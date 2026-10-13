# .ipa — All-Sky / Sky-Tracking Camera

A night-sky camera built on a **Radxa Cubie A7Z** (Allwinner A733) with a
**Sony IMX-series** sensor on a custom C-mount lens, connected over the
board's 4-lane MIPI CSI via a Radxa 31-pin → 22-pin FPC adapter.

Goal: capture the night sky, detect/track stars and transient objects
(planets, meteors, satellites, asteroids), and use lucky-imaging / frame
stacking to build high-detail images of chosen targets.

## Hardware

| Part | Choice | Notes |
|------|--------|-------|
| Compute | Radxa Cubie A7Z (A733) | Octa-core A76/A55, 1× 4-lane MIPI CSI |
| Sensor | Sony IMX585 (recommended) / IMX586 (your current pick) | See `docs/camera-imx585-bringup.md` for the sensor trade-off |
| Lens | Custom C-mount (your 3D-printed mount) | Fixed focal length |
| Camera FPC | Radxa 31-pin → 22-pin adapter cable | 22-pin sensor side |
| Boot media | microSD | NVMe/UFS possible later via SPI firmware |

## Setup status

- [ ] 1. Flash Radxa OS to microSD — `docs/flashing-macos.md`
- [ ] 2. First boot + base config (SSH, update, hostname) — `scripts/board-setup.sh`
- [ ] 3. Bring up the camera (IMX585 driver port) — `docs/camera-imx585-bringup.md`
- [ ] 4. Capture pipeline (libcamera / rpicam-style)
- [ ] 5. Detection + tracking + stacking software

## Where things run

This repo is edited from a cloud Claude Code session that **cannot touch the
board or the SD card directly**. Physical steps (flashing, booting, SSHing to
the board) run on your Mac — see each doc for the exact commands.
