#!/usr/bin/env bash
# Base setup for the Radxa Cubie A7Z night-sky camera.
# RUN THIS ON THE BOARD (not on the Mac, not in the cloud session).
set -euo pipefail

echo "== Cubie A7Z base setup =="
echo "Kernel: $(uname -r)   Arch: $(uname -m)"

echo "== Updating system =="
sudo apt-get update
sudo apt-get -y full-upgrade

echo "== Installing base tools + capture toolchain =="
sudo apt-get install -y \
  git vim htop i2c-tools v4l-utils \
  libcamera-apps libcamera-tools || \
  echo "NOTE: libcamera-apps may differ on Radxa's image; check 'apt search libcamera' / 'rpicam'."

echo "== Enabling SSH =="
sudo systemctl enable --now ssh || true

echo "== Camera / MIPI CSI state =="
echo "-- Active device-tree overlays (/boot/dtbo present? which enabled?):"
ls -1 /boot/dtbo 2>/dev/null || echo "  (no /boot/dtbo dir)"
echo "-- v4l2 devices:"
v4l2-ctl --list-devices 2>/dev/null || echo "  (none detected — camera overlay not enabled / no driver)"
echo "-- media controller topology:"
for m in /dev/media*; do
  [ -e "$m" ] && { echo "  $m:"; media-ctl -d "$m" -p 2>/dev/null | sed 's/^/    /'; }
done
echo "-- I2C buses (sensor should ACK on the CSI bus once powered):"
ls /dev/i2c-* 2>/dev/null || true

cat <<'EOF'

Next: enable the CSI camera overlay with `sudo rsetup` (Overlays / Camera),
reboot, and re-run the camera-state section above. For the IMX585 specifically,
see docs/camera-imx585-bringup.md — a driver port is required; no stock overlay
exists for the A733.
EOF
