---
name: remote-diag-kit
description: Automates the setup of the Hermes-powered USB troubleshooting kit, including Cloudflare Tunnel, SSH key injection, and kit assembly.
version: 1.0.0
author: Hermes Agent + mainmeister
platforms: [linux, windows]
tags: [devops, remote-support, cloudflare, ssh, windows, usb-kit, hermes]
---

# Remote Diagnostic Kit Setup (Hermes Skill)

This skill guides your Hermes Agent through the automated setup of the portable USB troubleshooting kit. It handles Cloudflare Tunnel creation, DNS configuration, `cloudflared` download, SSH key injection, and final kit assembly.

## Usage

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/mainmeister/hermes-friend-diag-kit.git ~/hermes-friend-diag-kit
    ```
    (Note: This step is typically done manually or by another agent before installing the skill.)

2.  **Install this skill:**
    ```bash
    hermes skill install ~/hermes-friend-diag-kit/remote-diag-kit.md
    ```

3.  **Run the setup action:**
    ```bash
    hermes skill run remote-diag-kit setup-kit
    ```

    This will kick off the automated process. You will be prompted for Cloudflare login, tunnel name, domain, and hostname.

## Actions

### `setup-kit`

This action orchestrates the entire kit setup process.

#### Steps:

1.  **Cloudflare Login & Tunnel Creation:**
    Hermes will guide you through the `cloudflared tunnel login` process. This usually involves opening a browser window for authentication to your Cloudflare account.
    Once authenticated, you will be prompted for a desired tunnel name (e.g., `friend-diag`).
    Hermes will then execute `cloudflared tunnel create <TUNNEL_NAME>` and confirm the creation.
    The unique `friend-diag-credentials.json` file will be generated in your `~/.cloudflared/` directory.

    **Example commands (executed by Hermes):**
    ```bash
    cloudflared tunnel login
    read -p "Enter desired tunnel name (e.g., friend-diag): " TUNNEL_NAME
    cloudflared tunnel create $TUNNEL_NAME
    ```

2.  **Domain & DNS Configuration:**
    Hermes will ask for your chosen domain (e.g., `yourdomain.com`) and the desired hostname (e.g., `helpdesk`).
    It will then use `cloudflared tunnel route dns <TUNNEL_NAME> <HOSTNAME>.<YOUR_DOMAIN>` to create the necessary CNAME record in your Cloudflare DNS, linking your chosen hostname to your tunnel.

    **Example commands (executed by Hermes):**
    ```bash
    read -p "Enter your domain (e.g., yourdomain.com): " YOUR_DOMAIN
    read -p "Enter desired hostname (e.g., helpdesk): " HOSTNAME
    cloudflared tunnel route dns $TUNNEL_NAME $HOSTNAME.$YOUR_DOMAIN
    ```

3.  **`config.yml` Customization:**
    Hermes will take the `templates/config.yml.template` from this repository, insert your newly generated Tunnel ID, and configure it to route SSH traffic from your chosen hostname (e.g., `helpdesk.yourdomain.com`) to `localhost:22` on the friend's machine.
    The resulting `config.yml` will be placed in the kit directory.

4.  **Download `cloudflared.exe`:**
    Hermes will download the latest `cloudflared.exe` for Windows directly from Cloudflare's GitHub releases into your kit directory.

5.  **SSH Key Injection:**
    Hermes will read your `~/.ssh/id_rsa.pub` (your public SSH key) and embed it directly into the `templates/setup-openssh.ps1.template` to create the final `setup-openssh.ps1` script for your friend. This ensures passwordless, key-based authentication.

6.  **Assemble the Kit:**
    Finally, Hermes will assemble all these generated, downloaded, and customized files into the final kit directory structure, typically `~/my_friend_usb/usb-kit/friend-diag/`, ready for you to copy to a physical USB drive.

## Files Provided by this Skill (Templates)

*   `templates/config.yml.template`: Template for the `cloudflared` configuration.
*   `templates/setup-openssh.ps1.template`: Template for the PowerShell setup script.

## Dependencies

*   `cloudflared` CLI (installed during the `setup-kit` process if not present)
*   `git` (for cloning the repository)
*   Python `requests` library (for downloading `cloudflared.exe`)

## Pitfalls & Troubleshooting

*   Ensure you are logged into the correct Cloudflare account during the `cloudflared tunnel login` step.
*   Verify DNS propagation for your chosen hostname.
*   Public SSH key (`~/.ssh/id_rsa.pub`) must exist. If not, generate one using `ssh-keygen`.
*   The final kit directory (`~/my_friend_usb/usb-kit/friend-diag/`) must be writable.
