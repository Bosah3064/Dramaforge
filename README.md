# DramaForge — AI Short Drama Studio & Photo Animation Platform

[![Build & Test](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.4-blue.svg)](#)
[![NestJS](https://img.shields.io/badge/NestJS-10.3-red.svg)](#)
[![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B.svg)](#)
[![License](https://img.shields.io/badge/License-Clean--Room-purple.svg)](#)

> **DramaForge** is a privacy-first, clean-room AI Short Drama Studio and Viral Photo Animation platform. It enables creators to transform short ideas into cinematic 15–90s episodic vertical (9:16) and widescreen (16:9) short dramas through an intelligent 4-stage pipeline (Story Outline → Storyboard Shot List → Video Shots → Final Assembly & Subtitles) alongside a viral photo effects suite (Hug, Kiss, Dance, Aging, Outfit Swap).

---

## 🏗️ Architecture & Monorepo Structure

```
DramaForge/
├── docs/                         # Competitive intelligence, specs, compliance runbooks
│   ├── competitive-scan.md       # Public clean-room scan & live forum findings
│   ├── spec.md                   # Full product definition & requirements
│   ├── compliance-checklist.md   # Google Play & Apple AI guidelines checklist
│   └── store-submission.md       # App store metadata & data-safety answers
├── docker/                       # Local infrastructure
│   ├── docker-compose.yml        # PostgreSQL, Redis, MinIO (S3 mock), Backend, Admin
│   ├── Dockerfile.backend
│   └── Dockerfile.admin
├── packages/
│   ├── shared/                   # Shared TypeScript models, enums, DTOs & pricing constants
│   ├── backend/                  # NestJS API & Orchestrator with Prisma ORM
│   ├── admin-panel/              # React + Vite + Tailwind CSS Admin Web Panel
│   └── mobile/                   # Flutter cross-platform client (iOS & Android)
├── AGENTS.md                     # Agent guardrails and invariants
└── README.md
```

---

## ⚡ Core Invariants & Standing Rules

1. **Dual-Bucket Coin Ledger & Financial Safety**:
   - `SUBSCRIPTION_COINS`: expire at billing period end, no rollover, push notification 48h prior.
   - `PURCHASED_COINS`: non-expiring, consumed **only** after subscription coins are depleted.
   - **Zero in-place balance updates**: Every coin movement is an immutable row in `coin_ledger`.
   - **Pre-deduction with auto-refund**: Coins are reserved before enqueueing generation. On technical failure or model rejection, coins are immediately refunded via a compensating ledger entry.

2. **AI Provider Abstraction Layer**:
   - All AI calls go through the `AIProvider` / `VideoAIAdapter` interface.
   - Comes with a 100% offline, deterministic `MockAIAdapter` for zero-cost dev and automated testing.

3. **Safety, Moderation & Privacy Compliance**:
   - **13+ Age Gate**: Verification at registration.
   - **Pre-Transfer Third-Party Consent**: Explicit disclosure of AI processors (OpenAI, Google Veo, Anthropic, BytePlus) logged to database before media is sent.
   - **Face Consent Gate**: Viral photo effects require explicit confirmation: *"I have consent from every identifiable person in this media."*
   - **Graduated Enforcement Machine**: `NONE` → `WARNING` → `FEATURE_LIMIT` → `TEMP_SUSPEND` → `BANNED`.
   - **30-Day Retention Sweep**: Ephemeral uploaded reference photos are automatically deleted after 30 days.

---

## 🚀 Quickstart & Development

### 1. Install & Build All Packages
```bash
# Install dependencies across all workspaces
npm install

# Build shared types, backend, and admin panel
npm run build
```

### 2. Run Backend Unit Tests (Coin Ledger & Moderation)
```bash
cd packages/backend
npm test
```

### 3. Start Local Infrastructure via Docker
```bash
cd docker
docker-compose up -d
```
- **PostgreSQL**: `localhost:5432`
- **Redis**: `localhost:6379`
- **MinIO S3 Console**: `http://localhost:9001` (user: `minioadmin`, pass: `minioadminpassword`)

### 4. Run Backend API & Admin Web Panel
```bash
# Terminal 1: Backend API (NestJS)
npm run start:backend

# Terminal 2: Admin Panel (Vite + React)
npm run start:admin
```
- **Backend API**: `http://localhost:3000/api/v1`
- **OpenAPI Swagger UI**: `http://localhost:3000/api/docs`
- **Admin Operations Studio**: `http://localhost:5173`

---

## 📱 Mobile App (Flutter)

Located in `packages/mobile/`:
- **MVVM Architecture** with clean screen separation.
- Built-in Age Gate (13+), Pre-Transfer AI Consent, Quick Generation, 4-Stage Studio, Viral Photo Animation, Dual-Bucket Wallet, and Privacy Center.

```bash
cd packages/mobile
flutter pub get
flutter run
```

---

## ⚖️ Clean-Room Competitive Compliance Note

This repository contains an original, clean-room product. No proprietary code, binaries, or decompiled assets from competitor applications were used. All feature specifications are derived from public terms of use, privacy policies, store listings, and user community reviews.
