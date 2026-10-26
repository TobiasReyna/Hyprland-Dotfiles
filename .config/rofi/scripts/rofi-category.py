#!/usr/bin/env python3
import os
import sys
import glob
import subprocess

CATEGORY_MAP = {
    "Juegos": {"game"},
    "Multimedia": {"audiovideo", "audio", "video", "player", "recorder", "midi", "graphics", "music"},
    "Desarrollo": {"development", "ide", "building", "debugger", "revisioncontrol"},
    "Sistema": {"system", "settings", "packagemanager", "monitor", "hardwaresettings", "desktopsettings"},
    "Utilidades": {"utility", "core", "accessories", "texteditor", "filemanager", "archiving", "network", "webbrowser"},
}

def parse_desktop(path):
    data = {}
    in_entry = False
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                line = line.strip()
                if line.startswith("[") and line.endswith("]"):
                    in_entry = (line == "[Desktop Entry]")
                    continue
                if in_entry and "=" in line:
                    k, v = line.split("=", 1)
                    k = k.strip()
                    v = v.strip()
                    if k not in data:
                        data[k] = v
    except Exception:
        pass
    return data

def get_apps():
    search_dirs = [
        "/usr/share/applications",
        os.path.expanduser("~/.local/share/applications")
    ]
    desktop_files = []
    for sdir in search_dirs:
        if os.path.isdir(sdir):
            desktop_files.extend(glob.glob(os.path.join(sdir, "*.desktop")))
            desktop_files.extend(glob.glob(os.path.join(sdir, "**", "*.desktop")))

    apps = []
    seen = set()

    for path in sorted(desktop_files):
        d = parse_desktop(path)
        if d.get("NoDisplay", "").lower() == "true":
            continue
        if d.get("Type", "Application") != "Application":
            continue
        name = d.get("Name")
        if not name:
            continue
        
        # Deduplicate by app name
        if name in seen:
            continue
        seen.add(name)

        icon = d.get("Icon", "application-x-executable")
        cats = {c.lower() for c in d.get("Categories", "").split(";") if c}
        apps.append((name, icon, cats, path))

    apps.sort(key=lambda x: x[0].lower())
    return apps

def main():
    mode = os.path.basename(sys.argv[0])

    # If an entry was selected (ROFI_RETV is 1 or 2, or argument passed)
    retv = os.environ.get("ROFI_RETV")
    if (retv in ("1", "2")) or (retv is not None and retv != "0" and len(sys.argv) > 1):
        target = os.environ.get("ROFI_INFO")
        if not target and len(sys.argv) > 1:
            target = sys.argv[1].strip()

        if target:
            if os.path.isfile(target):
                subprocess.Popen(["gio", "launch", target], start_new_session=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                subprocess.Popen(["gtk-launch", target], start_new_session=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        sys.exit(0)

    # Initial call: output app list for current category
    apps = get_apps()
    keywords = CATEGORY_MAP.get(mode)

    for name, icon, cats, path in apps:
        if keywords and not (cats & keywords):
            continue
        # Format: Name\0icon\x1fIcon\x1finfo\x1fDesktopPath
        sys.stdout.write(f"{name}\0icon\x1f{icon}\x1finfo\x1f{path}\n")
    sys.stdout.flush()

if __name__ == "__main__":
    main()
