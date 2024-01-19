#!/bin/zsh

#
# Keyave — Integrate Touch ID in Terminal for Enhanced Mac Security.
# By Nicolò Diamante <hello@nicolodiamante.com>
# https://github.com/nicolodiamante/keyave
# MIT License
#

#
# Enable Touch ID for sudo on macOS
#

# Validate macOS version
SW_VERS=$(sw_vers --productVersion)
OS_VERS=$(echo "$SW_VERS" | cut -d '.' -f 1)
PAM_TEMP_FILE="/etc/pam.d/sudo_local.template"
PAM_AUTH_FILE="/etc/pam.d/sudo_local"
PAM_SUDO_FILE="/etc/pam.d/sudo"

# Ask about enabling Touch ID for sudo
read -q "REPLY?Do you want to enable Touch ID for sudo? [y/N] "
echo ""
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  echo "\nEnabling Touch ID for sudo authentication..."

  if [[ "$OS_VERS" -ge 14 ]]; then
    # Backup existing file
    if [[ -f "$PAM_AUTH_FILE" ]]; then
      local BACKUP_FILE="${PAM_AUTH_FILE}_$(\date "+%Y%m%d%H%M%S").bak"
      echo "\nBacking up existing file to ${BACKUP_FILE}..."
      sudo /bin/mv "${PAM_AUTH_FILE}" "${BACKUP_FILE}"
    fi

    # Copy template file
    # Remove the comment mark granting Touch ID
    # Set ownership and permissions
    if [[ ! -f "$PAM_AUTH_FILE" ]]; then
      sudo /bin/cp "${PAM_TEMP_FILE}" "${PAM_AUTH_FILE}"
      sudo sed -i '' -e 's,#auth       sufficient     pam_tid.so,auth       sufficient     pam_tid.so,g' "${PAM_AUTH_FILE}"
      sudo /usr/sbin/chown root:wheel "${PAM_AUTH_FILE}"
      sudo /bin/chmod 555 "${PAM_AUTH_FILE}"
    else
      echo "\nkeyave: Failed to find ${PAM_AUTH_FILE}. Touch ID authorization for sudo could not be enabled."
      exit 1
    fi
  else
    # Backup existing sudo file
    local BACKUP_FILE="${PAM_SUDO_FILE}_$(\date "+%Y%m%d%H%M%S").bak"
    echo "\nBacking up existing sudo file to ${BACKUP_FILE}..."
    sudo /bin/cp "${PAM_SUDO_FILE}" "${BACKUP_FILE}"

    # Add Touch ID support at the top of the file
    if ! sudo grep -q "pam_tid.so" "${PAM_SUDO_FILE}"; then
      # Create a new file with Touch ID line at the top
      echo "auth       sufficient     pam_tid.so" | sudo cat - "${PAM_SUDO_FILE}" > temp_pam_sudo
      sudo mv temp_pam_sudo "${PAM_SUDO_FILE}"
      echo "\nTouch ID for sudo enabled on macOS."
    else
      echo "\nTouch ID already enabled in sudo configuration."
    fi
  fi
else
  echo "\nEnabling Touch ID for sudo skipped."
fi

echo "\nOpening Passwords Shortcut..."
sleep 3

# Open the Keyave Shortcut URL
SHORTUCT_URL="https://www.icloud.com/shortcuts/afd3e6896604451ab31cd303a153c881"
open "${SHORTUCT_URL}"

echo "\nKeyave: Touch ID for sudo enabled."
