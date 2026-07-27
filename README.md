# Robocopy Explorer helpers — RootRecord
#
# Much faster than File Explorer for large folder trees.
# Adds right-click **Robo Copy** / **Robo Paste** for the current Windows user.

## Install (Windows)

```powershell
git clone https://github.com/RootRecord/roboclipboard.git
cd roboclipboard
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-RoboClipboard.ps1
```

Or download the scripts and run `Install-RoboClipboard.ps1` from that folder.

## Use

1. Right-click a **folder** → **Robo Copy**
2. Open the destination → right-click the folder (or empty space) → **Robo Paste**
3. Confirm — runs:

```text
robocopy <source> <dest>\<folder-name> /E /COPY:DAT /R:1 /W:1 /MT:8
```

## Files

| File | Role |
|------|------|
| `Robo-Copy.ps1` | Stores source path under `%LOCALAPPDATA%\RoboClipboard\source.txt` |
| `Robo-Paste.ps1` | Robocopies stored source into the chosen destination |
| `Install-RoboClipboard.ps1` | Copies scripts to LocalAppData + registers HKCU context menus |
| `Uninstall-RoboClipboard.ps1` | Removes context menus |
| `docs/Robocopy-Quick-Guide.html` | Printable cheat sheet (open → Ctrl+P) |

## Command-line (no context menu)

```powershell
robocopy "C:\path\to\source" "D:\path\to\destination" /E /COPY:DAT /R:1 /W:1 /MT:8
```

Exit codes **0–7** usually mean success (including “nothing new to copy”). **8+** = failure.

## Uninstall

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Uninstall-RoboClipboard.ps1
```

## Notes

- Current-user only (`HKCU`) — no admin required.
- Does not replace Explorer drag-and-drop globally; adds menu items.
- Prefer this for multi-GB trees / backups; Explorer is fine for a few small files.

## License

MIT
