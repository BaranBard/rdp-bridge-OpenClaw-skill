# rdp-bridge (OpenClaw skill)

View and control a **Windows desktop over RDP** from OpenClaw **without Docker**.

This skill launches **FreeRDP (`xfreerdp`)** inside a virtual X desktop (Xvfb). For input + screenshots it prefers to **reuse the `computer-use` skill’s display** (`DISPLAY=:99`) and delegates click/type/key/screenshot to `computer-use` scripts.

## What you get

- `rdp.connect` — connect to an RDP host (host/port/user are parameters)
- `rdp.status` — show current connection state
- `rdp.screenshot` — capture the current RDP desktop
- `rdp.click`, `rdp.type`, `rdp.key` — control the session (delegates to `computer-use`)
- `rdp.disconnect` — stop the RDP client

Security defaults (per request):
- **Clipboard sharing disabled**.
- **No audio forwarding**.
- **No drive mapping**.

## Install prerequisites (Ubuntu/Debian / WSL)

```bash
sudo apt update
sudo apt install -y freerdp2-x11 xvfb x11-utils openbox xdotool imagemagick
```

Also install/setup the `computer-use` skill if you want full control (recommended).

## Usage

```bash
cd skills/rdp-bridge

# Provide password via env (recommended). Do NOT commit secrets.
export OPENCLAW_RDP_PASS='***'

./scripts/rdp.connect.sh 192.168.88.60 3389 baranbard
./scripts/rdp.screenshot.sh > shot.b64
./scripts/rdp.click.sh 512 384 left
./scripts/rdp.type.sh "hello"
./scripts/rdp.key.sh "Return"
./scripts/rdp.disconnect.sh
```

See `SKILL.md` for full docs and OpenClaw config env-var example.

## Notes

- The password is **not stored** by the repo; it is read from `OPENCLAW_RDP_PASS` or requested interactively.
- FreeRDP receives the password via `/p:` flag; on multi-user Linux hosts other users could potentially see process args. Prefer a single-user environment.
