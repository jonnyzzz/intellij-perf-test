#!/bin/bash

set -e -x -u

echo "Idea launcher tool"
echo "Usage: <tool> <IDEA binaries>"
echo ""
echo ""

FILE_NAME="$(basename "$1")"
FILE_BASE="$(cd "$(dirname "$1")" && pwd)"
FILE="${FILE_BASE}/${FILE_NAME}"



