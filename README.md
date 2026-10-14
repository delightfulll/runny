# Runny

## Demo

[![Runny Demo](docs/demo-thumbnail.jpg)](https://youtu.be/2BdfBvhCMq4)

> Click the thumbnail to watch the demo.

---

A fitness tracking iOS app that lets you log workouts, view activity history, track your daily streak, and monitor strain & recovery metrics.

---

## Tech Stack

### iOS App

| Framework / Library | Purpose                                                    |
| ------------------- | ---------------------------------------------------------- |
| **SwiftUI**         | Declarative UI layout and navigation                       |
| **MapKit**          | Live map view and route display                            |
| **CoreLocation**    | GPS tracking via `CLLocationManager`                       |
| **Charts**          | Weekly workout bar charts                                  |
| **Combine**         | Reactive state management in ViewModels                    |
| **URLSession**      | Async networking and REST API calls                        |
| **UserDefaults**    | Local auth token storage                                   |
| **Foundation**      | Base types, date formatting, and data handling             |

**Language:** Swift  
**Platform:** iOS  
**Minimum Deployment Target:** iOS 26.0 (see `Runny.xcodeproj`)

### Backend

| Library / Tool    | Purpose                              |
| ----------------- | ------------------------------------ |
| **Express**       | REST API server                      |
| **PostgreSQL**    | Relational database (via `pg`)       |
| **bcrypt**        | Password hashing                     |
| **jsonwebtoken**  | JWT-based authentication             |
| **helmet**        | HTTP security headers                |
| **cors**          | Cross-origin request handling        |
| **uuid**          | Unique ID generation                 |
| **dotenv**        | Environment variable management      |
| **TypeScript**    | Type-safe backend code               |

**Runtime:** Node.js

### Infrastructure

| Service      | Purpose                        |
| ------------ | ------------------------------ |
| **Docker**   | Backend containerization       |
| **AWS EC2**  | Backend hosting                |
| **AWS ECS**  | Container orchestration        |
| **AWS ECR**  | Docker container registry      |

---

## Features

- **Authentication** — Register and log in with JWT-based auth, persisted locally
- **Activity Logging** — Log runs, walks, bike rides, and weightlifting sessions
- **Live GPS Tracking** — Real-time route tracking on a live map using `CoreLocation` and `MapKit`
- **Activity History** — Browse past workouts with detailed stats per activity
- **Daily Streak** — Visual 7-day streak tracker to maintain consistency
- **Strain & Recovery** — Dashboard showing a Whoop-style strain score (0–21) and recovery metric, calculated on-device from your logged activities
- **Weekly Charts** — Bar chart of workouts per day over the past 7 days

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
    ├── schema.sql          # Database schema
    └── Dockerfile          # Backend container image
```

---

## API Endpoints

All routes are prefixed with `/api`. Everything except `/auth/*` requires a JWT in the `Authorization: Bearer <token>` header.

| Method | Route               | Description                  |
| ------ | ------------------- | ---------------------------- |
| POST   | `/auth/register`    | Create an account            |
| POST   | `/auth/login`       | Log in and receive a JWT     |
| GET    | `/users/me`         | Get the current user         |
| PATCH  | `/users/me`         | Update the current user      |
| GET    | `/activities`       | List your activities         |
| GET    | `/activities/:id`   | Get a single activity        |
| POST   | `/activities`       | Log a new activity           |
| DELETE | `/activities/:id`   | Delete an activity           |

---

## Getting Started

### Backend

```bash
cd backend
npm install
psql "$DATABASE_URL" -f schema.sql   # create tables
```

Create a `backend/.env` file (it's gitignored):

```
DATABASE_URL=postgres://user:password@localhost:5432/runny
JWT_SECRET=your-secret
PORT=8080
```

Then start the server:

```bash
npm run dev
```

### iOS App

Open `Runny.xcodeproj` in Xcode and run on targeted device.

> Update `APIService.baseURL` in `Runny/Services/APIService.swift` to point to your backend to make sure api's work as intended
