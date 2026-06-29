# ZMK Controller Pad: Getting Started

This guide documents the hardware, wiring, firmware build, and flashing process for the ZMK Controller Pad.

## Project Summary

ZMK Controller Pad is a Bluetooth HID media controller made from common modules:

- Pro Micro nRF52840 board compatible with nice!nano.
- Two HW-040 / KY-040 rotary encoder modules.
- ZMK firmware.
- UF2 bootloader flashing.

The goal is to keep the build easy to reproduce with inexpensive parts and no custom PCB.

## Controls

| Control | Action |
| --- | --- |
| Volume encoder clockwise | Volume up |
| Volume encoder counterclockwise | Volume down |
| Volume encoder press | Mute/unmute |
| Track encoder clockwise | Next track |
| Track encoder counterclockwise | Previous track |
| Track encoder press | Play/pause |

## Hardware

Required:

- Pro Micro nRF52840 compatible with nice!nano.
- Two HW-040 / KY-040 rotary encoder modules.
- One normally-open momentary pushbutton for reset.
- USB-C data cable.
- Wires.

Optional:

- LiPo 1S battery.
- Battery holder.
- Charging or boost module, depending on your board and enclosure.
- 3D printed case or mounting plate.

## Power Notes

For development, power the board through USB-C.

The encoder modules should be powered from 3.3 V:

```text
+   -> VCC / VDD 3.3 V
GND -> GND
```

Do not connect 5 V to `VCC` / `VDD`.

If your board has `B+` and `B-`, it likely supports a LiPo 1S connection. If your battery does not include protection, use a protected cell or an appropriate battery protection/charging board.

## Wiring

Volume encoder:

| HW-040 / KY-040 | Pro Micro nRF52840 |
| --- | --- |
| `GND` | `GND` |
| `+` | `VCC` / `VDD` 3.3 V |
| `CLK` | `029` |
| `DT` | `031` |
| `SW` | `002` |

Track encoder:

| HW-040 / KY-040 | Pro Micro nRF52840 |
| --- | --- |
| `GND` | `GND` |
| `+` | `VCC` / `VDD` 3.3 V |
| `CLK` | `006` |
| `DT` | `008` |
| `SW` | `009` |

Reset button:

```text
RST -> momentary button -> GND
```

## Firmware Files

- `config/zmk_controller_pad.conf`: Bluetooth name and ZMK options.
- `config/zmk_controller_pad.keymap`: encoder and button actions.
- `boards/shields/zmk_controller_pad/zmk_controller_pad.overlay`: GPIO wiring.
- `boards/shields/zmk_controller_pad/zmk_controller_pad.zmk.yml`: shield metadata.
- `build.yaml`: default board/shield build matrix.

## Local Build

This repository builds locally using Docker and the official ZMK build image.

Requirements:

- Docker installed and running.
- Git available in the terminal.

Build:

```bash
./scripts/build-local.sh
```

Output:

```text
firmware/zmk_controller_pad.uf2
```

Override the board if needed:

```bash
BOARD=nice_nano_v2 ./scripts/build-local.sh
```

## Flashing

1. Connect the board by USB.
2. Double-tap reset.
3. Wait for the bootloader drive, usually `NICENANO` or `NRF52BOOT`.
4. Run:

```bash
./scripts/flash-local.sh
```

The script copies the UF2 file to the bootloader volume. The board should reboot automatically.

## Bluetooth Pairing

1. Open Bluetooth settings on macOS, Windows, Linux, iOS, or Android.
2. Search for `ZMK Ctrl Pad`.
3. Pair it as a keyboard/HID device.

If the host previously paired the board under another name, remove the old pairing first.

## Bluetooth Reliability

The default firmware disables ZMK deep sleep:

```conf
CONFIG_ZMK_SLEEP=n
```

This keeps the Bluetooth HID connection responsive after idle periods. It also avoids the failure mode where the host still lists the controller as paired or connected, but the next encoder movement or button press does not send media keys.

The button scan node is also marked as a wake source in the shield overlay. That keeps the configuration compatible with future sleep experiments, but the public default favors reliable reconnect behavior over maximum battery life.

## Adjustments

Invert volume direction in `config/zmk_controller_pad.keymap`:

```dts
<&inc_dec_kp C_VOL_DN C_VOL_UP>
```

Invert it back:

```dts
<&inc_dec_kp C_VOL_UP C_VOL_DN>
```

If either encoder is reversed, you can also swap its `CLK` and `DT` wires.

## Troubleshooting

No bootloader drive appears:

- Confirm the reset button connects `RST` to `GND`.
- Double-tap reset quickly.
- Use a USB-C cable that supports data.
- Try another USB port.

Encoder does not respond:

- Confirm `+` is connected to 3.3 V.
- Confirm all grounds are common.
- Confirm `CLK`, `DT`, and `SW` match the pin table.

Bluetooth name does not update:

- Remove the old Bluetooth pairing on the host.
- Reboot the controller.
- Pair again.

The project name is `ZMK Controller Pad`, but the Bluetooth name is `ZMK Ctrl Pad` because ZMK limits BLE device names to 16 characters.
