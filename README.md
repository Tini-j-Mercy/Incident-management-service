# 🚀 Incident Management Service (Spring Boot)

A Spring Boot project that provides CRUD APIs for managing incidents, useful for DevOps & SRE teams.

## Features
- Create, Update, Delete incidents
- Track severity (LOW, MEDIUM, HIGH)
- Track status (OPEN, IN_PROGRESS, RESOLVED)
- REST API with JSON responses
- In-memory H2 database for testing
- Actuator endpoints for DevOps monitoring

## Endpoints
- `POST /api/incidents` → Create incident
- `GET /api/incidents` → List all
- `GET /api/incidents/{id}` → Get one
- `PUT /api/incidents/{id}` → Update
- `DELETE /api/incidents/{id}` → Delete

## Run Locally
```bash
mvn spring-boot:run

