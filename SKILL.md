---
name: rdp-bridge
description: View and control a Windows desktop over RDP from a Linux host/WSL using FreeRDP inside an Xvfb desktop (reuses computer-use display when available).
version: 0.1.0
metadata:
  openclaw:
    os: [linux]
    requires:
      bins: [xfreerdp, Xvfb]
---

# rdp-bridge

Connect to and control a Windows machine via **RDP** from the OpenClaw Linux host/WSL environment (no Docker).

It runs **FreeRDP** (`xfreerdp`) inside a virtual X desktop:

- **Preferred mode (recommended):** reuse the `computer-use` skill’s Xvfb desktop (`DISPLAY=:99`). This enables screenshots and input via the proven `computer-use` scripts.
- **Fallback mode:** if no X server is available on the chosen `DISPLAY`, `rdp-bridge` can start an ad-hoc **Xvfb + lightweight window manager** (Openbox or XFWM).

## Prerequisites (Ubuntu/Debian)

Install:

```bash
sudo apt update
sudo apt install -y freerdp2-x11 xvfb x11-utils openbox \
  xdotool imagemagick
```

If you plan to reuse `computer-use` (recommended), also install and/or set it up (see `skills/computer-use/SKILL.md`).

### Platform / OS

- This skill is for **Linux hosts** (including **WSL2 Linux distributions**).
- It does **not** run on Windows directly.

## Notes for WSL

- You don’t need a Windows GUI; everything renders into Xvfb.
- If systemd is not enabled in your WSL distro, the `computer-use` systemd services may not be running; `rdp-bridge` can still start its own ad-hoc Xvfb session.

## Security notes

- **Do not commit passwords.** This repo never stores the RDP password.
- `rdp.connect` reads the password from `OPENCLAW_RDP_PASS` or prompts interactively.
- **Caveat:** FreeRDP receives the password via a command-line flag (`/p:`). On multi-user machines, other users may be able to see command lines via process listings. Prefer a single-user host.
- This skill **disables clipboard sharing** by default (`-clipboard`) per your security requirement.

## Commands (scripts)

All commands live in `skills/rdp-bridge/scripts/`.

### rdp.connect

```bash
./scripts/rdp.connect.sh HOST [PORT] USER
```

- Password source:
  - `OPENCLAW_RDP_PASS` env var (preferred), OR
  - interactive prompt (silent)

Example:

```bash
export OPENCLAW_RDP_PASS='SuperSecret'
./scripts/rdp.connect.sh 192.168.1.10 3389 Administrator
```

By default it uses `DISPLAY=:99` (matching `computer-use`). Override if needed:

```bash
export RDP_DISPLAY=:100
./scripts/rdp.connect.sh 10.0.0.5 3389 user
```

### rdp.status

```bash
./scripts/rdp.status.sh
```

Prints `status=connected` plus connection details and PID, or `status=disconnected`.

### rdp.screenshot

```bash
./scripts/rdp.screenshot.sh > shot.b64
```

- If `computer-use` exists, this delegates to `computer-use/scripts/screenshot.sh`.
- Otherwise falls back to ImageMagick `import`.

### rdp.click / rdp.type / rdp.key

These delegate to `computer-use` input scripts on the selected `DISPLAY`:

```bash
./scripts/rdp.click.sh 512 384 left
./scripts/rdp.type.sh "Hello from OpenClaw"
./scripts/rdp.key.sh "Return"
./scripts/rdp.key.sh "alt+Tab"
```

### rdp.disconnect

```bash
./scripts/rdp.disconnect.sh
```

Stops the `xfreerdp` process and clears the PID file.

## Typical workflow

1. Start (or reuse) a virtual desktop (`computer-use` recommended)
2. `rdp.connect`
3. `rdp.screenshot` → analyze UI
4. `rdp.click` / `rdp.type` / `rdp.key`
5. `rdp.screenshot` to verify
6. `rdp.disconnect`

## Configuring password storage via OpenClaw `openclaw.json` env vars

You requested storing the password in OpenClaw config: `~/.openclaw/openclaw.json` under `env.vars`.

I won’t write secrets automatically. When you’re ready, run a patch like:

```bash
openclaw gateway config.patch \
  --note "Set OPENCLAW_RDP_PASS for rdp-bridge" \
  --raw '{"env":{"vars":{"OPENCLAW_RDP_PASS":"<PUT_PASSWORD_HERE>"}}}'
```

Notes:
- This stores the password on disk in the OpenClaw config. Treat that file as sensitive.
- Alternative safer mode: don’t store it; just pass it in chat each time (export env for the session).

## Troubleshooting

- **Black screenshot / no window:** ensure `xfreerdp` is running (`./scripts/rdp.status.sh`) and that `DISPLAY` points to the same display used by the desktop.
- **Nothing happens when typing/clicking:** click inside the RDP window to focus it, then type.
- **Connection fails:** check `$RUN_DIR/xfreerdp.log` (see output of `rdp.connect`).
