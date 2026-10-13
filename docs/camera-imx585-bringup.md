# 3. Camera bring-up (IMX585 on Allwinner A733)

## 3.1 Read this first: sensor choice

You mentioned an **IMX586** (48 MP phone sensor, Quad-Bayer, ~0.8 µm pixels).
For night sky that's a poor fit: tiny pixels + Quad-Bayer = weak low-light
performance and awkward raw handling. Will Whang's camera uses the **IMX585**
(Sony STARVIS 2, 1/1.2", 8 MP, ~2.9 µm pixels) precisely because big pixels and
low read noise matter far more than megapixel count for faint stars.

The 22-pin FPC + Radxa 31→22 adapter you have matches the StarlightEye/IMX585
form factor. **Strong recommendation: build around the IMX585**, not the 586.
If you genuinely want 48 MP, know you're trading away the thing that makes
night-sky imaging work.

## 3.2 The hard truth about drivers

There is **no IMX585 driver or device-tree overlay for the A733** today.
Radxa's A733 kernel ships overlays only for *their* camera modules:

- Radxa Camera 8M 219 (Sony **IMX219**) — overlay `/boot/dtbo/*radxa-camera-8m-219.dtbo`
- Radxa Camera 4K

So bringing up the IMX585 is a **kernel porting task**, not a config toggle:

1. **Port the IMX585 V4L2 subdev driver** into Radxa's kernel tree
   (source of truth: Will Whang's `will127534/StarlightEye` driver, written for
   the Raspberry Pi kernel — needs adapting to Radxa's 6.6 kernel + Allwinner
   CSI/ISP, not drop-in).
2. **Write a device-tree overlay** binding the sensor to the A733's MIPI CSI
   receiver + ISP, with the right lane count (4-lane), I2C bus/address, clocks,
   and regulators.
3. **Clocks matter on this SoC**: the existing IMX219 overlay only worked after
   dropping CSI/ISP clocks — Android used 704 MHz but Linux needed ~360/300 MHz
   to stop `frame error! width is 0`. Reference:
   https://github.com/radxa-build/radxa-a733/issues/39

## 3.3 De-risking plan (do this before porting)

**Prove the CSI pipeline with a sensor that already has a driver**, so you know
the cable/adapter/port/software all work before fighting the IMX585 port:

1. If you can get a **Radxa Camera 8M 219 (IMX219)**, enable it via
   `sudo rsetup` → Overlays, reboot, and confirm:
   ```bash
   v4l2-ctl --list-devices
   media-ctl -d /dev/media0 -p
   # capture a test frame (exact tool depends on image: rpicam-still / libcamera-still):
   libcamera-still -o /tmp/test.jpg   # or: rpicam-still -o /tmp/test.jpg
   ```
2. Once that works, you've validated the 4-lane CSI path. Then tackle the
   IMX585 driver port against the A733 bindings the IMX219 overlay reveals.

## 3.4 What I need from you to drive the port

- The board booted, on the network, SSH working (`radxa@<IP>`).
- Output of the camera-state section in `scripts/board-setup.sh`.
- Which Radxa image/kernel version you flashed (`uname -r`, `cat /etc/os-release`).
- Confirmation of sensor (IMX585 vs 586) and the sensor's I2C address if known.

With that, from a **local** Claude Code session on your Mac (which can SSH to
the board), we can: clone Radxa's kernel, add the IMX585 driver, author the
overlay, build, and test-capture — iterating on the clock values per issue #39.
