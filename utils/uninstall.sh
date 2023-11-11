#!/bin/zsh

#
# Uninstall Keyave.
#

# Function to revert Touch ID for sudo changes.
revert_touch_id_for_sudo() {
  echo "Reverting Touch ID for sudo authentication..."
  # Check for OS and use appropriate sed syntax.
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS requires an empty string as an argument to -i.
    sudo sed -i '' '/auth sufficient pam_tid.so/d' /etc/pam.d/sudo
  else
    # Other Unix-like systems (like Linux) do not require an empty string.
    sudo sed -i '/auth sufficient pam_tid.so/d' /etc/pam.d/sudo
  fi
}

# Function to revert auto unlock when docked.
revert_auto_unlock() {
  echo "Reverting auto unlock when docked..."

  # Explicitly set the system default to FALSE.
  defaults write com.apple.security.authorization ignoreArd -bool FALSE
}

# Main script execution.
echo "This will revert the changes made by the Keyave script."
read -q "REPLY?Do you want to proceed with uninstallation? [y/N] "
echo ""
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  revert_touch_id_for_sudo
  revert_auto_unlock
  echo "Uninstallation complete."
else
  echo "Uninstallation cancelled by the user."
fi
