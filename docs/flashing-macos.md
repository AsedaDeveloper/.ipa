# 1. Flash Radxa OS to microSD (macOS)

The Cubie A7Z runs an Allwinner **A733** image. Use Radxa's official GPT system
image for the A733 family (works on the A7Z). microSD boot needs no SPI/NVMe
prep.

## 1.1 Download the image

Open the official download page and grab the latest **release** image
(filename starts with `r`; `t` = beta):

- https://docs.radxa.com/en/cubie/a7z/download

Pick a Debian build (KDE desktop, or a CLI/server build if you want it
headless). It arrives as `*.img.xz`.

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

## 1.3 Boot

1. microSD into the A7Z.
2. Power via USB-C (use a supply that can deliver enough current; a weak
   charger causes brownout/boot loops).
3. First boot resizes the filesystem and can take a few minutes.

Next: `docs/first-boot.md`.
