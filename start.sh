#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -e -x -u

echo "Idea launcher tool"
echo "Usage: <tool> <IDEA binaries>"
echo ""
echo ""

FILE_NAME="$(basename "$1")"
FILE_BASE="$(cd "$(dirname "$1")" && pwd)"
FILE="${FILE_BASE}/${FILE_NAME}"

MIRROR_FILE=${FILE}_dmg

function detach_dmg {
  hdiutil detach -force "${MIRROR_FILE}" || true
}

trap detach_dmg EXIT

hdiutil attach -readonly -noautoopen -noautofsck -nobrowse -mountpoint "${MIRROR_FILE}" "$FILE"

ls -lah "${MIRROR_FILE}"


APP_DMG_HOME="$(cd "$(find "${MIRROR_FILE}" -type d -name "*.app")" && pwd)"
APP_NAME="$(basename "$FILE" .dmg)"
APP_HOME="${DIR}/runs/${APP_NAME}"
APP_DIR="${APP_HOME}/$(basename "${APP_DMG_HOME}")"
APP_DATA="${APP_HOME}/data"

echo "Traget app home: $APP_HOME"
echo "Mounted IntelliJ IDE home is: $APP_DMG_HOME"


rm /rf "${APP_DIR}" || true
mkdir -p "${APP_HOME}" || true


cp -R "${APP_DMG_HOME}" "${APP_HOME}"

VMOPTS="${APP_DIR}.vmoptions"
cp "${APP_DMG_HOME}/Contents/bin/idea.vmoptions" "$VMOPTS"

PROFILER_MODE=tracing
PROFILER_AGENT="/Applications/YourKit-Java-Profiler-2019.1.app/Contents/Resources/bin/mac/libyjpagent.jnilib"

echo "-agentpath:${PROFILER_AGENT}=onexit=snapshot,sessionname=TB_IJ_${APP_NAME},port=54444-54555,${PROFILER_MODE}" >> "$VMOPTS"
echo "-Dide.no.platform.update=true"           >> "$VMOPTS"
echo "-Didea.config.path=${APP_DATA}/config"   >> "$VMOPTS"
echo "-Didea.system.path=${APP_DATA}/system"   >> "$VMOPTS"
echo "-Didea.plugins.path=${APP_DATA}/plugins" >> "$VMOPTS"
echo "-Didea.log.path=${APP_DATA}/log"         >> "$VMOPTS"

echo "The application is ready to run!"
echo ""
echo "open \"${APP_DIR}\""
echo ""
echo ""






