# dotfiles

Settings for Claude Code, Codex, Rider and IdeaVim on Windows and macOS.

| Repo dir     | Windows                             | macOS                                               |
|--------------|-------------------------------------|-----------------------------------------------------|
| `claude/`    | `%USERPROFILE%\.claude`             | `~/.claude`                                         |
| `codex/`     | `%USERPROFILE%\.codex`              | `~/.codex`                                          |
| `rider/`     | `%APPDATA%\JetBrains\Rider<newest>` | `~/Library/Application Support/JetBrains/Rider<newest>` |
| `.ideavimrc` | `%USERPROFILE%\.ideavimrc`          | `~/.ideavimrc`                                      |

Requires Python 3.9+.

```sh
python3 dotfiles.py backup    # machine -> repo
python3 dotfiles.py restore   # repo -> machine (close Rider first)
```

Credentials, licenses, history, caches, Rider plugins and Toolbox-managed `.vmoptions` are not stored.
After restoring on a new machine, sign in to Claude/Codex and reinstall Rider plugins.
