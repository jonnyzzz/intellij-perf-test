#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -e -x -u

echo "Idea launcher tool"
echo "Usage: <tool> [install|run] <IDEA binaries>"
echo ""
echo ""

FILE_NAME="$(basename "$2")"
FILE_BASE="$(cd "$(dirname "$2")" && pwd)"
FILE="${FILE_BASE}/${FILE_NAME}"

MIRROR_FILE=${FILE}_dmg


APP_NAME="$(basename "$FILE" .dmg)"
APP_HOME="${DIR}/runs/${APP_NAME}"

TASK=$1

echo "Traget app home: $APP_HOME"


if [ "install" = "$TASK" ]; then
  
  function detach_dmg {
     hdiutil detach -force "${MIRROR_FILE}" || true
  }

  trap detach_dmg EXIT

  hdiutil attach -readonly -noautoopen -noautofsck -nobrowse -mountpoint "${MIRROR_FILE}" "$FILE"

  ls -lah "${MIRROR_FILE}"

  APP_DMG_HOME="$(cd "$(find "${MIRROR_FILE}" -type d -name "*.app")" && pwd)"
  APP_DIR="${APP_HOME}/$(basename "${APP_DMG_HOME}")"

  echo "Mounted IntelliJ IDE home is: $APP_DMG_HOME"

  rm /rf "${APP_DIR}" || true
  mkdir -p "${APP_HOME}" || true

  cp -R "${APP_DMG_HOME}" "${APP_HOME}"
  
  TASK=patch
fi

if [ ! -d "${APP_HOME}" ]; then
   echo "Application is not installed!"
   exit 1
fi


APP_DIR="$(cd "$(find "${APP_HOME}" -type d -name "*.app")" && pwd)"
APP_DATA="${APP_DIR}/data"

if [ "patch" = "$TASK" ]; then
  VMOPTS="${APP_DIR}.vmoptions"
  rm "${VMOPTS}" || true
  cp "${APP_DIR}/Contents/bin/idea.vmoptions" "$VMOPTS"

  PROFILER_MODE=tracing
  PROFILER_AGENT="/Applications/YourKit-Java-Profiler-2019.1.app/Contents/Resources/bin/mac/libyjpagent.jnilib"

  echo "-agentpath:${PROFILER_AGENT}=onexit=snapshot,sessionname=TB_IJ_${APP_NAME},port=54444-54555,${PROFILER_MODE}" >> "$VMOPTS"
  echo "-Dide.no.platform.update=true"           >> "$VMOPTS"
  echo "-Didea.config.path=${APP_DATA}/config"   >> "$VMOPTS"
  echo "-Didea.system.path=${APP_DATA}/system"   >> "$VMOPTS"
  echo "-Didea.plugins.path=${APP_DATA}/plugins" >> "$VMOPTS"
  echo "-Didea.log.path=${APP_DATA}/log"         >> "$VMOPTS"

fi


if [ "run" = "$1" ]; then 

  open "${APP_DIR}"
fi





