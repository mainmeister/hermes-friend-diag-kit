#!/bin/bash
# Smoke test for the friend-diagnostic kit, run AFTER OOBE + Guest Additions.
# Prereqs:
#   - VM is at the desktop
#   - Guest Additions installed (so the shared folder works)
#   - User created an account in OOBE (e.g. "Tester")
#
# This script automates some of the steps the friend would normally do, for testing purposes.
#
# IMPORTANT: This script is intended to be run by the kit operator (tester) from their Linux host,
#            interacting with a Windows VM. It is NOT part of the USB kit itself.

set -e

# --- CONFIGURATION VARIABLES --- #
# Adjust these for your testing environment.
VM_NAME="Your-Windows-VM-Name" # e.g., "Win11-Eval"
OPERATOR_SSH_KEY_PATH="/home/youruser/.ssh/id_ed25519.pub" # Your public SSH key path
# --- END CONFIGURATION VARIABLES --- #


echo "=== 1. (Optional) Detach install ISO from VM if still attached ==="
# VBoxManage storageattach "$VM_NAME" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium none 2>&1 || true
# Uncomment the above line and configure VM_NAME if you use VirtualBox and need to automate ISO detachment.

echo "=== 2. Ensure cloudflared tunnel is NOT running on the operator's host ==="
pkill -f config.yml 2>/dev/null && echo "Killed stale cloudflared instance on operator host." || echo "Operator host is clean."

echo "=== 3. Confirm operator's SSH config + key auth ==="
# Verify your SSH public key and potentially your SSH client config.
ssh-keygen -lf "$OPERATOR_SSH_KEY_PATH"
# Example of checking SSH config for a specific host alias:
# ls -la ~/.ssh/config
# grep -A2 "Host friend$" ~/.ssh/config | head -8

echo "=== 4. Instructions for the user (or tester) to run inside the VM ==="
cat <<'USER_INSTRUCTIONS'

----- USER INSTRUCTIONS (in the VM window or on the friend's PC) -----
This section describes the manual steps to be performed inside the Windows VM (or friend's PC)
for the smoke test. Assume the USB kit files are accessible (e.g., via a shared folder or actual USB drive).

1.  Log in to Windows if you haven't already.
2.  Ensure the USB kit files are accessible (e.g., if using VirtualBox, verify the shared folder is mapped as a drive, typically Z:).
    If not present, ensure VirtualBox Guest Additions are installed (from the VM Devices
    menu choose "Insert Guest Additions CD image", then run
    VBoxWindowsAdditions.exe inside the VM, then reboot).
3.  Open PowerShell as Administrator (right-click Start → Terminal
    (Admin), or search "PowerShell" → Run as administrator).
4.  Navigate to the kit directory (e.g., `cd Z:\friend-diag`) and run:
        .\setup-openssh.ps1
5.  Press Enter to continue when prompted, wait ~30 sec for "Done!".
6.  Note the Windows username it prints (e.g. "Tester"). This is what the operator will use to SSH in.
7.  Open another PowerShell window (no admin needed) and navigate to the kit directory (e.g., `cd Z:\friend-diag`).
8.  Run:
        .\connect.bat
9.  Leave the `connect.bat` window open. Wait until you see a line
    saying "Registered tunnel connection" — that's the tunnel
    coming up.

When you've reached step 9, notify the operator, who will then run the SSH test
from their host machine to confirm the full chain works.

----- END USER INSTRUCTIONS -----

USER_INSTRUCTIONS
