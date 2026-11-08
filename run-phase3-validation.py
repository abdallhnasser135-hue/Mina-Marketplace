#!/usr/bin/env python3
"""Runs every Phase 3 validation and writes validation/final-validation.log. Exit 0 only if nothing failed or was skipped."""
import subprocess, sys, os, shutil, datetime
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.dirname(D); os.chdir(D)
SQL_ENV = os.environ.get('MINA_SQL_ENV', '/home/claude/sqlcheck'); BOARD_ENV = os.environ.get('MINA_BOARD_ENV', '/home/claude/boards')
steps = [
 ('tokens', [sys.executable, 'validate-tokens.py'], D),
 ('screens vs api/schema/traceability', [sys.executable, 'validate-design.py'], D),
 ('component consistency', [sys.executable, 'validate-components.py'], D),
 ('documentation consistency', [sys.executable, 'validate-docs.py'], D),
]
def node(label, script, env, extra_files=()):
    if not os.path.isdir(os.path.join(env, 'node_modules')): return (label, None, f'SKIPPED: no node_modules in {env}')
    for f in (script, *extra_files): shutil.copy(os.path.join(R, f) if os.path.exists(os.path.join(R, f)) else os.path.join(D, f), env)
    return (label, ['node', os.path.basename(script)], env)
results = []
for label, cmd, cwd in steps:
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True); results.append((label, p.returncode, p.stdout + p.stderr))
for label, script, env, extra in [
    ('database: Phase 2 base schema suite', 'validation/check-schema.mjs', SQL_ENV, ()),
    ('database: migration 002 (fresh and populated)', 'validation/check-migration.mjs', SQL_ENV, ('validation/populated.mjs',)),
    ('boards: RTL lint, tokens, axe structure', 'design/validation/lint-boards.mjs', BOARD_ENV, ()),
    ('boards: touch targets and disabled controls', 'design/validation/check-targets.mjs', BOARD_ENV, ())]:
    r = node(label, script, env, extra)
    if r[1] is None: results.append((label, None, r[2])); continue
    name = os.path.basename(script)
    p = subprocess.run(['node', name], cwd=env, capture_output=True, text=True)
    results.append((label, p.returncode, p.stdout + (p.stderr if p.returncode else '')))
lines = [f'# Phase 3 final validation, {datetime.datetime.now(datetime.timezone.utc):%Y-%m-%d %H:%MZ}', '']
bad = 0
for label, rc, out in results:
    status = 'SKIPPED' if rc is None else ('PASS' if rc == 0 else 'FAIL')
    if status != 'PASS': bad += 1
    summary = out.strip().splitlines()[-1] if out.strip() else ''
    ok = sum(1 for l in out.splitlines() if l.startswith(('OK','CLEAN'))); fl = sum(1 for l in out.splitlines() if l.startswith('FAIL'))
    note = summary if status != 'PASS' else ''
    lines.append(f'{status:8} {label}  (OK lines: {ok}, FAIL lines: {fl})  {note}')
lines += ['', 'OVERALL: ' + ('PASS' if not bad else f'{bad} step(s) did not pass')]
open(os.path.join(D, 'validation', 'final-validation.log'), 'w').write('\n'.join(lines) + '\n\n' + '\n\n'.join(f'===== {l}\n{o}' for l, _, o in results))
print('\n'.join(lines)); sys.exit(1 if bad else 0)
