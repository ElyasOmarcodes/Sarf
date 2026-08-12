#!/usr/bin/env bash
# Applied after `flutter create --platforms=android` in CI.
#   * sets the visible launcher label to the Arabic app name
#   * turns on RTL mirroring for the whole app
set -euo pipefail

M=android/app/src/main/AndroidManifest.xml
[ -f "$M" ] || { echo "No manifest at $M"; exit 1; }

python3 - "$M" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s = re.sub(r'android:label="[^"]*"', 'android:label="تصريف"', s, count=1)
if 'supportsRtl' not in s:
    s = s.replace('<application', '<application\n        android:supportsRtl="true"', 1)
open(p, 'w', encoding='utf-8').write(s)
print('patched', p)
PY
