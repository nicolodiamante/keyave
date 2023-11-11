#!/bin/zsh

#
# Keyave — Seamlessly Integrate Touch ID for Enhanced Mac Security.
# By Nicolò Diamante <hello@nicolodiamante.com>
# https://github.com/nicolodiamante/keyave
# MIT License
#

# Function to check for Touch ID support.
has_touch_id() {
  local touch_id_info=$(system_profiler SPBiometricDataType)
  if [[ $touch_id_info == *"Touch ID"* ]]; then
    return 0 # Touch ID is supported.
  else
    return 1 # Touch ID is not supported.
  fi
}

# Function to enable Touch ID for sudo.
enable_touch_id_for_sudo() {
  echo "Enabling Touch ID for sudo authentication..."
  echo "auth sufficient pam_tid.so" | sudo tee -a /etc/pam.d/sudo.temp
  cat /etc/pam.d/sudo >> /etc/pam.d/sudo.temp
  sudo mv /etc/pam.d/sudo.temp /etc/pam.d/sudo
}

# Function to enable auto unlock when docked.
enable_auto_unlock() {
  echo "Enabling auto unlock when docked..."
  defaults write com.apple.security.authorization ignoreArd -bool TRUE
}

# Main script execution.
if has_touch_id; then
  echo "Touch ID is supported on this Mac."

  # Ask about enabling Touch ID for sudo.
  read -q "REPLY?Do you want to enable Touch ID for sudo? [y/N] "
  echo ""
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    enable_touch_id_for_sudo
    echo "Touch ID for sudo enabled."
  else
    echo "Skipping Touch ID for sudo."
  fi

  # Ask about enabling auto unlock when docked.
  read -q "REPLY?Do you want to enable auto unlock when docked? [y/N] "
  echo ""
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    enable_auto_unlock
    echo "Auto unlock when docked enabled."
  else
    echo "Skipping auto unlock when docked."
  fi

  echo "Setup complete."
else
  echo "Touch ID is not supported on this Mac. No changes made."
fi
