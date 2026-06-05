# SZABIST FYP Finder

A mobile application built with Flutter and Node.js that helps SZABIST students find FYP (Final Year Project) partners, explore project ideas, and connect with supervisors.

---

## Description

SZABIST FYP Finder is a full-stack mobile app designed to simplify the FYP team formation process at SZABIST Karachi. Students can create profiles, post project ideas, send partner requests, and browse available supervisors — all backed by a real REST API connected to a MySQL database.

---

## Features

- **Student Profiles** — View and edit your profile with skills, technologies, interests, GitHub, LinkedIn, and resume links
- **Partner Finder** — Browse all student profiles with search and filter by department, batch, skills, and technologies
- **FYP Ideas** — Post, browse, and manage project ideas with status tracking (open / closed / archived)
- **Partner Requests** — Send, accept, and reject partnership requests with real-time status updates
- **Supervisors** — Browse available supervisors with their specializations and available slots
- **Bookmarks** — Save student profiles for later
- **Chat** — Message other students directly in-app
- **Settings** — Manage account preferences and logout

---

## Technologies Used

### Frontend
| Technology | Purpose |
|---|---|
| Flutter (Dart) | Cross-platform mobile UI |
| Riverpod (StateNotifierProvider) | State management |
| GoRouter | Navigation / routing |
| http package | REST API calls |
| Google Fonts | Typography (Poppins) |
| url_launcher | Open GitHub / LinkedIn / resume links |

### Backend
| Technology | Purpose |
|---|---|
| Node.js + Express.js | REST API server |
| MySQL 8.0 | Relational database |
| mysql2 | MySQL driver with promise API |
| dotenv | Environment variable management |
| cors | Cross-origin request handling |

---

## Project Structure

```
szabist_fyp_finder/
├── backend/                        # Node.js REST API
│   ├── config/
│   │   └── db.js                   # MySQL connection pool
│   ├── routes/
│   │   ├── students.js             # CRUD for students
│   │   ├── ideas.js                # CRUD for ideas
│   │   ├── requests.js             # CRUD for requests
│   │   └── supervisors.js          # CRUD for supervisors
│   ├── .env                        # Environment variables
│   ├── server.js                   # Express app entry point
│   └── package.json
│
└── lib/                            # Flutter app
    ├── core/                       # Colors, constants, utils
    ├── features/                   # Feature-based screens
    │   ├── auth/                   # Login, splash
    │   ├── bookmarks/              # Saved profiles
    │   ├── chat/                   # Messaging
    │   ├── dashboard/              # Home dashboard
    │   ├── discovery/              # Partner finder
    │   ├── ideas/                  # FYP ideas
    │   ├── profile/                # Student profile
    │   ├── requests/               # Partner requests
    │   ├── settings/               # App settings
    │   └── supervisors/            # Supervisor browser
    └── shared/
        ├── models/                 # Data models
        ├── providers/              # Riverpod providers
        ├── services/               # API service classes
        └── widgets/                # Reusable widgets
```

---

## API Endpoints

| Module | Method | Endpoint | Description |
|---|---|---|---|
| Students | GET | `/api/students` | Get all students |
| Students | GET | `/api/students/:id` | Get student by ID |
| Students | POST | `/api/students` | Create student |
| Students | PUT | `/api/students/:id` | Update student |
| Students | DELETE | `/api/students/:id` | Delete student |
| Ideas | GET | `/api/ideas` | Get all ideas (`?status=open`) |
| Ideas | GET | `/api/ideas/:id` | Get idea by ID |
| Ideas | POST | `/api/ideas` | Create idea |
| Ideas | PUT | `/api/ideas/:id` | Update idea |
| Ideas | DELETE | `/api/ideas/:id` | Delete idea |
| Requests | GET | `/api/requests` | Get all requests (`?status=pending`) |
| Requests | GET | `/api/requests/:id` | Get request by ID |
| Requests | POST | `/api/requests` | Send request |
| Requests | PUT | `/api/requests/:id` | Update request status |
| Requests | DELETE | `/api/requests/:id` | Delete request |
| Supervisors | GET | `/api/supervisors` | Get all supervisors |
| Supervisors | GET | `/api/supervisors/:id` | Get supervisor by ID |
| Supervisors | POST | `/api/supervisors` | Add supervisor |
| Supervisors | PUT | `/api/supervisors/:id` | Update supervisor |
| Supervisors | DELETE | `/api/supervisors/:id` | Delete supervisor |

---

## Database Schema

**Database:** `fyp_finder_db`

```sql
students    — id, name, email (unique), registration_id (unique), department,
              section, batch, skills, technologies, interests, bio,
              github_url, linkedin_url, completion_percentage, is_locked,
              is_profile_public, created_at

ideas       — id, owner_name, owner_id, owner_dept, title, description,
              technologies_required, skills_required, status (open/closed/archived),
              created_at

requests    — id, sender_name, sender_dept, receiver_name, message,
              status (pending/accepted/rejected), created_at

supervisors — id, name, email (unique), department, designation,
              specialization, available_slots, is_available, created_at
```

---

## Setup Instructions

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or above)
- [Node.js](https://nodejs.org/) (v18 or above)
- [MySQL 8.0](https://dev.mysql.com/downloads/mysql/)
- Android Emulator or physical Android device

---

### 1. Clone the Repository

```bash
git clone https://github.com/arunkumar231105/szabist_fyp_finder.git
cd szabist_fyp_finder
```

---

### 2. Database Setup

Open MySQL Workbench or MySQL CLI and run:

```sql
CREATE DATABASE fyp_finder_db;
USE fyp_finder_db;

CREATE TABLE students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  registration_id VARCHAR(50) NOT NULL UNIQUE,
  department VARCHAR(20) NOT NULL,
  section VARCHAR(5),
  batch VARCHAR(10),
  skills VARCHAR(500),
  technologies VARCHAR(500),
  interests VARCHAR(500),
  bio TEXT,
  github_url VARCHAR(255),
  linkedin_url VARCHAR(255),
  completion_percentage INT DEFAULT 0,
  is_locked TINYINT(1) DEFAULT 0,
  is_profile_public TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ideas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  owner_name VARCHAR(100) NOT NULL,
  owner_id INT NOT NULL,
  owner_dept VARCHAR(20),
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  technologies_required VARCHAR(500),
  skills_required VARCHAR(500),
  status ENUM('open','closed','archived') DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sender_name VARCHAR(100) NOT NULL,
  sender_dept VARCHAR(20) NOT NULL,
  receiver_name VARCHAR(100) NOT NULL,
  message VARCHAR(500),
  status ENUM('pending','accepted','rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE supervisors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  department VARCHAR(20) NOT NULL,
  designation VARCHAR(100),
  specialization VARCHAR(300),
  available_slots INT DEFAULT 0,
  is_available TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### 3. Backend Setup

```bash
cd backend
npm install
```

Create a `.env` file in the `backend/` folder:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=fyp_finder_db
PORT=3000
```

Start the backend server:

```bash
npm start
```

Server will run at `http://localhost:3000`

---

### 4. Flutter App Setup

```bash
# From the project root
flutter pub get
```

**Important — API Base URL:**

Open `lib/shared/services/api_service.dart` and set the correct base URL:

```dart
// Android Emulator
const String _base = 'http://10.0.2.2:3000/api';

// Real Device (replace with your PC's local IP)
// const String _base = 'http://192.168.1.x:3000/api';
```

Run the app:

```bash
flutter run -d emulator-5554 --no-enable-impeller
```

> **Note:** `--no-enable-impeller` is required for Android API 36 emulators due to an OpenGL ES limitation. Not needed on real devices.

---

### 5. Testing the API (Postman)

Import and test any endpoint. Example:

```
GET  http://localhost:3000/api/students
POST http://localhost:3000/api/students
     Body → raw → JSON
     {
       "name": "Ali Hassan",
       "email": "bscs2380999@szabist.pk",
       "registrationId": "2380999",
       "department": "CS",
       "section": "A",
       "batch": "2023"
     }
```

---

## Developer

**Arun Kumar**
Registration ID: 2380145
Department: Software Engineering
SZABIST Karachi — 2026

---

## License

This project is developed for academic purposes at SZABIST Karachi.
