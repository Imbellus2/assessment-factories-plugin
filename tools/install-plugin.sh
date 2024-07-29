#!/bin/bash
set -e

# Determine the project root directory
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
  OUTPUT_DIR="$HOME/Documents/Roblox/Plugins"
else
  # Windows
  PROJECT_ROOT="$(cd "$(dirname "$0")\.." && pwd -W)"
  OUTPUT_DIR="$USERPROFILE\AppData\Local\Roblox\Plugins"
fi

cd "$PROJECT_ROOT"
rojo build --output "$OUTPUT_DIR/factories-plugin.rbxmx" plugin.project.json
echo "Plugin installed"