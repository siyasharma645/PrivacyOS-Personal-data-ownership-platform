# PrivacyOS — Personal Data Ownership & Privacy Intelligence Platform

Full-stack privacy monitoring platform with Flutter frontend and Spring Boot backend.

## Stack
| Layer | Technology |
|-------|-----------|
| Mobile/Desktop/Web Frontend | Flutter 3.16 + Riverpod + GoRouter |
| Backend API | Java 21 + Spring Boot 3.2 + Spring Security |
| Primary Database | PostgreSQL 16 |
| Graph Database | Neo4j 5 |
| Cache | Redis 7 |
| Search | Elasticsearch 8 |
| AI | Anthropic Claude API |
| Container | Docker + Docker Compose |

## Quick Start

### Prerequisites
- Docker 24+ and Docker Compose v2
- 8 GB RAM minimum

### 1. Clone & configure
```bash
git clone <repo> && cd privacyos
cp .env.example .env
# Edit .env with your API keys (all optional for demo)
```

### 2. Start everything
```bash
docker compose up -d
```

### 3. Access
| Service | URL |
|---------|-----|
| Flutter Web App | http://localhost:3000 |
| Spring Boot API | http://localhost:8080 |
| Neo4j Browser | http://localhost:7474 |

### 4. Demo login
```
Email:    demo@privacyos.io
Password: Demo@1234
```

## Flutter Development

```bash
cd frontend
flutter pub get

# Run on web (connects to backend at localhost:8080)
flutter run -d chrome --dart-define=API_URL=http://localhost:8080

# Run on Android
flutter run -d android --dart-define=API_URL=http://10.0.2.2:8080

# Run on iOS
flutter run -d ios --dart-define=API_URL=http://localhost:8080

# Build web release
flutter build web --release --dart-define=API_URL=http://your-api.com
```

## Backend Development

```bash
cd backend

# Start only infrastructure
docker compose up postgres redis neo4j elasticsearch -d

# Run Spring Boot
mvn spring-boot:run
```

## Project Structure

```
privacyos/
├── docker-compose.yml
├── .env.example
├── backend/                          # Spring Boot API
│   ├── src/main/java/com/privacyos/
│   │   ├── config/                   # Security, Redis, WebClient
│   │   ├── controller/               # REST endpoints
│   │   ├── dto/                      # Request/Response records
│   │   ├── entity/                   # JPA entities
│   │   ├── exception/                # Global error handling
│   │   ├── repository/               # Spring Data JPA repos
│   │   ├── security/                 # JWT filter + service
│   │   └── service/                  # Business logic
│   └── src/main/resources/
│       ├── application.yml
│       └── db/migration/             # Flyway SQL migrations
└── frontend/                         # Flutter app
    └── lib/
        ├── api/                      # Dio HTTP clients
        ├── models/                   # Data classes
        ├── providers/                # Riverpod state
        ├── router.dart               # GoRouter navigation
        ├── screens/                  # 8 full screens
        │   ├── auth/                 # Login + Register
        │   ├── dashboard/            # Privacy overview + chart
        │   ├── accounts/             # Connected accounts + permissions
        │   ├── breaches/             # Breach monitor
        │   ├── recommendations/      # Privacy action items
        │   ├── timeline/             # Privacy event log
        │   ├── graph/                # Interactive data graph
        │   ├── ai/                   # AI chat assistant
        │   └── settings/             # Profile + score breakdown
        ├── utils/                    # Theme, formatters, extensions
        └── widgets/                  # Shared UI components
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register |
| POST | `/api/v1/auth/login` | Login → JWT |
| GET  | `/api/v1/dashboard` | Full dashboard data |
| GET  | `/api/v1/dashboard/score` | Privacy score breakdown |
| GET  | `/api/v1/accounts` | Connected OAuth accounts |
| DELETE | `/api/v1/accounts/{id}` | Disconnect account |
| POST | `/api/v1/accounts/{id}/sync` | Sync account |
| DELETE | `/api/v1/accounts/permissions/{id}` | Revoke permission |
| GET  | `/api/v1/breaches` | Data breaches |
| POST | `/api/v1/breaches/check` | Run breach check |
| GET  | `/api/v1/recommendations` | Privacy recommendations |
| POST | `/api/v1/recommendations/{id}/complete` | Complete action |
| GET  | `/api/v1/timeline` | Privacy event timeline |
| GET  | `/api/v1/graph` | Data ownership graph |
| POST | `/api/v1/ai/chat` | AI assistant chat |
| POST | `/api/v1/ai/explain/permission/{id}` | Explain permission |

## Privacy Score Algorithm

Score 0–100 (higher = more private):

| Factor | Weight | Calculation |
|--------|--------|-------------|
| Permission Risk | 35% | CRITICAL=15, HIGH=8, MEDIUM=3, LOW=1 pts each |
| Breach Exposure | 25% | Unresolved breaches × 12 pts |
| Third-Party Sharing | 20% | OAuth scope breadth |
| Account Sprawl | 12% | >3 accounts penalised |
| Data Staleness | 8% | Accounts not synced in 30+ days |

Risk levels: 80–100=LOW, 60–79=MEDIUM, 40–59=HIGH, 0–39=CRITICAL

## Environment Variables

```env
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
ANTHROPIC_API_KEY=your-anthropic-api-key
HIBP_API_KEY=your-hibp-api-key
JWT_SECRET=change-in-production-min-32-chars
```
