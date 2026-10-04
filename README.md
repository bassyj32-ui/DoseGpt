# DoseGPT

> ## ⚠️ Not clinically verified — do not use for real patient care
>
> Every dose in this app is **unverified**. `lib/data/meta.json` declares:
>
> ```
> "dataset_status": "UNVERIFIED — DO NOT USE FOR REAL PATIENT CARE UNTIL CLINICALLY SIGNED OFF"
> "reviewed_by": []
> ```
>
> `reviewed_by` is empty. No clinician has signed off on any of the 110 drug
> entries. **23 entries carry an explicit `VERIFY` marker** in their own
> citation text, including both deworming drugs, whose `source_name` reads
> *"VERIFY against Ethiopia's specific national deworming program schedule."*
>
> The app shows this warning on every result screen. Treat it as a
> **reference and teaching aid**, not as a source of truth. Every dose must
> be independently checked against a current national protocol or the WHO
> guideline before use with a patient.

---

Offline paediatric and adult dosing reference for Ethiopia, built by a
physician. Amharic illness names, English drug names, no account, no network
required.

## Why it is built this way

**The escalation decision is not made by a model, and cannot be.** That is the
central design constraint. A clinical reference that guesses is worse than one
that refuses, so:

- Doses come from **deterministic code over an explicit data table**, not a
  language model. Every number is reproducible and inspectable.
- When a patient falls outside a drug's safe range, the app **refers**. It
  never clamps to a "close enough" dose. Out-of-range is a valid, tested
  outcome — see `out-of-range results always carry a message`.
- Age is entered in whole months, so **age `0` means "not entered"**, not
  "newborn". An empty field stops the calculation and asks for input rather
  than dosing a patient of unknown age.

What the app is *not*: a diagnostic tool, a substitute for clinical judgement,
or a validated reference. It does not know a patient's diagnosis, allergies,
renal function, or the local formulary.

## What it covers

| | |
|---|---|
| Illnesses | 17 paediatric, 20 adult |
| Drug entries | 48 paediatric, 62 adult |
| Languages | Amharic illness names, English drug names |
| Platform | Android, iOS, Web (installable PWA) |

IV fluid support covers the four formulas a low-resource setting actually
needs — **Holliday-Segar 4-2-1** maintenance, **20 ml/kg** shock bolus,
deficit replacement by percent dehydration, and **Parkland** for burns.

## Install it

**Web (PWA)** — <https://dosegpt.vercel.app>

Installable from the browser: on Android, Chrome → *Add to Home screen*; on
iOS, Safari → *Share → Add to Home Screen*. Once installed it runs full-screen
and **works with no network at all** — the clinical data, both fonts, and the
app shell are all precached by the service worker.

Long-press the home screen icon for shortcuts straight to paediatric or adult
dosing.

**Android** — download the APK from the
[Actions run](https://github.com/bassyj32-ui/DoseGpt/actions/workflows/build-apk.yml)
(14-day retention).

## Running it

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

36 tests. The suite runs against the **real bundled dataset** rather than
hand-built fixtures, so it fails when the data drifts as well as when the code
does. The 4-2-1 rule is independently recomputed rather than copied from the
implementation, so a change to one does not silently pass the other.

Covered: the four IV formulas · weight and age band lookup · concentration
conversion and clamping · artesunate's step to 2.4 mg/kg at 20 kg · referential
behaviour · band-table contiguity · and a sweep asserting `calculate` never
throws for any bundled drug across 64 age/weight combinations.

CI runs `flutter analyze --fatal-infos` and `flutter test` on every push. Both
are currently green.

## Contributing

Clinical content changes need a named, qualified reviewer recorded in
`meta.json`. To mark the dataset verified:

1. Have a clinician review every entry in `lib/data/drugs.json` and
   `adult_drugs.json`.
2. Record the reviewer and date in `meta.json` → `reviewed_by` and
   `dataset_last_updated`.
3. Change `dataset_status` to reflect the actual state.
4. Remove the `VERIFY` markers from `source_name` / `source_detail` as each
   entry is confirmed.

Until step 2 is done, `test/dose_calculator_test.dart` will fail on
`no drug entry claims clinical sign-off` — by design.

## Known gaps

- Amharic drug names are absent (0 of 110). Illness names are complete.
- Drug search matches illness names only, not drug names or synonyms.
- The flow to a dose is six taps deep; no deep link from a search result.
- 69 raw `Color(0x…)` literals sit outside the design tokens in `app_theme.dart`.
- `assets/images/background/baby_photo.jpg` is 3585×5751 at 1.4 MB.

## Licence

MIT — see [LICENSE](LICENSE).

The underlying clinical guidance should stay attributable to WHO and the
Ethiopian Ministry of Health. Cite them; do not restate their protocols as this
app's own.