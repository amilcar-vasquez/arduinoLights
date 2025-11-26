# arduinoLights

Short description

- Small Arduino sketch (`changingLights.ino`) to drive 8 LEDs and cycle through several lighting patterns (modes) with a single button.

Features / Modes

- Mode 0 — Knight Rider: a single LED sweeps left-to-right and back.
- Mode 1 — Chase (accumulating): LEDs turn on one-by-one until all are lit, then clear.
- Mode 2 — Blink All: all LEDs blink together.
- Mode 3 — Odd/Even: alternates odd and even LED positions.

Pin mapping

- LEDs: `ledPins[0..7]` = Arduino pins `2,3,4,5,6,7,8,9` respectively. Bit 0 (LSB) maps to `ledPins[0]` (pin 2), bit 7 (MSB) maps to `ledPins[7]` (pin 9).
- Button: `buttonPin` = pin `10` (configured as `INPUT_PULLUP`, active LOW). Pressing the button advances the `mode` (with debounce and wait-for-release).

Implementation notes

- `writePort(unsigned char value)` shifts out the low 8 bits and writes each bit to the corresponding LED pin.
- Timing is controlled by helper functions: `delay_short()` (150 ms), `delay_chase()` (100 ms), and `delay_blink()` (500 ms). Change these values to speed up/slow down effects.
- `check_button()` debounces the button (30 ms) and waits for release to avoid multiple mode steps per press.

How to build / upload

- If you have an upload script in the repo, run:

```bash
./upload.sh
```

- Or open `changingLights.ino` in the Arduino IDE and upload to your board.

Quick tweaks

- Reverse LED bit order: modify `writePort()` indexing or reorder `ledPins` if your physical wiring doesn't match the logical bit ordering.
- Change counter direction: in Mode 3 replace `writePort(~i);` with `writePort(i);` to show ascending binary.
- Make delays configurable: replace hard-coded values with `const` or `#define` constants at the top for easier tuning.

File references

- `changingLights.ino` — main sketch containing all modes and helper functions.
- `upload.sh` — (if present) helper script to upload the sketch from the command line.