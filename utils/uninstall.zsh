#!/bin/zsh

#
# Disable Touch ID for sudo on macOS
#

# Set PATHs
SW_VERS=$(sw_vers --productVersion)
OS_VERS=$(echo "$SW_VERS" | cut -d '.' -f 1)
PAM_AUTH_FILE="/etc/pam.d/sudo_local"
PAM_SUDO_FILE="/etc/pam.d/sudo"

# Main script execution
echo "This will revert the changes made by the Keyave script."

# Prompt the user
echo -n "Do you want to proceed with disabling Touch ID for sudo? [y/N]: "
read REPLY
echo ""
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  if [[ "$OS_VERS" -ge 14 ]]; then
    if [[ -f "$PAM_AUTH_FILE" ]]; then
      # Remove PAM local for macOS 14 and later
      sudo /bin/rm "${PAM_AUTH_FILE}"
      echo "Touch ID for sudo has been disabled for macOS."
    else
      echo "The ${PAM_AUTH_FILE} file does not exist. No changes made."
    fi

    # Restore the backup of sudo_local
    BACKUP_FILE=$(ls -t /etc/pam.d/sudo_local_* | head -n 1)
    if [[ -n "$BACKUP_FILE" ]]; then
      sudo /bin/mv "${BACKUP_FILE}" "${PAM_AUTH_FILE}"
      echo "Backup of sudo_local has been restored for macOS."
    else
      echo "No backup file found for sudo_local. No restoration made on macOS."
    fi
  else
    # Handle macOS versions prior to macOS 14
    # Find the most recent backup file
    BACKUP_FILE=$(ls -t /etc/pam.d/sudo_* | head -n 1)
    if [[ -n "$BACKUP_FILE" ]]; then
      sudo /bin/mv "${BACKUP_FILE}" "${PAM_SUDO_FILE}"
      echo "Touch ID for sudo has been disabled and original sudo configuration restored for macOS."
    else
      echo "No backup file found. Cannot revert changes on macOS."
    fi
  fi
else
  echo "Disabling Touch ID for sudo cancelled by the user."
fi
