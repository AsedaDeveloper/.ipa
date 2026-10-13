#!/usr/bin/env bash
# Flash the Radxa Cubie A7Z image to a microSD AND inject headless WiFi config.
#
# RUN THIS ON YOUR MAC (a local Claude Code session on the Mac, or by hand) —
# NOT in the cloud session, which cannot see the SD card.
#
# Usage:
#   ./prepare-sdcard-macos.sh /path/to/radxa-os-cli.img.xz "MyWiFiSSID" "MyWiFiPassword"
#
# It will: list disks, ask you to confirm the target, flash with dd, then write
# before.txt (WiFi) to the boot partition. SSH is on by default on headless boot.
set -euo pipefail

IMG="${1:?Usage: $0 <image.img[.xz]> <SSID> <PASSWORD>}"
SSID="${2:?Need WiFi SSID}"
PASS="${3:?Need WiFi password}"

[ -f "$IMG" ] || { echo "Image not found: $IMG"; exit 1; }

echo "== Disks BEFORE (note what's already here) =="
diskutil list
echo
read -r -p "Make sure the microSD is INSERTED, then press Enter..." _
echo "== Disks NOW — find your card by SIZE =="
diskutil list
echo
read -r -p "Enter the card's disk identifier (e.g. disk4, NO /dev/, NO partition s1): " DISK
DISK="${DISK#/dev/}"

echo
echo ">>> About to ERASE /dev/$DISK and write $IMG"
diskutil info "/dev/$DISK" | grep -E "Device / Media Name|Disk Size" || true
read -r -p "Type ERASE to confirm: " CONFIRM
[ "$CONFIRM" = "ERASE" ] || { echo "Aborted."; exit 1; }

echo "== Unmounting =="
diskutil unmountDisk "/dev/$DISK"

echo "== Flashing (this takes a few minutes) =="
case "$IMG" in
  *.xz) xz -dc "$IMG" | sudo dd of="/dev/r$DISK" bs=4m status=progress ;;
  *)    sudo dd if="$IMG" of="/dev/r$DISK" bs=4m status=progress ;;
esac
sync

echo "== Re-reading partitions =="
# Give macOS a moment to mount the FAT boot partition after flashing.
sleep 5
diskutil list "/dev/$DISK" || true

# Find the mounted FAT boot volume for this disk.
BOOT_MNT=""
for v in /Volumes/*; do
  src="$(diskutil info "$v" 2>/dev/null | awk -F: '/Part of Whole/{gsub(/ /,"",$2);print $2}')"
  [ "$src" = "$DISK" ] && BOOT_MNT="$v" && break
done

if [ -z "$BOOT_MNT" ]; then
  echo "!! Could not auto-find the boot volume. Mount it in Finder and copy"
  echo "   boot/before.txt there manually, then eject."
else
  echo "== Writing before.txt to $BOOT_MNT =="
  printf 'connect_wi-fi %s %s\n' "$SSID" "$PASS" > "$BOOT_MNT/before.txt"
  echo "   wrote: $BOOT_MNT/before.txt"
  sync
  diskutil eject "/dev/$DISK"
fi

cat <<EOF

Done. Now:
  1. microSD into the A7Z, power via a strong USB-C supply.
  2. Wait ~2-3 min for first boot (it resizes + joins WiFi).
  3. Find its IP on your router, or scan: 'arp -a' / your router's client list.
  4. SSH in (default user is usually radxa/radxa — confirm on the download page):
       ssh radxa@<BOARD_IP>
  5. Run scripts/board-setup.sh on the board.
EOF
