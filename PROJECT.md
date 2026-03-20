# LearingLeague — Open Source Fraud Hunter for Independent Journalists

*"Claim routes. Expose the grift. Climb the league. Claim your prize."*

**Owner:** Joseph Gale
**Started:** 2026-03-19
**Status:** Planning
**License:** MIT
**Inspired by:** Nick Shirley's "Quality Learing Center" investigations

---

## 1. Project Overview

LearingLeague is an open-source, cross-platform app that turns independent journalists and citizen investigators into a nationwide network of fraud hunters.

It features:
- A live **megabase** of potential fraud leads (childcare, hospice, home health, government programs, etc.)
- Territory-based **route claiming** (zip codes, counties, specific providers)
- One-click evidence upload + official reporting tools
- Competitive **leaderboards** and heavy **gamification** so users actually grind investigations like Nick Shirley does

**Core Mission:** Make exposing taxpayer fraud as addictive as a mobile game while staying 100% evidence-based and legally safe.

## 2. Target Users

- Independent journalists & citizen reporters (Nick Shirley fans)
- Whistleblowers & concerned taxpayers
- Investigative podcasters / YouTubers
- State & local watchdogs
- Journalism students / open-source contributors

## 3. Core Features

### Megabase (the heart of the app)

- Nationwide database of licensed providers pulling public data (HHS, state licensing boards, SAM.gov, Medicare claims, county property records, etc.)
- AI-powered red-flag scoring on every lead (empty building probability, funding vs. visible activity, owner conflicts, etc.)
- Search + filters by state, program, funding amount, last verified date

### Route Claiming System

- Users can "claim" or join any territory (zip code, county, or single provider)
- **Multiple people can claim the exact same route at the same time** — no exclusive locking
- Every route publicly shows the full list of active claimants (usernames, avatars, join date)
- All claimants can collaboratively add photos, videos, notes, checklists, and evidence in real time
- Visual map interface (shows claim density, team icons, and live activity heat map)

### Investigation & Reporting Toolkit

- Geo-tagged photo/video uploader with timestamps
- Built-in checklists ("Quality Learing Center" style templates)
- Draft report generator (PDF + evidence package) — any claimant on the route can contribute

### Government Reporting & Prize Claiming

- One-click guided submission to official government channels:
  - HHS OIG Fraud Hotline (quick tip line)
  - DOJ for **False Claims Act (FCA) qui tam** complaints (sealed lawsuit option)
  - State AG offices and licensing boards
- **Reward info built-in:** Under the False Claims Act, successful whistleblowers can receive **15–30%** of any money the government recovers. FY2025 set an all-time record with **$6.8 billion** recovered nationwide (mostly healthcare fraud), and 1,297 new qui tam lawsuits filed — the highest ever.
- Evidence package auto-generates and pre-fills for submission
- Status tracker for submitted reports (user-only view)
- **Heavy legal disclaimers on every screen:** "This is NOT legal advice. Qui tam requires a formal sealed lawsuit (strongly recommend a whistleblower attorney). No guarantee of any payout or government action. Rewards only paid if the government successfully recovers funds. You are responsible for your own filing and any legal risks."

### Community Feed

- Moderated "Exposes" feed (verified reports only)
- Upvote + comment system (evidence only — no speculation)

## 4. Gamification System

Designed like a mix of Pokemon GO + Duolingo + bounty hunting.

### Points & XP

- Join/claim a route: +50 XP
- Upload 5+ pieces of evidence: +100 XP
- Submit verified report to agency: +500 XP
- Report gets picked up by media / official action: +2,000 XP bonus
- Daily login streak multiplier

### Leaderboards (real-time, updated live)

- National Top 100
- State leaderboards
- Program-specific (Childcare Grift King, Hospice Reaper, etc.)
- Weekly "Most Ghosts Busted" resets

### Levels, Badges, Quests, Rewards

**TBD** — will be finalized with open-source community input and Nick Shirley base feedback.

### Anti-Cheat

- All evidence must be geo-tagged + timestamped
- Manual moderation queue for leaderboard entries
- Reports flagged for review before points awarded

## 5. Technical Architecture

### Stack

- **Frontend/Mobile:** Flutter (iOS + Android + web — one codebase)
- **Backend:** Supabase (PostgreSQL + Realtime + Storage + Auth)
- **Maps:** Mapbox (open-source friendly, free tier)
- **AI Red Flags:** OpenAI API (turnkey) — swappable to Llama local models later
- **Hosting:** Supabase (backend) + Vercel (web frontend)
- **Data Scrapers:** Python jobs on GitHub Actions (community can contribute)

### Database Models (high-level)

- `providers` — leads table (the megabase)
- `routes` — claimed territories (many-to-many with users)
- `investigations` — user evidence packages (tied to routes)
- `reports` — submitted + status (includes government submission tracking)
- `users` — with XP, badges, level
- `leaderboard_snapshots`

### Open-Source Structure

- Public GitHub: `josephgale/LearingLeague`
- License: MIT
- Private fork for production megabase (controls live data)
- Contributors can add scrapers, UI improvements, new state modules

## 6. Security & Legal (non-negotiable)

- Strong disclaimers on every screen (especially prize-claiming flow)
- Anonymous reporting mode
- Evidence stored encrypted
- Rate limiting + anti-abuse
- Full `DISCLAIMER.md` + `CODE_OF_CONDUCT.md` in repo
- "Evidence only — no doxxing, no harassment" rules enforced

## 7. Development Roadmap

### MVP (Phase 1)

- Megabase seed data (top 3 states + 2 programs)
- Multi-user route claiming + live claimant list
- Evidence uploader + collaborative editing
- Leaderboards + basic points
- Government reporting toolkit with prize info + disclaimers
- Open-source repo live

### Phase 2

- Full gamification (community-decided levels, badges, quests, rewards)
- AI photo scanner
- Multi-state scrapers (community driven)

### Phase 3

- Mobile push notifications ("New teammate just joined your Minnesota route" or "Your report just triggered a government review")
- Podcast export tools
- Nick Shirley integration / verified accounts

## 8. Success Metrics

- 1,000 active users in first 3 months
- 500+ routes claimed (with multiple claimants)
- 50+ official reports filed
- At least 3 major media pickups from user exposes

---

*This document is the single source of truth for the project. Update it as decisions are made.*
