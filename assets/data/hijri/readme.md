# Hijri Date Offset Files

## Why this exists

Ekush Ponji computes Hijri dates using the **Umm al-Qura (UQ)** calendar —
the official Saudi Arabia standard used by every major Islamic app worldwide.

However, **Bangladesh** determines Hijri month starts by **actual moon
sighting**, which can fall 1–2 days later than the UQ astronomical calculation.
These JSON files correct the displayed date to match the
**GOB (Government of Bangladesh) gazette**.

---

## File structure

```
assets/data/hijri/
├── README.md       ← you are here
├── 2025.json       ← Hijri months whose UQ start falls in Gregorian 2025
├── 2026.json       ← Hijri months whose UQ start falls in Gregorian 2026
├── 2027.json       ← placeholder — fill after GOB gazette published
└── ...
```

One file per **Gregorian year**. Each file has up to 13 entries
(one per Hijri month that starts in that calendar year).

---

## How the offset works

For any Gregorian date `D`, the app:
1. Computes the UQ Hijri date for `D`
2. Finds which Hijri month's `uq_start ≤ D ≤ uq_end`
3. Adds `offset` to the UQ day number

```
displayed_hijri_day = uq_day + offset
```

| offset | meaning |
|--------|---------|
| `0`    | UQ and GOB agree — no correction needed |
| `-1`   | BD moon sighting 1 day later than UQ |
| `-2`   | BD moon sighting 2 days later than UQ (rare — happens when previous month also slipped) |

---

## Entry format

```json
{
  "hijri_month":      "1448/04",           ← Hijri year/month
  "hijri_month_name": "Rabi al-Thani",     ← for human reference only
  "uq_start":         "2026-09-12",        ← Gregorian date UQ month starts
  "uq_end":           "2026-10-11",        ← Gregorian date UQ month ends (inclusive)
  "gob_start":        "2026-09-14",        ← GOB gazette month start (null if unknown)
  "offset":           -2,                  ← applied to UQ day number
  "status":           "confirmed — GOB gazette 2026"
}
```

The app reads `uq_start`, `uq_end`, and `offset` only.
`hijri_month`, `hijri_month_name`, `gob_start`, and `status` are for
human reference and are ignored by the app.

---

## How to update each year

### Step 1 — Get UQ dates
Run this Python snippet (requires `hijridate` package):
```python
from hijridate import Hijri
year = 2027  # change to target Gregorian year
for hy in [1449, 1450]:
    for hm in range(1, 13):
        g = Hijri(hy, hm, 1).to_gregorian()
        if g.year == year:
            print(f"{hy}/{hm:02d} {g}")
```

### Step 2 — Get GOB dates
Download the annual gazette from:
https://cabinet.gov.bd  (search "সরকারি ছুটির তালিকা")

Look for the table of Hijri month start dates for each month.

### Step 3 — Compute offsets
```
offset = -(gob_start_gregorian - uq_start_gregorian).days
```
Example: UQ Sep 12, GOB Sep 14 → offset = -(14-12) = -2

### Step 4 — Edit the JSON file
- Fill in `gob_start` and `offset` for each entry
- Change `status` from `"placeholder"` to `"confirmed — GOB gazette YYYY"`
- Bump `version` by 1

### Step 5 — Push to GitHub
The app fetches current year + next year files on every launch.
No app update needed.

---

## Version field

Each file has its own `version` integer. The app only re-downloads a file
when the remote version is higher than the locally cached version.
**Always bump `version` when you edit a file, even for minor fixes.**

---

## Historical note

Files for past years should **never be deleted**. Users looking at
historical dates (e.g. "what was the Hijri date of Bangladesh's
independence day in 1971?") rely on the offset data being present.

Past years without GOB data (offset=0) simply display the UQ date,
which is still accurate to ±1 day and perfectly acceptable for
historical reference.