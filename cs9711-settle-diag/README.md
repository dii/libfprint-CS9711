# Settle diagnostics for PR #2 (not for merging)

How much two frames of a still finger differ varies between CS9711 units with the same USB ID. `collect.sh` measures it on your unit, so the numbers can be compared with other units.

It builds the driver with the settle threshold switched off, using the build-time overrides in the PR (`-DCS9711_SETTLE_MAD=-1 -DCS9711_SETTLE_MAX_FRAMES=40`), so every frame of a press is logged. It then runs two tests:

1. **still**: one finger held flat and still for about 15 seconds (40 frames);
2. **presses**: 15 ordinary presses, lifting fully each time.

```
cs9711-settle-diag/collect.sh            # writes cs9711-settle-diag/out/
```

The examples may save an image or a print (the fallback still submits a frame). Each test runs in a temporary folder that is deleted when it ends, so neither is kept. The examples need access to the USB device, so run it as root or add a udev rule. It needs meson, ninja, gcc and the libfprint build dependencies.

## Output

`still.csv` and `presses.csv` hold one row per frame: the press, the frame number, the mean absolute change from the frame before (what the settle check compares with 4.0), and why the frames differ: the mean (a change is a brightness shift), the spread (a change is a contrast change), and the correlation with the frame before (which ignores both). The logs hold no image data.

## Reference: one 2541:0236 unit (bcdDevice 2.00), 2026-10-26

| | change | mean | spread | correlation |
| --- | --- | --- | --- | --- |
| still, frames 3 to 40 | 0.5 to 1.0 | 118 drifting to 114 | 48.5 to 49.0 | 0.996 to 0.9999 |
| presses, landing (frame 1 to 2) | 10.1 to 25.7 | falls 9 to 19 | falls about 50 to 40 | 0.74 to 0.98 |
| presses, after landing | 1.1 to 5.9 | within 2 | steady | 0.986 to 0.9995 |
| presses, lifting | 70 to 112 | jumps to 166 to 215 | 7 to 75 | 0.04 to 0.33 |
