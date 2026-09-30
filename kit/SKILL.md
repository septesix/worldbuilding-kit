---
name: worldbuilding-kit
description: Use when the user wants to build, extend, or resume a fictional world for a writing project — world bible, lore, setting, or character backstory.
---

# Worldbuilding kit (installer)

Installs the real skill, then hands off. Bundle = `../bundle/worldbuilding` beside this file's
`readlink -f` directory.

1. `project_root` = nearest `.git` ancestor, else CWD.
2. If `project_root` is `$HOME`, or holds neither `.git` nor `world/`: **write nothing** — ask which
   folder holds the manuscript, and confirm the path once if told "here".
3. If `<CWD>/.pi/skills/worldbuilding/SKILL.md` is absent: `mkdir -p .pi/skills`, copy the bundle
   excluding `tests/`, mention once that project skills now load from here.
4. Versions come only from the two `SKILL.md` files, never `world/`:
   `diff <(grep -m1 ' version:' BUNDLE) <(grep -m1 ' version:' INSTALLED)`. Differ → offer
   upgrade, replacing only that folder.
5. `read` the installed `SKILL.md`, follow it; never re-install this session.
