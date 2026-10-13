# 1. Flash Radxa OS to microSD (macOS)

The Cubie A7Z runs an Allwinner **A733** image. Use Radxa's official GPT system
image for the A733 family (works on the A7Z). microSD boot needs no SPI/NVMe
prep.

## 1.1 Download the image

Open the official download page and grab the latest **release** image
(filename starts with `r`; `t` = beta):

- https://docs.radxa.com/en/cubie/a7z/download

**Pick the Debian 11 CLI (R6) image, not KDE.** The A7Z is a headless camera
appliance — the CLI build is ~4 GB vs ~7 GB for KDE, boots faster, and wastes
no CPU/RAM on a desktop. (The English download page may only show KDE; the CLI
R6 image for SD/eMMC is listed on the same page's other locale / the
`radxa-a733` releases. Grab the CLI one.) It arrives as `*.img.xz`.

> **The A7Z has NO Ethernet** (Wi-Fi 6 only), so you must pre-configure Wi-Fi
> before first boot — see §1.4. This is why your earlier flash was invisible:
> Raspberry Pi Imager's Wi-Fi/SSH presets are ignored by Radxa images.

> Also note the two community Debian 12/13 builders in case you want a newer
> userland later: `github.com/cuihuir/radxa-a7z-debian12` and
> `github.com/dok2d/cubie-a7z-debian`. Start with the official image.

## 1.2 Flash it

**Easiest (GUI):** [balenaEtcher](https://etcher.balena.io/) — it reads
`.img.xz` directly (no manual extract), verifies after writing, and is the
method Radxa documents.

1. Insert the microSD (use a decent 32 GB+ A1/A2 card).
2. Open Etcher → *Flash from file* → select the `.img.xz`.
3. Select the SD card as target. **Double-check the device** — Etcher hides
   system disks, but confirm the size matches your card.
4. Flash + wait for validation.

**CLI alternative (dd):** only if you prefer it. Identify the disk first so you
don't overwrite the wrong one:

```bash
# BEFORE inserting the card, note the disk list:
diskutil list
# Insert the card, run again, find the NEW /dev/diskN (match by size):
diskutil list
# Unmount (not eject) that disk — replace N:
diskutil unmountDisk /dev/diskN
# Decompress and write to the RAW device (rdiskN = faster). Replace N and path:
xz -dc ~/Downloads/radxa-os-*.img.xz | sudo dd of=/dev/rdiskN bs=4m status=progress
sync
diskutil eject /dev/diskN
```

⚠️ `dd` to the wrong `/dev/diskN` wipes that disk irreversibly. If unsure, use
Etcher.

## 1.4 Pre-configure Wi-Fi (REQUIRED — no Ethernet on this board)

After flashing, the FAT **boot** partition mounts on your Mac as a drive. Drop a
`before.txt` there with one line (template in `boot/before.txt`):

```
connect_wi-fi YOUR_WIFI_SSID YOUR_WIFI_PASSWORD
```

- It runs **once** on first boot to join Wi-Fi, then deletes itself (to change
  the network later, reflash).
- **SSH is enabled by default** on a headless (no-display) boot, so once it's on
  Wi-Fi you can `ssh radxa@<ip>` straight away.
- Prefer a **space-free SSID/password** for this step; the parser is simple.

Or let the helper script flash **and** write this in one go:
`scripts/prepare-sdcard-macos.sh` (run on your Mac).

## 1.3 Boot

1. microSD into the A7Z.
2. Power via USB-C (use a supply that can deliver enough current; a weak
   charger causes brownout/boot loops).
3. First boot resizes the filesystem and can take a few minutes.

Next: `docs/first-boot.md`.
