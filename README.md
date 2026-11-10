# dotfiles

Settings for Claude Code, Codex, Rider and IdeaVim.

| Repo dir  | Machine location                          |
|-----------|-------------------------------------------|
| `claude/` | `%USERPROFILE%\.claude`                   |
| `codex/`  | `%USERPROFILE%\.codex`                    |
| `rider/`  | `%APPDATA%\JetBrains\Rider<newest>`       |
| `.ideavimrc` | `%USERPROFILE%\.ideavimrc`             |

```powershell
.\dotfiles.ps1 backup    # machine -> repo
.\dotfiles.ps1 restore   # repo -> machine (close Rider first)
```

Credentials, licenses, history, caches and Rider plugins are not stored. After restoring on a new
machine, sign in to Claude/Codex and reinstall Rider plugins.
