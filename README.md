# LearingLeague

**Open source fraud hunter for independent journalists.**

*Claim routes. Expose the grift. Climb the league. Claim your prize.*

---

LearingLeague turns independent journalists and citizen investigators into a nationwide network of fraud hunters. Inspired by [Nick Shirley's](https://www.youtube.com/@NickShirley) investigations of fraudulent hospice, daycare, and autism centers across the United States.

## What It Does

- **Megabase** — Nationwide database of government-funded providers (hospice, childcare, autism centers, home health) with AI-powered fraud risk scores
- **Interactive Map** — Pindrops on every suspected fraudulent entity, color-coded by investigation status
- **Route Claiming** — Claim geographic routes (zip codes, counties) and investigate providers on the ground with other hunters
- **Evidence Collection** — Geo-tagged photos, videos, notes, and checklists uploaded from the field
- **Government Reporting** — One-click guided submission to HHS OIG, DOJ (False Claims Act / qui tam), state AGs, and licensing boards
- **Gamification** — XP, levels, leaderboards, and titles. Make fraud hunting as addictive as a mobile game.

## Tech Stack

| Layer | Tech |
|-------|------|
| Frontend/Mobile | Flutter (iOS, Android, Web) |
| Backend | Supabase (PostgreSQL, Auth, Realtime, Storage) |
| Maps | Mapbox GL |
| AI Scoring | OpenAI API (swappable) |
| Scrapers | Python + GitHub Actions |

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) 3.29+
- A [Supabase](https://supabase.com) project (free tier works)
- A [Mapbox](https://www.mapbox.com) access token (free tier)

### Setup

1. **Clone the repo**
   ```bash
   git clone git@github.com:josephgale/LearingLeague.git
   cd LearingLeague
   ```

2. **Set up Supabase**
   - Create a new Supabase project
   - Run the migration: copy `supabase/migrations/00001_initial_schema.sql` into the Supabase SQL Editor and execute
   - Copy your project URL and anon key

3. **Configure environment**
   ```bash
   # Run with environment variables
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
               --dart-define=SUPABASE_ANON_KEY=your-anon-key \
               --dart-define=MAPBOX_ACCESS_TOKEN=your-mapbox-token
   ```

4. **Run**
   ```bash
   flutter run -d chrome    # Web
   flutter run -d android   # Android
   flutter run -d ios        # iOS
   ```

## Project Structure

```
lib/
  config/         # App constants, theme
  models/         # Data models (Provider, Route, Investigation, etc.)
  providers/      # Riverpod state providers
  screens/        # Map, Routes, Leaderboard, Profile, Auth
  services/       # Supabase service layer
  widgets/        # Reusable UI components
supabase/
  migrations/     # Database schema (PostgreSQL + PostGIS)
scrapers/         # Python data scrapers (community-contributed)
```

## XP System

| Action | XP |
|--------|----|
| Claim a route | +50 |
| Upload 5+ evidence items | +100 |
| Submit report to agency | +500 |
| Report picked up by media | +2,000 |
| Daily login | +25 |

## Contributing

We welcome contributions! Especially:

- **State scrapers** — Python scripts that pull public licensing data for specific states
- **UI improvements** — Better map interactions, mobile UX, accessibility
- **Fraud detection rules** — New red-flag indicators based on domain expertise
- **Documentation** — Guides for journalists, legal info, state-specific resources

See `CODE_OF_CONDUCT.md` before contributing.

## Legal

**READ `DISCLAIMER.md` BEFORE USING THIS SOFTWARE.**

This tool works exclusively with publicly available data. It does not make accusations of fraud — it identifies entities that match known risk patterns for further investigation by qualified individuals.

Under the False Claims Act, whistleblowers may receive 15-30% of recovered funds. FY2025 saw $6.8B recovered and 1,297 new qui tam lawsuits — the highest ever. **This app is not a substitute for legal counsel.** Consult a whistleblower attorney before filing.

## License

MIT — see `LICENSE`
