"""flutter create ke baad Android/web files me app ki zaroori settings jodta hai.

Chalao (flutter_app folder se): python3 tool/patch_platforms.py
"""
import pathlib
import re

root = pathlib.Path(__file__).resolve().parent.parent

manifest = root / "android/app/src/main/AndroidManifest.xml"
if manifest.exists():
    s = manifest.read_text()
    if "android.permission.INTERNET" not in s:
        s = s.replace("<application", '<uses-permission android:name="android.permission.INTERNET"/>\n    <application', 1)
    s = re.sub(r'android:label="[^"]*"', 'android:label="SSS Shop"', s, count=1)
    extra = (
        '<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>\n'
        '        <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>\n'
        '        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="whatsapp"/></intent>\n'
        "        "
    )
    if 'android:scheme="tel"' not in s:
        if "<queries>" in s:
            s = s.replace("<queries>", "<queries>\n        " + extra, 1)
        else:
            s = s.replace("</manifest>", "    <queries>\n        " + extra + "</queries>\n</manifest>", 1)
    manifest.write_text(s)
    print("patched", manifest)

index = root / "web/index.html"
if index.exists():
    s = index.read_text()
    s = re.sub(r"<title>.*?</title>", "<title>Shree Sawriya Shop</title>", s, count=1, flags=re.S)
    if 'name="theme-color"' not in s:
        s = s.replace("</head>", '  <meta name="theme-color" content="#0A0B0A">\n</head>', 1)
    index.write_text(s)
    print("patched", index)

wm = root / "web/manifest.json"
if wm.exists():
    s = wm.read_text()
    s = re.sub(r'"background_color":\s*"[^"]*"', '"background_color": "#0A0B0A"', s)
    s = re.sub(r'"theme_color":\s*"[^"]*"', '"theme_color": "#0A0B0A"', s)
    s = re.sub(r'"name":\s*"[^"]*"', '"name": "Shree Sawriya Shop"', s, count=1)
    s = re.sub(r'"short_name":\s*"[^"]*"', '"short_name": "SSS Shop"', s, count=1)
    wm.write_text(s)
    print("patched", wm)
