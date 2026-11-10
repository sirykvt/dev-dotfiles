#!/usr/bin/env python3
"""Backs up or restores Claude Code, Codex, Rider and IdeaVim settings on Windows and macOS.

Usage: python dotfiles.py backup|restore
"""
import os
import re
import shutil
import subprocess
import sys
from fnmatch import fnmatch
from pathlib import Path

REPO = Path(__file__).resolve().parent
HOME = Path.home()
IS_WINDOWS = sys.platform == "win32"

# Machine-local state, usage stats and window layouts that should not travel between machines.
RIDER_OPTIONS_EXCLUDE = [
    "*.local.xml", "vim_settings_local.xml", "recentSolutions*.xml", "window.state.xml",
    "rider.perapp.window.state.v2.xml", "*usage.statistics.xml", "actionSummary.xml",
    "contributorSummary.xml", "EventLogAllowedList.xml", "CommonFeedbackSurveyService.xml",
    "DontShowAgainFeedbackService.xml", "trace_license_storage.xml", "updates.xml",
    "riderVersions.xml", "trustedSolutions.xml", "trusted-paths.xml", "settingsSyncLocal.xml",
]


def jetbrains_root() -> Path:
    if IS_WINDOWS:
        return Path(os.environ["APPDATA"]) / "JetBrains"
    return HOME / "Library" / "Application Support" / "JetBrains"


def newest_rider_dir() -> Path:
    """Restore targets the newest installed Rider so settings carry over after an upgrade."""
    candidates = []
    for path in jetbrains_root().glob("Rider*"):
        match = re.fullmatch(r"Rider(\d{4})\.(\d+)", path.name)
        if match and path.is_dir():
            candidates.append(((int(match[1]), int(match[2])), path))
    if not candidates:
        sys.exit(f"No Rider config directory found in {jetbrains_root()}")
    return max(candidates)[1]


def is_rider_running() -> bool:
    if IS_WINDOWS:
        result = subprocess.run(["tasklist", "/FI", "IMAGENAME eq rider64.exe", "/NH"],
                                capture_output=True, text=True)
        return "rider64.exe" in result.stdout.lower()
    return subprocess.run(["pgrep", "-x", "rider"], capture_output=True).returncode == 0


def copy(src: Path, dst: Path, exclude: list[str]) -> None:
    if not src.exists():
        print(f"  skip (missing): {src}")
        return
    if src.is_dir():
        ignore = lambda _dir, names: [n for n in names if any(fnmatch(n, p) for p in exclude)]
        shutil.copytree(src, dst, ignore=ignore, dirs_exist_ok=True)
    else:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
    print(f"  {src} -> {dst}")


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in ("backup", "restore"):
        sys.exit(__doc__)
    action = sys.argv[1]

    if action == "restore" and is_rider_running():
        sys.exit("Close Rider before restoring: it overwrites its settings on exit.")

    rider_dir = newest_rider_dir()
    print(f"Rider config: {rider_dir}")

    entries = [
        ("claude", HOME / ".claude",
         ["settings.json", "CLAUDE.md", "keybindings.json", "statusline.js", "hooks"], []),
        ("codex", HOME / ".codex",
         ["config.toml", "AGENTS.md", "hooks.json", "review.config.toml",
          "permission-review.ps1", "herdr-agent-state.ps1"], []),
        ("rider", rider_dir,
         ["options", "keymaps", "codestyles", "colors", "disabled_plugins.txt",
          "resharper-host/GlobalSettingsStorage.DotSettings"], RIDER_OPTIONS_EXCLUDE),
        (".", HOME, [".ideavimrc"], []),
    ]

    for repo_dir, target_dir, items, exclude in entries:
        for item in items:
            repo_path = REPO / repo_dir / item
            target_path = target_dir / item
            if action == "backup":
                # Drop stale files so deletions on the machine are reflected in the repo.
                if repo_path.is_dir():
                    shutil.rmtree(repo_path)
                copy(target_path, repo_path, exclude)
            else:
                copy(repo_path, target_path, [])


if __name__ == "__main__":
    main()
