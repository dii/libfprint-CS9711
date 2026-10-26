#!/usr/bin/env python3
"""Turn a cs9711 debug log into one CSV row per frame comparison."""
import re
import sys

FRAME = re.compile(r"Frame (\d+) of this press differs from the last by ([\d.]+)")
STATS = re.compile(r"mean ([\d.]+) -> ([\d.]+), spread ([\d.]+) -> ([\d.]+), correlation ([-\d.]+)")

print("press,frame,change,mean_before,mean_after,spread_before,spread_after,correlation")
press, row = 0, None
for line in open(sys.argv[1], errors="replace"):
    m = FRAME.search(line)
    if m:
        if m.group(1) == "2":
            press += 1
        row = [str(press), m.group(1), m.group(2)]
        continue
    m = STATS.search(line)
    if m and row:
        print(",".join(row + list(m.groups())))
        row = None
