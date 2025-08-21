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
  <img width="1433" height="929" alt="image" src="https://github.com/user-attachments/assets/6464c136-6bf1-41e9-b8e8-d68d3917323b" />

- `GET /api/incidents` → List all
  <img width="1384" height="881" alt="image" src="https://github.com/user-attachments/assets/bf71dc40-88c0-4047-af6f-595271adca83" />

- `GET /api/incidents/{id}` → Get one
  <img width="1408" height="919" alt="image" src="https://github.com/user-attachments/assets/fba753f5-137c-4087-a967-daf9350d36d3" />

- `PUT /api/incidents/{id}` → Update
  <img width="1424" height="945" alt="image" src="https://github.com/user-attachments/assets/7ec92c84-7cd5-4436-b51e-4d5fb9933d4c" />

- `DELETE /api/incidents/{id}` → Delete
  <img width="1348" height="915" alt="image" src="https://github.com/user-attachments/assets/f4d28477-fb3a-4122-be34-662bd4746bbb" />


## Run Locally
```bash
mvn spring-boot:run


