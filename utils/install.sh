#!/bin/zsh

#
# Install Keyave.
#

# Validate OS.
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is only compatible with macOS" >&2
  exit 1
fi

# Set paths for the Keyave script and iCloud shortcut URL.
HAS_TOUCH_ID="${HOME}/keyave/script/has_touch_id.zsh"
SHORTUCT_URL="https://www.icloud.com/shortcuts/d25f1cdf4e7542d1b856d3f29ed52613"

# Prompt user and execute Keyave script if confirmed.
read -q "REPLY?Do you want to proceed with updating the Mac OS settings using the keyave script? [y/N] "
echo ""
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  # Execute Keyave script to enable macOS Security with Touch ID.
  source "${KEYAVE_SCRIPT}"
else
  echo "Update cancelled by the user."
fi

# Open the Keyave Shortcut URL.
open_url() {
  echo "Opening Keyave Shortcut in your browser..."
  open "${SHORTUCT_URL}"
}

# Execute.
open_url