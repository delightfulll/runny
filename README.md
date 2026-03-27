# Runny

A fitness tracking iOS app that lets you log workouts, view activity history, track your daily streak, and monitor strain & recovery metrics.

---

## Tech Stack

### iOS App (Swift)

- **SwiftUI** — UI framework
- **MapKit** — Map and route tracking
- **CoreLocation** — GPS location services
- **Charts** — Activity data visualizations
- **URLSession** — Networking / API calls
- **UserDefaults** — Local token storage

### Backend (Node.js)

- **Express** — REST API server
- **PostgreSQL** — Database (via `pg`)
- **bcrypt** — Password hashing
- **jsonwebtoken** — JWT authentication
- **helmet** — HTTP security headers
- **cors** — Cross-origin request handling
- **dotenv** — Environment variable management
- **TypeScript** — Type-safe backend code

### Infrastructure

- **Docker** — Backend containerization
- **AWS EC2** — Backend hosting

---

## Features

- User registration & login (JWT auth)
- Log runs, walks, bikes, and other workouts
- GPS route tracking on a live map
- Activity history with detail views
- Daily workout streak tracker
- Strain & recovery score dashboard
- Charts for distance and performance over time
- Whoop API integration (optional)

---

## Project Structure

```
Runny/
├── Runny/                  # iOS app source
│   ├── Models/             # Data models (Activity, User)
│   ├── ViewModels/         # Business logic (Auth, Activity, Location)
│   ├── Views/              # SwiftUI views
│   └── Services/           # API service layer
└── backend/                # Node.js REST API
    └── src/
        ├── routes/         # Auth, users, activities
        ├── middleware/     # JWT auth middleware
        ├── types/          # TypeScript types
        └── db/             # PostgreSQL connection
```

---

## Getting Started

### Backend

```bash
cd backend
npm install
cp .env.example .env   # fill in DB_URL, JWT_SECRET, PORT
npm run dev
```

### iOS App

Open `Runny.xcodeproj` in Xcode, set your target device, and run.

> Update `APIService.baseURL` in `Runny/Services/APIService.swift` to point to your backend.
