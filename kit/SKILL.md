---
name: worldbuilding-kit
description: Use when the user wants to build, extend, or resume a fictional world for a writing project — world bible, lore, setting, or character backstory.
---

# Worldbuilding kit (installer)

Installs the real skill into this project, then gets out of the way.

1. `project_root` = nearest ancestor holding `.git`, else CWD.
2. If CWD is `$HOME`, or holds neither `.git` nor `world/`: **do not scaffold.** Ask which folder
   holds the manuscript. If told "here", echo the absolute path and confirm once.
3. If `<CWD>/.pi/skills/worldbuilding/SKILL.md` is absent, copy it in from `../bundle/worldbuilding`
   relative to this file's real directory (`readlink -f`), excluding `tests/`, after `mkdir -p
   .pi/skills`. Say once that project skills now load from this repo.
4. If present at a different `version`: offer the upgrade; replace only that folder, never `world/`.
5. `read` `<CWD>/.pi/skills/worldbuilding/SKILL.md` and follow it from here; never re-install this
   session.
