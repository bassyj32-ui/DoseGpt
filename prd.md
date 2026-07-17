DoseGPT — Master Product Requirements Document (MVP1, Complete)

Status of this document: This is the single, complete, self-contained brief for building DoseGPT MVP1. It includes the product definition, target user, full clinical scope, data schema, the actual dataset (embedded in full at the end), the design system, project structure, and build order — everything needed to build without needing to reference a separate file. Paste this whole document to the AI coder.

⚠️ Clinical data status: The dataset embedded in this document is a DRAFT and clinically UNVERIFIED. Every drug entry with "VERIFY" or "verified\_by": "PENDING" requires sign-off from a licensed clinician before this app reaches a real patient or nurse. The coder should build the full app against this data now — the app's logic and UI do not change once real values replace placeholders — but this must not be treated as medically final.

1\. Product overview

One-line pitch: An offline, illness-first pediatric dosing tool for Ethiopian nurses and health officers — Flutter, Android-only, designed so a low-literacy, non-recently-trained user can get a safe, correct, prescription-ready dose in seconds.

Problem: Rural Ethiopian health facilities are staffed largely by nurses and health officers, not doctors, due to severe physician shortages. Pediatric dosing math (mg/kg, weight bands, age bands) done manually under time pressure is a common source of error. Existing dosing apps (Pediatric Rx Dose Calculator, PediQuikCalc, etc.) are built for pediatricians who already know pharmacology — search-box-driven, drug-first, text-heavy, and designed for depth (80+ drugs, extra calculators) rather than speed and accessibility for a frontline, low-literacy user.

Positioning: the stripped-down, illness-first, low-literacy-friendly version for frontline Ethiopian health workers. A narrow, deliberate niche — not a feature-for-feature clone of existing dosing apps.

2\. Target user (design anchor — every decision traces back to this)

A \~50-year-old nurse, roughly a decade removed from formal training, using her own smartphone or a borrowed coworker's. Simplicity is the top-priority constraint on every decision. In practice:

Large tap targets, icon-first, minimal reading required

No menu nested more than one level deep

Nothing that requires remembering a previous screen's state

When in doubt between "simpler" and "more capable," choose simpler

3\. Core principles (non-negotiable)

Deterministic, not generative. No dose is ever computed live by an AI model. All doses come from the hard-coded, versioned dataset embedded in Section 9.

Offline-first, Android-only, Flutter. Entire dataset ships bundled in the app as local JSON. No login, no server dependency.

Calculation hidden by default. Result screen shows only the final, practical dose. A "Show calculation" tap reveals the formula for users who want to verify.

Hard safety caps. Max-dose ceilings enforced regardless of weight entered.

Practical, not raw, doses. Doses are rounded to measurable increments (e.g. nearest 0.5ml) and displayed as a complete prescription-style line — drug, dose, frequency, duration — never a bare decimal.

Sourced, but out of the way. Every entry cites its protocol source; full citations live on a separate Reference page (stubbed in MVP1), not inline in the main flow.

Uniform components. One shared component library — every screen composed from the same building blocks, not styled individually.

Universal edge-case rule. Any weight entry that is blank, zero, outside a drug's valid range, OR any calculation that would require a null/missing data field, must show one consistent message and no calculated result:

"This weight is outside the safe range for this calculation. Please double-check the weight or consult a colleague/refer the patient."

This applies to every currently-unverified entry in the dataset, not just literal out-of-weight-range cases — never display "0", "null", or a guessed number under any circumstance.

Scope discipline. 10 illnesses, 2–3 drug options each, English only for MVP1. Every addition is a clinical review burden, not just a feature.

Disclaimers, not gates. The app clearly states it is an assistive tool, not a replacement for clinical judgment — once on first launch, and briefly on every Result screen. Neither disclaimer adds a step to the core dosing flow (see Section 5A and 5B).

Age is a hard safety input, not just weight. Some drugs are contraindicated by age regardless of weight (Ibuprofen <3 months, Primaquine <6 months, Albendazole age-banded). Neonatal cases (approx. <1 month, VERIFY exact cutoff) are excluded universally, for every illness, before a drug is even shown — neonatal illness needs fundamentally different management than this dataset covers. Age is therefore collected alongside weight on every calculation (see Section 5C).

4\. Language scope

English only for MVP1. The data schema reserves \_am fields (e.g. name\_am) for future use — currently empty. No language-selection screen exists in MVP1; app opens directly to Home in English.

5\. App structure & navigation

Screens:

0\. First-launch disclaimer — shown exactly once, ever (see 5A)

Home — scrollable list of illness cards, ordered by display\_order (clinical burden/danger, not alphabetical)

Age + Weight entry — age (years + months) and weight input together; concentration selection shown when the selected drug has multiple concentrations

Result — practical, prescription-style dose line; calculation hidden by default behind a "Show calculation" toggle; carries a small persistent disclaimer line (see 5B)

Reference — stubbed as "Coming soon" in MVP1

Navigation: persistent Home + Reference bottom nav from anywhere. Tapping Home always returns to the illness list directly.

Component reuse rule: build shared components first (card, button, header) and compose every screen from them.

5A. First-launch disclaimer (one-time)

Shown as a full screen only on the very first app open, ever — a single "I Understand / Continue" button dismisses it and writes a local flag (e.g. hasSeenDisclaimer: true, stored via SharedPreferences or equivalent local storage) so it never appears again on subsequent opens

After dismissal, the app proceeds directly to Home — no other onboarding, no additional screens

Exact copy:

"DoseGPT assists dosing calculations. It does not replace clinical judgment. Always verify the patient's diagnosis and contraindications before administering."

Styling: centered text, ink color on surface background, single primary-colored button, matches the calm/uncluttered tone of the rest of the app — not an aggressive legal-modal look

5B. Per-result disclaimer (persistent, small)

Appears on every Result screen, beneath the dose and formula area, styled small and muted (ink-muted, 13px, matching the "formula/source" type scale tier) — must never compete visually with the hero dose number

Exact copy:

"Assistive tool only — verify diagnosis and contraindications."

No dismiss action needed — it's a passive, always-visible line, not a modal or interruption. Does not add a tap or a step to the flow.

5C. Age + Weight entry (replaces weight-only entry)

Input fields: Age as Years + Months (two small numeric fields or steppers, not a single free-typed months count) alongside the existing Weight field. Matches how nurses already record age on charts — faster and less error-prone than typing total months.

Universal neonatal gate (checked first, before anything else on this screen proceeds): if age indicates a neonate (approx. <1 month — VERIFY exact cutoff against Ethiopian STG before finalizing), the app shows a hard referral message and does not proceed to any drug or dose, regardless of which illness was selected:

"This app is not designed for newborns. Please refer to a physician immediately."

This is illness-independent — it fires the same way whether the entry point was Malaria, Pneumonia, or anything else.

Per-drug age gating: once past the neonatal gate, age is checked against each drug's valid\_age\_range (already present in the schema for Ibuprofen ≥3 months, Primaquine ≥6 months; Albendazole/Mebendazole use age as their primary age\_band lookup rather than a gate). If age falls outside a specific drug's valid range, that drug is not offered as a selectable option for this calculation — the recommended alternative (if one exists, via penicillin\_allergy\_alternative or similar cross-reference) is shown instead, or the universal out-of-range message is shown if no valid alternative exists.

Relationship to the existing weight-only edge-case rule (Section 3, item 8): unchanged and still applies independently — a blank/zero/out-of-range weight still triggers its own message. Age and weight are checked as two independent gates, not combined into one condition.

6\. Clinical scope summary (see Section 9 for the full dataset)

\#

Illness

Drug(s)

Dosing shape

1

Malaria

Artemether-Lumefantrine (first-line); Chloroquine + Primaquine (P. vivax)

weight\_band; mg\_per\_kg

2

Pneumonia

Amoxicillin (first-line); Azithromycin, Augmentin (alt.)

mg\_per\_kg

3

Diarrhea

Zinc; ORS (structural flag — needs dehydration sub-step)

age\_band; fixed (incomplete)

4

Fever/Pain

Paracetamol (first-line); Ibuprofen (alt.)

mg\_per\_kg

5

UTI

Cotrimoxazole (first-line); Amoxicillin (alt.)

mg\_per\_kg

6

Tonsillitis

Penicillin V (first-line, 10-day duration); Amoxicillin, Azithromycin (alt.)

mg\_per\_kg

7

Otitis Media

Amoxicillin (first-line); Azithromycin, Augmentin (alt.)

mg\_per\_kg

8

Asthma/Wheeze

Salbutamol (first-line); Prednisolone (add-on)

mg\_per\_kg

9

Impetigo/Skin Infection

Cloxacillin

mg\_per\_kg

10

Intestinal Worms

Albendazole (first-line); Mebendazole

age\_band

Removed from scope: Scabies, Conjunctivitis, Oral Thrush, Common Cold/supportive-care-only entries.

7\. Data schema (structure of Section 9's JSON)

No live server — an entirely local, versioned JSON dataset bundled at build time. All app logic reads from this data; no dose or formula is hardcoded into UI code.

Files: illnesses.json, drugs.json, meta.json — placed in lib/data/.

illnesses.json fields

id, name\_en (name\_am reserved, unused), icon, display\_order, urgent\_accent (bool — drives the red left-edge accent), drug\_ids (ordered, first = "Recommended")

drugs.json — shared fields on every entry

id, illness\_id, drug\_name\_en (drug\_name\_am reserved), drug\_synonyms, is\_recommended, combination\_drug, dosing\_shape (mg\_per\_kg | weight\_band | age\_band | fixed), frequency\_en, duration\_days, max\_daily\_dose\_mg, safety\_warning, valid\_weight\_range / valid\_age\_range, referral\_trigger\_text, penicillin\_allergy\_alternative, source\_name, source\_detail, last\_verified, verified\_by

Shape-specific fields

mg\_per\_kg: dose\_per\_kg\_mg (or dose\_schedule\[] for multi-day regimens like Azithromycin), concentrations\[]

weight\_band / age\_band: bands\[] of {min\_kg/min\_months, max\_kg/max\_months, dose\_display\_en}

fixed: dose\_display\_en

concentrations\[] (for mg\_per\_kg only)

label\_en, strength\_mg, volume\_ml, round\_to\_ml, min\_safe\_ml, max\_safe\_ml

Calculation logic (implemented in code, not data)

mg\_per\_kg: weight\_kg × dose\_per\_kg\_mg → convert to ml via chosen concentration → round to round\_to\_ml → clamp to min\_safe\_ml/max\_safe\_ml → check against max\_daily\_dose\_mg

weight\_band / age\_band: direct table lookup — bands are built with zero gaps so every valid input matches exactly one row

fixed: return dose\_display\_en directly

Any null critical field encountered at calculation time (e.g. dose\_per\_kg\_mg: null): treat identically to an out-of-range weight — show the standard refer-out message, never a fallback number

All shapes converge on one output line: drug\_name + dose + frequency + duration, prescription-style (e.g. "Amoxicillin 250mg/5ml syrup — give 5ml, twice daily, for 5 days")

8\. Design system

Visual direction: Apple-inspired restraint and polish, adjusted for a low-literacy, bright-daylight, non-tech-fluent user — high contrast over subtlety, bigger tap targets than typical mobile defaults, icon+label always paired.

Color

Token

Hex

Use

primary

\#0B6E4F

Buttons, active states, header, primary accents

primary-dark

\#07543C

Pressed state

accent-gold

\#C98A1F

"Recommended" tag only — sparing use

urgent

\#B3402B

Reserved for urgent\_accent: true illness cards (Malaria, Pneumonia) only

ink

\#16211C

Primary text

ink-muted

\#5B6B62

Secondary text (formula, source citations)

surface

\#FFFFFF

Base background

surface-card

\#F4F6F5

Card backgrounds

border-hairline

\#E1E6E3

Dividers

Rule: one accent color does the work per screen — green = action, gold = recommended, red = pay attention. Never combine all three at equal weight.

Typography

Font: Inter or Manrope (clean geometric sans)

Type scale: dose result 48–56px bold; screen title 24px semibold; card label 16px semibold; body 16px regular; formula/source 13px regular, ink-muted

Layout

8px base spacing grid

Cards: fully rounded pill shape, surface-card background, soft shadow (0 2px 8px rgba(0,0,0,0.06)), 16–20px internal padding, icon left-aligned + name + chevron

Minimum tap target: 56px height on any interactive element

Iconography

Real illustrative images per illness (placeholder icons acceptable until provided — see icon field values in Section 9, e.g. icon\_mosquito, icon\_lungs), consistent frame size/shape across all cards, neutral background — color is never decorative

Malaria/Pneumonia cards only: thin urgent accent line on the card's left edge (driven by urgent\_accent: true in the data)

Motion

Minimal: subtle tap feedback (\~100–150ms), gentle screen transitions (\~200ms). No decorative animation.

Signature element

A practical-dose visual (illustrated syringe or spoon that visually fills to the measured line) on the Result screen.

Accessibility floor

Text contrast ≥4.5:1

All tap targets ≥56px

Must remain legible in bright outdoor daylight

Core flow must not require reading beyond illness/drug names

9A. Project structure

Code

9B. Build order (MVP1) — build in this exact sequence

Stage 0 — Project setup. Scaffold per structure above, add fonts, place the three JSON files (Section 10) into lib/data/, add preferences\_service.dart with a hasSeenDisclaimer boolean flag (default false, persisted locally). Done means: app builds and runs, blank screen, no crashes.

Stage 1 — Data layer. Build models/ and data\_loader.dart. Done means: app successfully loads and prints all 10 illnesses and every linked drug with zero parsing errors.

Stage 2 — Calculation engine. Build dose\_calculator.dart — one function per dosing\_shape, including rounding, clamping, and the universal edge-case rule (including the null-field rule from Section 7). Done means: hardcoded test calls return correct results for at least one case per shape, plus one deliberate out-of-range case, provable via console/unit test.

Stage 3 — Shared components. Build app\_theme.dart and all widgets/. Done means: a test screen renders each component matching the design system, visually confirmed on a real device.

Stage 4 — Home screen + first-launch disclaimer. Build disclaimer\_screen.dart (exact copy per Section 5A) as the app's entry point: on launch, check hasSeenDisclaimer — if false, show the disclaimer screen and set the flag to true on dismissal; if true, skip straight to Home. Build Home screen using Stage 3 components + Stage 1 data. Done means: first-ever launch shows the disclaimer exactly once; every subsequent launch (including app restart) goes straight to Home; all 10 cards render correctly ordered and styled; tapping doesn't crash.

Stage 5 — Age + Weight entry screen. Build weight\_entry\_screen.dart (renamed in function to Age + Weight entry per Section 5C) — Years/Months age input plus the existing weight input, concentration selection chips shown when applicable. Implement the universal neonatal gate first (checked before anything else on this screen can proceed), then per-drug valid\_age\_range filtering. Wired to Stage 2's calculation engine. Done means: entering age + weight (+ concentration if applicable) and pressing Calculate correctly triggers the calculator and passes a real result forward for at least Pneumonia end-to-end; a deliberately-entered neonatal age (e.g. 2 weeks) correctly blocks with the referral message regardless of illness selected; an age outside a specific drug's valid\_age\_range (e.g. 2-month-old + Ibuprofen) correctly excludes that drug rather than allowing a dose to be calculated.

Stage 6 — Result screen. Hero dose line, collapsed "Show calculation," dose visual, "New calculation" button, out-of-range handling, and the small persistent per-result disclaimer line (exact copy per Section 5B, always visible, no dismiss action). Done means: full Home → Weight → Result flow works for all 10 illnesses, including a deliberate out-of-range test per illness confirming the safety message displays instead of a guessed number, and the disclaimer line is present and correctly styled (muted, non-competing with the dose number) on every Result screen.

Stage 7 — Navigation & Reference stub. Bottom nav, "Coming soon" Reference screen. Done means: Home/Reference navigation works from any screen without crashing.

Stage 8 — Polish pass. Tap/transition animations, app icon/splash (once provided), real-device outdoor daylight contrast check. Done means: app feels calm, fast, legible outdoors, not just correct on an emulator.

Explicitly NOT part of MVP1: Reference content, Amharic content, final illness/drug images (placeholders OK), any clinical dataset correction (that's a separate human review pass, not a build task).

Standing rule for the coder throughout every stage: if the data doesn't fully support a case (a null field, an unverified entry), the app shows the universal out-of-range/refer message — never a crash, never "null," never "0."

10\. Full dataset (embedded in full below — this is the actual data to place in lib/data/)

The three JSON files below are the complete, current dataset. Copy each into its own file exactly as shown.

10.1 — illnesses.json

Json

\


{

  "illnesses": \[

    {

      "id": "malaria",

      "name\_en": "Malaria",

      "name\_am": "",

      "icon": "icon\_mosquito",

      "display\_order": 1,

      "urgent\_accent": true,

      "drug\_ids": \["al\_malaria", "chloroquine\_malaria", "primaquine\_malaria"]

    },

    {

      "id": "pneumonia",

      "name\_en": "Pneumonia",

      "name\_am": "",

      "icon": "icon\_lungs",

      "display\_order": 2,

      "urgent\_accent": true,

      "drug\_ids": \["amoxicillin\_pneumonia", "azithromycin\_pneumonia", "augmentin\_pneumonia"]

    },

    {

      "id": "diarrhea",

      "name\_en": "Diarrhea",

      "name\_am": "",

      "icon": "icon\_droplet",

      "display\_order": 3,

      "urgent\_accent": false,

      "drug\_ids": \["zinc\_diarrhea", "ors\_diarrhea"]

    },

    {

      "id": "fever",

      "name\_en": "Fever / Pain",

      "name\_am": "",

      "icon": "icon\_thermometer",

      "display\_order": 4,

      "urgent\_accent": false,

      "drug\_ids": \["paracetamol\_fever", "ibuprofen\_fever"]

    },

    {

      "id": "uti",

      "name\_en": "UTI",

      "name\_am": "",

      "icon": "icon\_kidney",

      "display\_order": 5,

      "urgent\_accent": false,

      "drug\_ids": \["cotrimoxazole\_uti", "amoxicillin\_uti"]

    },

    {

      "id": "tonsillitis",

      "name\_en": "Tonsillitis",

      "name\_am": "",

      "icon": "icon\_throat",

      "display\_order": 6,

      "urgent\_accent": false,

      "drug\_ids": \["penicillin\_v\_tonsillitis", "amoxicillin\_tonsillitis", "azithromycin\_tonsillitis"]

    },

    {

      "id": "otitis\_media",

      "name\_en": "Ear Infection",

      "name\_am": "",

      "icon": "icon\_ear",

      "display\_order": 7,

      "urgent\_accent": false,

      "drug\_ids": \["amoxicillin\_otitis", "azithromycin\_otitis", "augmentin\_otitis"]

    },

    {

      "id": "asthma",

      "name\_en": "Asthma / Wheeze",

      "name\_am": "",

      "icon": "icon\_inhaler",

      "display\_order": 8,

      "urgent\_accent": false,

      "drug\_ids": \["salbutamol\_asthma", "prednisolone\_asthma"]

    },

    {

      "id": "impetigo",

      "name\_en": "Skin Infection",

      "name\_am": "",

      "icon": "icon\_skin",

      "display\_order": 9,

      "urgent\_accent": false,

      "drug\_ids": \["cloxacillin\_impetigo"]

    },

    {

      "id": "worms",

      "name\_en": "Intestinal Worms",

      "name\_am": "",

      "icon": "icon\_worm",

      "display\_order": 10,

      "urgent\_accent": false,

      "drug\_ids": \["albendazole\_worms", "mebendazole\_worms"]

    }

  ]

}

\


10.2 — drugs.json

Json



{

  "\_status": "DRAFT — CLINICALLY UNVERIFIED. Every entry requires sign-off by a licensed clinician before use in a shipped app. Do not treat any value here as final.",

  "drugs": \[



    {

      "id": "al\_malaria",

      "illness\_id": "malaria",

      "drug\_name\_en": "Artemether-Lumefantrine (Coartem)",

      "drug\_name\_am": "",

      "drug\_synonyms": \["Coartem", "AL"],

      "is\_recommended": true,

      "combination\_drug": true,

      "dosing\_shape": "weight\_band",

      "frequency\_en": "twice daily (0h and 8h on day 1, then morning/evening days 2-3)",

      "duration\_days": 3,

      "max\_daily\_dose\_mg": null,

      "valid\_weight\_range": { "min\_kg": 5, "max\_kg": null },

      "referral\_trigger\_text": "Below 5kg or under 2 months old: do not dose, refer immediately.",

      "bands": \[

        { "min\_kg": 5, "max\_kg": 14, "dose\_display\_en": "1 tablet per dose" },

        { "min\_kg": 15, "max\_kg": 24, "dose\_display\_en": "2 tablets per dose" },

        { "min\_kg": 25, "max\_kg": 34, "dose\_display\_en": "3 tablets per dose" },

        { "min\_kg": 35, "max\_kg": null, "dose\_display\_en": "4 tablets per dose" }

      ],

      "safety\_warning": null,

      "source\_name": "WHO Malaria Treatment Guidelines",

      "source\_detail": "VERIFY against current Ethiopia National Malaria Guideline edition",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "chloroquine\_malaria",

      "illness\_id": "malaria",

      "drug\_name\_en": "Chloroquine",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": true,

      "dosing\_shape": "mg\_per\_kg",

      "notes": "Used for P. vivax malaria (with Primaquine below). Ethiopia has significant vivax burden alongside falciparum.",

      "dose\_schedule": \[

        { "day": 1, "dose\_per\_kg\_mg": 10 },

        { "day": 2, "dose\_per\_kg\_mg": 10 },

        { "day": 3, "dose\_per\_kg\_mg": 5 }

      ],

      "frequency\_en": "once daily",

      "duration\_days": 3,

      "max\_daily\_dose\_mg": null,

      "concentrations": \[

        { "label\_en": "VERIFY local syrup/tablet strength", "strength\_mg": null, "volume\_ml": null, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "valid\_weight\_range": { "min\_kg": null, "max\_kg": null },

      "safety\_warning": null,

      "source\_name": "Confirmed against Ethiopian National Malaria Guideline (Northwest Ethiopia therapeutic efficacy study)",

      "source\_detail": "25mg base/kg total over 3 days (10/10/5mg/kg)",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "primaquine\_malaria",

      "illness\_id": "malaria",

      "drug\_name\_en": "Primaquine (radical cure)",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": true,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": 0.25,

      "frequency\_en": "once daily",

      "duration\_days": 14,

      "max\_daily\_dose\_mg": null,

      "concentrations": \[

        {

          "label\_en": "7.5mg tablet",

          "strength\_mg": 7.5,

          "volume\_ml": null,

          "round\_to\_tablet": 0.25,

          "practical\_bands\_DRAFT": \[

            { "min\_kg": 8, "max\_kg": 16, "dose\_display\_en": "1/2 tablet (3.75mg) daily" },

            { "min\_kg": 17, "max\_kg": 40, "dose\_display\_en": "1 tablet (7.5mg) daily" }

          ]

        }

      ],

      "valid\_weight\_range": { "min\_kg": 8, "max\_kg": null },

      "valid\_age\_range": { "min\_months": 6, "max\_months": null },

      "safety\_warning": "Primaquine can cause dangerous hemolysis (red blood cell breakdown) in patients with G6PD deficiency. VERIFY current Ethiopian protocol on G6PD testing requirement before dosing at this facility level. Do not dispense without confirming this.",

      "source\_name": "Ethiopia national low-dose radical cure protocol (rolled out nationally 2018)",

      "source\_detail": "Tablet-band practicality table is DRAFT, adapted from a regional study — VERIFY against current Ethiopia FMOH Malaria Guideline tablet-banding chart specifically",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "amoxicillin\_pneumonia",

      "illness\_id": "pneumonia",

      "drug\_name\_en": "Amoxicillin",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": true,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": 40,

      "frequency\_en": "twice daily",

      "duration\_days": 5,

      "max\_daily\_dose\_mg": null,

      "concentrations": \[

        { "label\_en": "125mg/5ml", "strength\_mg": 125, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 },

        { "label\_en": "250mg/5ml", "strength\_mg": 250, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 }

      ],

      "valid\_weight\_range": { "min\_kg": 2, "max\_kg": null },

      "penicillin\_allergy\_alternative": \["azithromycin\_pneumonia"],

      "safety\_warning": null,

      "source\_name": "WHO pneumonia treatment guideline (recent revision)",

      "source\_detail": "This dose (40mg/kg/dose) is HIGHER than older references (25mg/kg) still in circulation. VERIFY current Ethiopia STG reflects the updated figure, and VERIFY duration (5 vs 3 days per local HIV prevalence guidance).",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "azithromycin\_pneumonia",

      "illness\_id": "pneumonia",

      "drug\_name\_en": "Azithromycin",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_schedule": \[

        { "day": 1, "dose\_per\_kg\_mg": 10, "max\_dose\_mg": 500 },

        { "day": "2-5", "dose\_per\_kg\_mg": 5, "max\_dose\_mg": 250 }

      ],

      "frequency\_en": "once daily",

      "duration\_days": 5,

      "max\_daily\_dose\_mg": 500,

      "concentrations": \[

        { "label\_en": "VERIFY local syrup strength (commonly 100mg/5ml or 200mg/5ml)", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "valid\_weight\_range": { "min\_kg": null, "max\_kg": null },

      "safety\_warning": null,

      "source\_name": "Standard pediatric CAP guidance",

      "source\_detail": "Widely consistent across references",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "augmentin\_pneumonia",

      "illness\_id": "pneumonia",

      "drug\_name\_en": "Amoxicillin-Clavulanate (Augmentin)",

      "drug\_name\_am": "",

      "drug\_synonyms": \["Augmentin"],

      "is\_recommended": false,

      "combination\_drug": true,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": null,

      "notes": "Dosed on the amoxicillin component. Regimens range 20-45mg/kg/dose twice daily depending on the amoxicillin:clavulanate ratio of the specific syrup stocked. This entry is HIGH PRIORITY to verify — wrong ratio assumption is a real mis-dose risk.",

      "frequency\_en": "twice daily",

      "duration\_days": 5,

      "max\_daily\_dose\_mg": null,

      "concentrations": \[

        { "label\_en": "VERIFY — e.g. 125mg/31.25mg per 5ml", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null },

        { "label\_en": "VERIFY — e.g. 200mg/28.5mg per 5ml", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "valid\_weight\_range": { "min\_kg": null, "max\_kg": null },

      "safety\_warning": null,

      "source\_name": "VERIFY against specific product available in Ethiopian pharmacies",

      "source\_detail": "Do not finalize without confirming exact locally-stocked formulation ratio",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "zinc\_diarrhea",

      "illness\_id": "diarrhea",

      "drug\_name\_en": "Zinc",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": true,

      "combination\_drug": false,

      "dosing\_shape": "age\_band",

      "frequency\_en": "once daily",

      "duration\_days": 12,

      "max\_daily\_dose\_mg": null,

      "bands": \[

        { "min\_months": 0, "max\_months": 5, "dose\_display\_en": "10mg once daily for 10-14 days" },

        { "min\_months": 6, "max\_months": null, "dose\_display\_en": "20mg once daily for 10-14 days" }

      ],

      "safety\_warning": null,

      "source\_name": "WHO/UNICEF diarrhea management guideline",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "ors\_diarrhea",

      "illness\_id": "diarrhea",

      "drug\_name\_en": "ORS (Oral Rehydration Solution)",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": true,

      "combination\_drug": false,

      "dosing\_shape": "fixed",

      "dose\_display\_en": "STRUCTURAL FLAG: ORS volume depends on dehydration status (plan A/B/C), not weight alone. This entry needs a dehydration-assessment sub-step designed before finalizing — do not ship as a single fixed number.",

      "frequency\_en": null,

      "duration\_days": null,

      "safety\_warning": null,

      "source\_name": "WHO/UNICEF diarrhea management guideline",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required, structural design decision needed"

    },



    {

      "id": "paracetamol\_fever",

      "illness\_id": "fever",

      "drug\_name\_en": "Paracetamol",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": true,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": 15,

      "frequency\_en": "every 4-6 hours as needed",

      "duration\_days": null,

      "max\_daily\_dose\_mg": null,

      "concentrations": \[

        { "label\_en": "120mg/5ml", "strength\_mg": 120, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 },

        { "label\_en": "250mg/5ml", "strength\_mg": 250, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 }

      ],

      "valid\_weight\_range": { "min\_kg": 2, "max\_kg": null },

      "safety\_warning": null,

      "source\_name": "WHO / standard pediatric reference",

      "source\_detail": "VERIFY max daily dose cap (commonly \~60mg/kg/day)",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "ibuprofen\_fever",

      "illness\_id": "fever",

      "drug\_name\_en": "Ibuprofen",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": 7.5,

      "notes": "Range 5-10mg/kg/dose; 7.5 used as a practical midpoint — VERIFY preferred figure",

      "frequency\_en": "every 6-8 hours",

      "duration\_days": null,

      "max\_daily\_dose\_mg": null,

      "max\_daily\_dose\_per\_kg\_mg": 30,

      "concentrations": \[

        { "label\_en": "100mg/5ml", "strength\_mg": 100, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 15 }

      ],

      "valid\_age\_range": { "min\_months": 3, "max\_months": null },

      "referral\_trigger\_text": "Under 3 months old: do not use ibuprofen.",

      "safety\_warning": "Avoid in dehydration, suspected bleeding risk, or known kidney problems.",

      "source\_name": "MSF pediatric guideline",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "cotrimoxazole\_uti",

      "illness\_id": "uti",

      "drug\_name\_en": "Cotrimoxazole",

      "drug\_name\_am": "",

      "drug\_synonyms": \["Septrin", "Bactrim"],

      "is\_recommended": true,

      "combination\_drug": true,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": 4,

      "notes": "Dose expressed as the trimethoprim component — VERIFY, easy to mis-transcribe.",

      "frequency\_en": "twice daily",

      "duration\_days": null,

      "max\_daily\_dose\_mg": null,

      "concentrations": \[

        { "label\_en": "VERIFY — commonly 40mg/200mg per 5ml", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "valid\_weight\_range": { "min\_kg": null, "max\_kg": null },

      "safety\_warning": null,

      "source\_name": "VERIFY — this entry needs direct clinical input more than most",

      "source\_detail": "Duration commonly 5-7 days for uncomplicated UTI at this level of care — VERIFY",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "amoxicillin\_uti",

      "illness\_id": "uti",

      "drug\_name\_en": "Amoxicillin",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": null,

      "notes": "VERIFY — UTI dosing may differ from the pneumonia amoxicillin entry, do not assume identical.",

      "frequency\_en": "twice daily",

      "duration\_days": null,

      "concentrations": \[

        { "label\_en": "125mg/5ml", "strength\_mg": 125, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 },

        { "label\_en": "250mg/5ml", "strength\_mg": 250, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 }

      ],

      "safety\_warning": null,

      "source\_name": "VERIFY",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "penicillin\_v\_tonsillitis",

      "illness\_id": "tonsillitis",

      "drug\_name\_en": "Penicillin V",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": true,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": null,

      "notes": "VERIFY whether Ethiopia STG doses this as strict mg/kg or fixed mg by age band — do not assume mg/kg without checking.",

      "frequency\_en": "VERIFY (commonly 2-3 times daily)",

      "duration\_days": 10,

      "duration\_warning": "IMPORTANT: 10-day duration for strep eradication — do NOT default this to 5 days like the other antibiotics in this dataset. Flagged as a likely transcription error risk.",

      "concentrations": \[

        { "label\_en": "VERIFY local syrup strength", "strength\_mg": null, "volume\_ml": null, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "penicillin\_allergy\_alternative": \["azithromycin\_tonsillitis"],

      "safety\_warning": null,

      "source\_name": "VERIFY",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "amoxicillin\_tonsillitis",

      "illness\_id": "tonsillitis",

      "drug\_name\_en": "Amoxicillin",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": null,

      "notes": "VERIFY dose and duration for this indication specifically.",

      "frequency\_en": "twice daily",

      "duration\_days": 10,

      "concentrations": \[

        { "label\_en": "125mg/5ml", "strength\_mg": 125, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 },

        { "label\_en": "250mg/5ml", "strength\_mg": 250, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 }

      ],

      "safety\_warning": null,

      "source\_name": "VERIFY",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "azithromycin\_tonsillitis",

      "illness\_id": "tonsillitis",

      "drug\_name\_en": "Azithromycin",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_schedule": \[

        { "day": 1, "dose\_per\_kg\_mg": 10, "max\_dose\_mg": 500 },

        { "day": "2-5", "dose\_per\_kg\_mg": 5, "max\_dose\_mg": 250 }

      ],

      "frequency\_en": "once daily",

      "duration\_days": 5,

      "notes": "Penicillin-allergy alternative",

      "concentrations": \[

        { "label\_en": "VERIFY local syrup strength", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "safety\_warning": null,

      "source\_name": "Standard pediatric guidance",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "amoxicillin\_otitis",

      "illness\_id": "otitis\_media",

      "drug\_name\_en": "Amoxicillin",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": true,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": null,

      "notes": "VERIFY — may follow the same high-dose logic as pneumonia (40mg/kg/dose) or a different local standard. Do not assume identical to the pneumonia entry without checking.",

      "frequency\_en": "twice daily",

      "duration\_days": null,

      "duration\_note": "5-7 days typical — VERIFY",

      "concentrations": \[

        { "label\_en": "125mg/5ml", "strength\_mg": 125, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 },

        { "label\_en": "250mg/5ml", "strength\_mg": 250, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": 1, "max\_safe\_ml": 20 }

      ],

      "penicillin\_allergy\_alternative": \["azithromycin\_otitis", "augmentin\_otitis"],

      "safety\_warning": null,

      "source\_name": "VERIFY",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "azithromycin\_otitis",

      "illness\_id": "otitis\_media",

      "drug\_name\_en": "Azithromycin",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_schedule": \[

        { "day": 1, "dose\_per\_kg\_mg": 10, "max\_dose\_mg": 500 },

        { "day": "2-5", "dose\_per\_kg\_mg": 5, "max\_dose\_mg": 250 }

      ],

      "frequency\_en": "once daily",

      "duration\_days": 5,

      "concentrations": \[

        { "label\_en": "VERIFY local syrup strength", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "safety\_warning": null,

      "source\_name": "Standard pediatric guidance",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "augmentin\_otitis",

      "illness\_id": "otitis\_media",

      "drug\_name\_en": "Amoxicillin-Clavulanate (Augmentin)",

      "drug\_name\_am": "",

      "drug\_synonyms": \["Augmentin"],

      "is\_recommended": false,

      "combination\_drug": true,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": null,

      "notes": "Same VERIFY flags as the pneumonia Augmentin entry — dosed on amoxicillin component, ratio-dependent.",

      "frequency\_en": "twice daily",

      "duration\_days": null,

      "concentrations": \[

        { "label\_en": "VERIFY exact local formulation ratio", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "safety\_warning": null,

      "source\_name": "VERIFY",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "salbutamol\_asthma",

      "illness\_id": "asthma",

      "drug\_name\_en": "Salbutamol",

      "drug\_name\_am": "",

      "drug\_synonyms": \["Ventolin"],

      "is\_recommended": true,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": null,

      "notes": "VERIFY — salbutamol syrup is often age-banded rather than strict mg/kg locally; confirm which format Ethiopia STG uses before building.",

      "frequency\_en": "VERIFY",

      "duration\_days": null,

      "concentrations": \[

        { "label\_en": "VERIFY local syrup strength", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "referral\_trigger\_text": "Acute severe asthma (unable to speak, severe chest indrawing, cyanosis) needs urgent referral and nebulized/inhaled therapy — this is NOT a syrup-dosing situation. Consider a hard screen-level warning distinguishing mild wheeze from acute severe asthma before this entry ships.",

      "safety\_warning": null,

      "source\_name": "VERIFY",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required, structural design decision needed"

    },



    {

      "id": "prednisolone\_asthma",

      "illness\_id": "asthma",

      "drug\_name\_en": "Prednisolone",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": 1.5,

      "notes": "Range 1-2mg/kg/day; 1.5 used as practical midpoint — VERIFY preferred figure. For moderate-severe exacerbations per clinical judgment, not routine for every mild wheeze case.",

      "frequency\_en": "once daily or divided",

      "duration\_days": 4,

      "max\_daily\_dose\_mg": 60,

      "concentrations": \[

        { "label\_en": "VERIFY local syrup strength", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "safety\_warning": null,

      "source\_name": "GINA guideline range",

      "source\_detail": "Consistent across multiple pediatric asthma references",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "cloxacillin\_impetigo",

      "illness\_id": "impetigo",

      "drug\_name\_en": "Cloxacillin",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": true,

      "combination\_drug": false,

      "dosing\_shape": "mg\_per\_kg",

      "dose\_per\_kg\_mg": null,

      "notes": "VERIFY — commonly 12.5-25mg/kg/dose four times daily, less standardized across references than other entries. Also worth deciding whether topical treatment should be first-line for localized impetigo instead of oral — a clinical judgment call, not just a number to look up.",

      "frequency\_en": "four times daily",

      "duration\_days": null,

      "concentrations": \[

        { "label\_en": "VERIFY local syrup strength", "strength\_mg": null, "volume\_ml": 5, "round\_to\_ml": 0.5, "min\_safe\_ml": null, "max\_safe\_ml": null }

      ],

      "safety\_warning": null,

      "source\_name": "VERIFY",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "albendazole\_worms",

      "illness\_id": "worms",

      "drug\_name\_en": "Albendazole",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": true,

      "combination\_drug": false,

      "dosing\_shape": "age\_band",

      "frequency\_en": "single dose",

      "duration\_days": 1,

      "bands": \[

        { "min\_months": 12, "max\_months": 23, "dose\_display\_en": "200mg (half tablet) single dose" },

        { "min\_months": 24, "max\_months": null, "dose\_display\_en": "400mg (full tablet) single dose" }

      ],

      "safety\_warning": null,

      "source\_name": "VERIFY against Ethiopia's specific national deworming program schedule",

      "source\_detail": "Do not assume generic WHO bands match the Ethiopian program exactly — check directly.",

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    },



    {

      "id": "mebendazole\_worms",

      "illness\_id": "worms",

      "drug\_name\_en": "Mebendazole",

      "drug\_name\_am": "",

      "drug\_synonyms": \[],

      "is\_recommended": false,

      "combination\_drug": false,

      "dosing\_shape": "age\_band",

      "frequency\_en": "single dose (or twice daily for 3 days depending on regimen — VERIFY)",

      "duration\_days": 1,

      "bands": \[

        { "min\_months": 12, "max\_months": null, "dose\_display\_en": "VERIFY exact dose — commonly 500mg single dose" }

      ],

      "safety\_warning": null,

      "source\_name": "VERIFY against Ethiopia's specific national deworming program schedule",

      "source\_detail": null,

      "last\_verified": null,

      "verified\_by": "PENDING — Dr. Basliel review required"

    }



  ]

}

\


10.3 — meta.json

Json



{

  "schema\_version": "1.0",

  "dataset\_version": "0.3-draft",

  "dataset\_status": "UNVERIFIED — DO NOT USE FOR REAL PATIENT CARE UNTIL CLINICALLY SIGNED OFF",

  "dataset\_last\_updated": "2026-07-16",

  "reviewed\_by": \[],

  "notes": "Compiled from WHO/IMCI, Ethiopia National Malaria Guideline references, and standard pediatric sources as a starting structure for DoseGPT. Every entry in drugs.json with 'VERIFY' in its source\_detail or notes field requires direct clinical review before this dataset is considered production-ready. This file itself should be updated with reviewer name(s) and date only once that review is complete."

}

\


11\. Final note to the coder

This document is complete and self-contained — everything needed to build MVP1 is above. If any instruction here seems to conflict with another part of this document, the Build Order (Section 9B) sequence and the universal edge-case rule (Section 3, item 8) take precedence over all else, since they protect against the one failure mode that matters most in this app: a wrong or fabricated dose reaching a real child.

