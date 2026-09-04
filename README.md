RaceDay: 

is a robust, scalable, and secure backend system designed to manage endurance events such as marathons, cycle tours, and charity walks. It provides a complete lifecycle management solution, from event creation and category setup to participant enrolment, bib allocation, and real-time result capturing.
Built with ASP.NET Core and SQL Server, RaceDay enforces strict role-based access control and adheres to modern API design principles, including standardized RFC 7807 error handling.

 Key Features:

Secure Authentication: JWT Bearer token authentication with strict Role-Based Access Control for Organisers and Participants.
Event Management: Full CRUD operations for events, including filtering by city, province, and event type (Running, Walking, Cycling).
Category & Enrolment System: Define race distances, max participants, and entry fees. Handle participant sign-ups and bib number assignments seamlessly.
Result Capturing: Organisers can record finish times, positions, and statuses (Finished, DNF, DSQ) with automatic database cascade rules.
Enterprise Error Handling: Consistent, developer-friendly error responses using the RFC 7807 Problem Details standard.
Optimized Database: Fully normalized SQL Server schema with cascading deletes, unique constraints, and check constraints to ensure absolute data integrity.

System Architecture & Database:

The system is powered by a highly normalized relational database consisting of 7 core tables:
Users: Stores participant and organiser profiles, including names, email, password hash, date of birth, gender, phone number, city, and province.
Roles: Defines system roles, specifically "Organiser" and "Participant".
UserRoles: A many-to-many mapping table linking Users to their assigned Roles.
Events: Core event details such as name, description, date, start time, location, city, province, event type, and status. Owned by an Organiser.
Categories: Race divisions within an event (e.g., "42.2km Full Marathon", "109km Full Tour"), including distance, max participants, and entry fees.
Enrolments: Tracks participant sign-ups, bib numbers, enrolment dates, and status (Registered, Confirmed, Withdrawn, DNS).
Results: Captures finish times, positions, and race statuses, linked directly to a specific enrolment.
Data Integrity Note: The schema enforces strict rules, such as preventing duplicate enrolments per category, ensuring valid event types, and cascading deletes from Events down to Results.

 API Endpoint Summary:
 
The API exposes 26 fully documented endpoints across 6 resource areas:
Authentication (2 endpoints): Register new users and login to receive a JWT token.
User Profile (2 endpoints): View and update personal details like phone, city, and province.
Events (6 endpoints): Create, read, update, and delete events. Includes a dedicated endpoint for organisers to view "my-events".
Categories (5 endpoints): Manage race distances, entry fees, and participant caps per event.
Enrolments (5 endpoints): Sign up for races, view personal or event-wide enrolments, withdraw, and update enrolment status.
Results (6 endpoints): Capture race results, view leaderboards grouped by category, and track personal race history.

Role Enforcement:

Public: Browse events, view categories, and view public results or leaderboards.
Participant: Manage personal profile, enrol in events, and view personal results.
Organiser: Create and manage events, manage categories, view event enrolments, and capture or update results.
🚀 Getting Started
Prerequisites
.NET 8.0 SDK (or higher)
SQL Server (LocalDB, Express, or Developer Edition)
Postman or Swagger UI for testing

1. Database Setup:
   
Execute the provided SQL script to create the database, schema, and seed data. Connect to your SQL Server instance and run the RaceDay_Database.sql file. This will create the RaceDay database, all tables, constraints, and inject sample South African events and users.

3. Application Configuration:
   
Update your appsettings.json with your database connection string and JWT settings:

{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=RaceDay;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "JwtSettings": {
    "SecretKey": "YourSuperSecretKeyForJWTTokenGeneration123!",
    "Issuer": "RaceDayAPI",
    "Audience": "RaceDayClients"
  }
}

3. Run the API
   
Execute the following command in your terminal:

dotnet run

The API will be available at https://localhost:<port>/api.

Seed Data Included

To help you test immediately, the database script includes realistic seed data:

Users: Thandi Nkosi (Organiser), Johan van der Merwe (Organiser), Sipho Dlamini (Participant), Lerato Mokoena (Participant).
Events: Soweto Marathon 2026 (Johannesburg), Cape Town Cycle Tour 2027 (Cape Town), and Midlands Meander Charity Walk 2026 (Pietermaritzburg).
Enrolments & Results: Pre-linked participants with Bib Numbers and recorded finish times.

Standardized Error Handling

All API errors follow the RFC 7807 Problem Details standard, making it easy for frontend clients to parse and display errors.

{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Validation Error",
  "status": 400,
  "detail": "One or more validation errors occurred.",
  "errors": {
    "email": ["The Email field is not a valid e-mail address."],
    "password": ["The Password must be at least 8 characters long."]
  }
}

