# 2. First boot + base configuration

## 2.1 Get a terminal on the board

Pick one:

- **Monitor + keyboard** on the board (micro-HDMI), open a terminal.
- **Serial console** (most reliable for headless bring-up): USB-UART adapter to
  the board's debug UART, then on your Mac:
  ```bash
  ls /dev/tty.usbserial-*        # find the adapter
  screen /dev/tty.usbserial-XXXX 1500000   # A733 debug UART is 1.5 Mbaud
  ```
- **SSH over your network** once it's on Wi-Fi/Ethernet (see 2.3).

Default Radxa login is usually `radxa` / `radxa` (or set via first-boot
wizard). Change the password immediately: `passwd`.

## 2.2 Run the base setup

Copy `scripts/board-setup.sh` onto the board and run it (it updates the system,
sets hostname, enables SSH, installs the capture toolchain, and prints the
camera/overlay state):

```bash
# from your Mac, once you know the board's IP (see 2.3):
scp scripts/board-setup.sh radxa@<BOARD_IP>:~
ssh radxa@<BOARD_IP> 'bash ~/board-setup.sh'
```

## 2.3 Networking

- Ethernet: plug in, it should DHCP. Find the IP from your router, or on the
  board: `ip -4 addr`.
- Wi-Fi via Radxa's tool:
  ```bash
  sudo nmcli dev wifi connect "<SSID>" password "<PASS>"
  ```
- Enable SSH (if not already): `sudo systemctl enable --now ssh`.

Give me the board's IP + confirm SSH works, and from a **local** Claude Code
session on your Mac I can drive the rest over SSH.

## 2.4 System config tool

Radxa ships `rsetup` for overlays, camera ports, and peripherals:

```bash
sudo rsetup
```

We'll use this in step 3 to enable the CSI camera overlay.
