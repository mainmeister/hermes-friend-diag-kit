FRIEND DIAGNOSTICS KIT
======================

What this does
--------------
Lets a remote friend securely SSH into this PC from their own computer
to help diagnose problems. No password needed — the kit installs the
operator's public key on your machine, so they log straight in.
The connection runs through Cloudflare's network using a *named tunnel* —
no port forwarding, no firewall holes exposing you to the wider internet,
no quick-tunnel expiry.

What's on the USB stick:
  `cloudflared.exe`                  Cloudflare's tunnel client (Windows portable)
  `config.yml`                       Tunnel configuration (routes SSH to localhost:22)
  `friend-diag-credentials.json`     Tunnel credentials (KEEP THIS SECRET — it
                                   authorises anyone holding it to run the tunnel)
  `setup-openssh.ps1`                Run once as Administrator to enable OpenSSH Server
                                   (also installs the operator's public key)
  `connect.bat`                      Double-click to start the tunnel
  `stop.bat`                         Stops cloudflared if the window is in the way
  `README.txt`                       This file

ONE-TIME SETUP (you only do this once per PC)
----------------------------------------------
1. Right-click "setup-openssh.ps1"
2. Choose "Run with PowerShell as Administrator"
3. Click "Yes" on the UAC prompt
4. Wait for "Done!" (about 30 seconds)
5. Note the Windows username it prints at the end
   (or open PowerShell any time and type: whoami)
6. Send that username to your friend (you do NOT need to send a password
   — the kit uses passwordless key auth)

EVERY TIME YOU WANT HELP
------------------------
1. Double-click "connect.bat"
2. A black window opens. Wait until you see a line that says
   "Registered tunnel connection" — that means the tunnel is up.
   (Usually 5-15 seconds.)
3. Tell your friend: "Tunnel is up, you can SSH in now."
   They'll SSH in using your Windows username.
4. LEAVE THE WINDOW OPEN while your friend is working.
5. When done, just close the window (or run "stop.bat").

Unlike the previous version of this kit, the URL is now
`{{HOSTNAME}}.{{YOUR_DOMAIN}}` — it stays the same every time and
doesn't expire after 90 days.

TROUBLESHOOTING
---------------
- "sshd service not found" or "service did not start":
    Re-run `setup-openssh.ps1` as Administrator.

- Friend says "connection refused" or "no route to host":
    Make sure `connect.bat` is still running on this PC and showing
    "Registered tunnel connection" lines.

- Friend says "permission denied (publickey)":
    Re-run `setup-openssh.ps1` as Administrator. Step 4 installs the
    operator's public key into BOTH your personal `authorized_keys` file
    AND the system-wide one (`C:\ProgramData\ssh\administrators_authorized_keys`)
    that Windows OpenSSH Server actually checks for admin accounts.
    If that step didn't complete, the operator has no key to use.
    Also: the operator may have typed the username wrong. Yours is the
    one printed at the end of `setup-openssh.ps1`.

- "Windows Defender SmartScreen prevented an unrecognized app":
    Click "More info" then "Run anyway". `cloudflared` is signed by
    Cloudflare but SmartScreen warns on first run.

- "Execution of scripts is disabled on this system":
    Open PowerShell as Administrator and run:
        `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`
    Then re-run `setup-openssh.ps1`.

- "failed to fetch configuration" or "tunnel not found":
    The credentials file is missing or wrong. Verify
    `friend-diag-credentials.json` is in the same folder as
    `cloudflared.exe`.

WHAT YOUR FRIEND CAN SEE
------------------------
When connected, your friend has a PowerShell prompt as your Windows
user. They can:
  - Read system information
  - Run diagnostic commands
  - View files in your user profile
  - Change settings (with your permission)
  - Install or remove software (with your permission)

They CANNOT:
  - See your desktop or watch your screen (unless you send a screenshot)
  - Access other user accounts on this PC
  - Reach this PC after you close `connect.bat`
  - Reach this PC from anywhere other than through this specific tunnel
    (the hostname `{{HOSTNAME}}.{{YOUR_DOMAIN}}` is the only entry point)

SECURITY NOTES
--------------
- The credentials file (`friend-diag-credentials.json`) is a secret.
  Don't share the USB stick with anyone else, and don't leave it
  plugged in when you're not using it.
- The tunnel only forwards port 22 (SSH). Nothing else on this PC
  is exposed to the internet.
- If you stop using this kit, ask your friend to delete the tunnel
  from their Cloudflare account — that permanently revokes these
  credentials.

TO UNINSTALL EVERYTHING
-----------------------
1. `Settings -> Apps -> Optional Features`.
2. Find "OpenSSH Server" -> Uninstall
3. Delete this folder

That's it. The tunnel credentials are still valid (your friend can
revoke them), but no software remains on this PC.
