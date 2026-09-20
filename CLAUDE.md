@AGENTS.md

## Claude Code

Everything tool-neutral lives in `AGENTS.md` (imported above). Keep it that way: only add
things here that are specific to Claude Code, and put any new project rule in `AGENTS.md`
so other agents and human contributors pick it up too.

### Tooling in this checkout

- Use the plain `flutter` / `dart` commands in `AGENTS.md`. They are what CI runs and
  what a contributor will have. If this checkout happens to carry a local fvm pin
  (`.fvmrc` is gitignored, so it may or may not) prefix with `fvm`. Do not add one,
  and do not tell anyone they need fvm to work on this repo.
- `flutter run` for `example/` is long-running — ask before starting it and don't
  leave it running in the background.

### Working style

- Prefer the file tools (Read / Edit / Grep / Glob) over `cat`/`sed`/`grep` in Bash for
  reading and editing repo files.
- The package is small, about a thousand lines under `lib/`; targeted `Grep` is
  almost always faster here than a search subagent.
- Run `/code-review` on the diff before handing work over.

### Commits and PRs

- Follow the forking + PR workflow in `AGENTS.md`; don't push to
  `Baseflow/octo_image` branches directly unless the maintainer asks for it in
  that session.
- End commit messages with:

  ```
  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

- End PR descriptions with:

  ```
  🤖 Generated with [Claude Code](https://claude.com/claude-code)
  ```
