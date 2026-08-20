# YegnaConnect — MVP Product & Technical Specification

**Document type:** Source-of-truth implementation specification  
**Project:** YegnaConnect  
**Target:** Flutter mobile application + Node.js/Express backend + PostgreSQL  
**Database ORM:** Sequelize  
**Status:** MVP implementation  
**Audience:** AI coding agents, developers, reviewers, and project maintainers

---

## 1. Purpose of This Document

This document is the implementation contract for the YegnaConnect MVP.

AI coding agents should treat this document as the primary source of truth for:

- what the MVP does;
- what users can and cannot do;
- which features must be implemented;
- how the Flutter application, backend, database, and APIs fit together;
- which existing frontend work should be preserved;
- what is explicitly outside the MVP;
- how the system should be structured so the product can grow after MVP.

### Core instruction to coding agents

**Build the product described here. Do not invent additional product features unless they are required to make an explicitly requested feature work.**

If an implementation detail is not specified, choose a conventional, maintainable solution that fits the existing stack and architecture. Do not introduce unnecessary technologies.

---

# 2. Product Definition

## 2.1 One-sentence definition

**YegnaConnect is an Ethiopian local-service marketplace/finder where customers can discover nearby service providers, view their profiles, request services, communicate through the service-request flow, complete services, and review providers.**

## 2.2 MVP objective

The MVP must prove the complete core marketplace loop:

1. A customer creates an account and signs in.
2. A customer discovers relevant nearby service providers.
3. A customer views a provider's profile.
4. A customer creates a service request.
5. The provider receives the request.
6. The provider accepts or rejects the request.
7. The request progresses through its lifecycle.
8. The service is completed.
9. The customer leaves a 1–5 star review.
10. Both parties can see relevant request/status information and in-app notifications.

A provider must be admitted and verified before being treated as a verified provider in the marketplace.

---

# 3. MVP Scope

## 3.1 Customer features

Customers must be able to:

- Register.
- Sign in.
- Sign out.
- Manage their profile.
- Discover nearby providers.
- Search providers by service/category.
- Search providers by provider name.
- Filter providers by distance.
- Filter providers by rating.
- Filter by verified status.
- View provider profiles.
- See provider service information.
- See provider rating/review information.
- Create service requests.
- Specify request details.
- Provide/request a service location where applicable.
- View their requests.
- Track request status.
- Cancel eligible requests.
- Communicate with the provider through MVP chat.
- Receive in-app notifications.
- Mark/view relevant request information.
- Review a provider after a completed request with a 1–5 star rating.

## 3.2 Service provider features

Providers must be able to:

- Register.
- Sign in.
- Manage their profile.
- Create/update provider information.
- Select service categories.
- Describe offered services.
- Set service area/location.
- Submit required admission/verification information.
- See verification/admission status.
- Receive service requests.
- View request details.
- Accept requests.
- Reject requests.
- Cancel eligible requests according to business rules.
- Update request status.
- Mark services as completed.
- Communicate with customers through MVP chat.
- View ratings/reviews.
- Receive in-app notifications.

## 3.3 Admin features

The admin system is a **web application** and is planned to be built separately.

The MVP admin system must support provider admission and verification.

At minimum, administrators should be able to:

- Sign in securely.
- View provider applications.
- Review provider information.
- Review submitted verification information/documents where applicable.
- Approve a provider.
- Reject a provider.
- Mark a provider as verified.
- View basic provider/request/user information.
- Manage inappropriate/problematic content where necessary.

The admin web application does not need to be fully implemented in the first mobile-app implementation pass, but the backend and database must be designed so the admin application can be added without restructuring the system.

---

# 4. Service Categories

The MVP should start with a practical set of local-service categories.

Initial categories:

- Plumber
- Electrician
- Cleaner
- Mechanic
- Carpenter
- Painter
- Tutor
- Beauty Services
- Moving / Transport
- Computer / Phone Repair

The architecture must **not hardcode categories throughout the Flutter application or backend**.

Categories should be represented as database records so administrators can add/edit categories later.

---

# 5. User Roles

There are three system roles:

```text
CUSTOMER
PROVIDER
ADMIN
```

## 5.1 Customer

A customer searches for providers and requests services.

## 5.2 Provider

A provider offers one or more services and receives service requests.

## 5.3 Admin

An administrator manages platform-level operations, particularly provider admission and verification.

Role-based authorization must be enforced by the backend.

A Flutter client must never be trusted to enforce authorization by itself.

---

# 6. Provider Admission and Verification

Provider verification is a core MVP requirement.

## 6.1 Provider lifecycle

A provider should have a verification/admission state similar to:

```text
PENDING
APPROVED
REJECTED
SUSPENDED
```

The exact naming may be adjusted during implementation, but the underlying states must be represented clearly.

## 6.2 Provider admission flow

```text
Provider registers
        ↓
Creates provider profile
        ↓
Selects services/categories
        ↓
Submits admission/verification information
        ↓
Status = PENDING
        ↓
Admin reviews application
        ↓
       ┌───────────────┐
       ↓               ↓
   APPROVED         REJECTED
       ↓
Provider can operate normally
```

## 6.3 Marketplace visibility

The system should distinguish between:

- registered providers;
- approved providers;
- verified providers.

Only providers that satisfy the marketplace's active/approved requirements should appear as normal searchable providers.

The `verified` state must be available as a filter.

---

# 7. Provider Discovery

Discovery is one of the primary MVP features.

Customers must be able to:

### Location

- Find providers near their current location.

### Search

- Search by provider name.
- Search by service/category.

### Filters

- Distance.
- Rating.
- Verified status.

The backend should perform filtering and pagination rather than downloading the entire provider database to the mobile device.

---

# 8. Location Architecture

The mobile application should obtain the customer's current location using Flutter-compatible location services.

Provider profiles should contain a usable geographic location.

At MVP level, the system should support:

- latitude;
- longitude;
- service area/location metadata;
- distance-based provider discovery.

The backend should calculate or query provider proximity efficiently.

### Important architectural rule

Do not design the provider-search API in a way that requires rewriting the database later to support geographic queries.

The initial implementation may use PostgreSQL geographic calculations if appropriate. If a geospatial extension is used, keep it isolated behind the repository/service layer.

---

# 9. Provider Profile

A provider profile should contain enough information for a customer to make a decision.

At minimum:

- Provider name.
- Profile image where available.
- Description/bio.
- Service categories.
- Service details.
- Location/service area.
- Verification status.
- Average rating.
- Number of reviews.
- Relevant contact/request information.
- Availability information if implemented as a simple field.

Do not introduce a complex scheduling/calendar system into MVP.

---

# 10. Service Request System

The service request is the central business object of YegnaConnect.

## 10.1 Request creation

A customer should be able to create a request from a provider profile.

The request should contain, as appropriate:

- Customer.
- Provider.
- Service/category.
- Description.
- Requested location.
- Coordinates where applicable.
- Creation time.
- Status.
- Completion time.
- Cancellation information where applicable.

## 10.2 Request lifecycle

The canonical MVP lifecycle is:

```text
PENDING
   ↓
ACCEPTED
   ↓
IN_PROGRESS
   ↓
COMPLETED
```

Alternative terminal paths:

```text
PENDING → REJECTED
PENDING → CANCELLED
ACCEPTED → CANCELLED
IN_PROGRESS → CANCELLED
```

The exact cancellation rules should be implemented consistently and validated by the backend.

## 10.3 Status ownership

Customer:

- Creates request.
- Can cancel eligible requests.
- Views request status.
- Views request history.
- Reviews completed service.

Provider:

- Accepts request.
- Rejects request.
- Updates accepted request to in-progress.
- Marks service completed.
- Cancels eligible requests.

Backend:

- Validates every state transition.

The frontend must never be allowed to arbitrarily set a request to any status.

---

# 11. Rescheduling

Rescheduling is included as a growth-friendly concept but must remain lightweight in MVP.

If the implementation requires a scheduled service date/time, support a simple requested/confirmed service time field.

Do **not** build a full calendar, recurring schedule, appointment engine, or complex availability-management system.

The architecture should leave room for a richer scheduling system after MVP.

---

# 12. Customer ↔ Provider Chat

Chat is included in MVP.

## 12.1 Purpose

Chat exists to support communication around an active service request.

## 12.2 MVP chat requirements

Users should be able to:

- Open a conversation associated with a service request.
- Send text messages.
- View message history.
- See message timestamps.
- Receive notifications for new messages.

A conversation should be associated with a specific request rather than being an unrestricted global chat.

## 12.3 MVP limitations

Do not implement:

- Voice calls.
- Video calls.
- Complex group chats.
- Social feeds.
- Stories.
- Reactions.
- Advanced attachments unless required later.

The architecture should allow attachments and richer messaging to be added later.

---

# 13. Reviews and Ratings

Reviews are only available after a service is completed.

## 13.1 MVP rule

A customer can leave a **1–5 star rating** after a completed service request.

The same request must not be reviewed more than once.

## 13.2 Review model

At minimum:

- Request ID.
- Customer ID.
- Provider ID.
- Rating.
- Created timestamp.

A written review/comment may be supported if the existing UI or implementation includes it, but the mandatory MVP rating is 1–5 stars.

## 13.3 Rating calculation

Provider profiles should expose:

- average rating;
- total number of reviews.

The backend should calculate/update these values safely.

---

# 14. Notifications

MVP uses **in-app notifications only**.

No push notifications are required at this stage.

Notifications should cover important events such as:

- New service request.
- Request accepted.
- Request rejected.
- Request cancelled.
- Request status changed.
- Service completed.
- New chat message.
- Provider verification approved.
- Provider verification rejected.
- Review-related events where useful.

Notifications should be stored in the database so they can be viewed later.

---

# 15. Offline Request Queue

Offline support is a required MVP feature.

## 15.1 Objective

A customer should be able to prepare and submit a service request even when internet connectivity is temporarily unavailable.

The mobile application stores the request locally and synchronizes it when connectivity returns.

## 15.2 Required behavior

```text
User creates request
        ↓
Internet available?
    ┌───────┴────────┐
   YES              NO
    ↓                ↓
Send API       Save locally
    ↓                ↓
Success          Queue request
                     ↓
              Connection returns
                     ↓
                Sync with API
                     ↓
                 Success
```

## 15.3 Important backend requirement

Offline synchronization must be **idempotent**.

The client must generate a unique local/request synchronization identifier.

If the same queued request is submitted more than once because of retries, the backend must not create duplicate service requests.

## 15.4 Local storage

Use an appropriate local persistence mechanism in Flutter.

SQLite is preferred for structured offline request data if the project already uses or adopts SQLite.

Do not use an in-memory-only queue.

---

# 16. Authentication

The MVP requires secure authentication.

## 16.1 Required operations

- Registration.
- Login.
- Logout.
- Token/session persistence.
- Authenticated API requests.
- Password hashing.
- Authorization.
- Current-user retrieval.

JWT is the expected authentication approach unless the existing implementation has already selected another secure mechanism.

## 16.2 Security

Passwords must never be stored as plaintext.

Use a reputable password hashing algorithm/library such as bcrypt or Argon2.

JWT secrets must come from environment variables.

Never commit secrets to Git.

---

# 17. Existing Frontend Work

The following frontend work already exists and should be treated as completed unless changes are required for integration:

- Landing page/screen.
- Splash screen.
- Sign-in page/screen.
- Other existing frontend work already present in the project.

## Agent rule

**Do not unnecessarily rebuild existing screens.**

If an existing screen is already functional and consistent with the YegnaConnect product:

1. Preserve it.
2. Integrate it with the new architecture/backend.
3. Only modify it where necessary.

If a screen is incomplete or incompatible with the required functionality:

- improve it rather than discarding it;
- preserve the established visual identity where possible.

The agent may edit existing frontend code when required to make the application functional.

After existing screens are integrated, continue implementing the missing application functionality instead of repeatedly redesigning completed pages.

---

# 18. Design Direction

YegnaConnect uses a simple, modern, minimalist visual identity.

Primary visual direction:

- Lemon green.
- Light blue.
- Burgundy/wine-like accent.
- Clean whitespace.
- Rounded but restrained UI elements.
- Simple iconography.
- Easy-to-read typography.
- Mobile-first interaction patterns.

Do not introduce unrelated colors or a completely different visual language.

The existing UI should remain the visual reference.

---

# 19. Mobile Application Screens

The exact screen names may vary, but the MVP should cover these functional areas.

## Authentication

- Splash.
- Landing.
- Sign in.
- Sign up.
- Forgot/reset password if authentication implementation requires it.

## Customer

- Home/discovery.
- Search.
- Filter interface.
- Provider results.
- Provider profile.
- Create request.
- Request details.
- Active requests.
- Request history.
- Chat.
- Notifications.
- Reviews.
- Customer profile/settings.

## Provider

- Provider dashboard/home.
- Provider profile.
- Provider setup.
- Verification/admission.
- Incoming requests.
- Request details.
- Active services.
- Completed services.
- Chat.
- Notifications.
- Reviews received.
- Provider profile/settings.

The agent should reuse shared components where appropriate.

---

# 20. Backend Technology Stack

## Required stack

```text
Node.js
Express.js
PostgreSQL
Sequelize
JWT
dotenv
```

Additional packages may be introduced only when they solve a concrete implementation requirement.

Potential examples:

- bcrypt/Argon2 for password hashing.
- validation library such as Joi/Zod/express-validator.
- CORS.
- structured logging.
- file upload/storage library if provider verification requires documents.
- WebSocket technology for real-time chat if needed.

Do not add packages merely because they are popular.

---

# 21. Backend Architecture

Use a modular structure that can grow.

A reasonable structure is:

```text
backend/
├── src/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── repositories/
│   ├── validators/
│   ├── utils/
│   ├── migrations/
│   ├── seeders/
│   ├── app.js
│   └── server.js
├── .env
├── .env.example
├── package.json
└── README.md
```

The agent may adapt this structure to the existing repository, but the separation of concerns should remain.

### Controllers

Handle HTTP requests/responses.

### Services

Contain business logic.

### Repositories/data-access

Contain database interaction where useful.

### Models

Define Sequelize database models and relationships.

### Middleware

Handle:

- authentication;
- authorization;
- validation;
- errors;
- request processing.

### Routes

Define versioned API endpoints.

---

# 22. API Design

Use RESTful APIs.

Version the API:

```text
/api/v1/...
```

Example endpoint groups:

```text
/api/v1/auth
/api/v1/users
/api/v1/providers
/api/v1/services
/api/v1/categories
/api/v1/requests
/api/v1/reviews
/api/v1/notifications
/api/v1/chats
/api/v1/messages
/api/v1/admin
```

Exact endpoint names may be adjusted, but the API must remain predictable and consistent.

---

# 23. Suggested API Surface

## Authentication

```text
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
GET    /api/v1/auth/me
```

## Providers

```text
GET    /api/v1/providers
GET    /api/v1/providers/:id
POST   /api/v1/providers/profile
PATCH  /api/v1/providers/profile
POST   /api/v1/providers/verification
GET    /api/v1/providers/me
```

The provider list endpoint must support parameters for:

- search;
- category;
- latitude;
- longitude;
- distance;
- rating;
- verified;
- pagination.

Example concept:

```text
GET /api/v1/providers?category=plumber&lat=...&lng=...&radius=10&minRating=4&verified=true&search=...
```

## Categories

```text
GET /api/v1/categories
GET /api/v1/categories/:id
```

## Requests

```text
POST   /api/v1/requests
GET    /api/v1/requests
GET    /api/v1/requests/:id
PATCH  /api/v1/requests/:id/status
POST   /api/v1/requests/:id/cancel
```

## Reviews

```text
POST   /api/v1/requests/:id/review
GET    /api/v1/providers/:id/reviews
```

## Notifications

```text
GET    /api/v1/notifications
PATCH  /api/v1/notifications/:id/read
PATCH  /api/v1/notifications/read-all
```

## Chat

```text
GET    /api/v1/requests/:id/chat
GET    /api/v1/requests/:id/messages
POST   /api/v1/requests/:id/messages
```

## Admin

```text
GET    /api/v1/admin/providers/pending
GET    /api/v1/admin/providers/:id
PATCH  /api/v1/admin/providers/:id/approve
PATCH  /api/v1/admin/providers/:id/reject
PATCH  /api/v1/admin/providers/:id/verify
```

The actual implementation should document all endpoints once built.

---

# 24. API Response Standard

Responses should use a consistent structure.

Example success:

```json
{
  "success": true,
  "data": {},
  "message": "Request created successfully"
}
```

Example error:

```json
{
  "success": false,
  "message": "Unable to create request",
  "error": {
    "code": "REQUEST_VALIDATION_ERROR",
    "details": []
  }
}
```

Do not leak stack traces or sensitive internal errors to clients in production.

---

# 25. Database Design

The database should be relational and normalized.

Core entities should include:

```text
User
ProviderProfile
Category
Service
ServiceRequest
Review
Notification
Conversation
Message
ProviderVerification
```

Additional entities may be added where genuinely necessary.

---

# 26. Core Relationships

Conceptual relationship:

```text
User
 ├── Customer identity
 └── ProviderProfile
        ├── ProviderVerification
        ├── Services
        ├── Reviews
        └── ServiceRequests

Category
 └── Services

ServiceRequest
 ├── Customer
 ├── Provider
 ├── Service
 ├── Conversation
 └── Review

Conversation
 └── Messages

User
 └── Notifications
```

Use foreign keys and appropriate indexes.

---

# 27. Important Database Fields

## User

Suggested fields:

```text
id
name
email
phone
passwordHash
role
profileImage
createdAt
updatedAt
```

Add fields only where justified.

## ProviderProfile

Suggested:

```text
id
userId
bio
latitude
longitude
serviceArea
verificationStatus
isActive
averageRating
reviewCount
createdAt
updatedAt
```

## Category

```text
id
name
slug
description
isActive
createdAt
updatedAt
```

## Service

```text
id
providerId
categoryId
title
description
isActive
createdAt
updatedAt
```

## ServiceRequest

```text
id
customerId
providerId
serviceId
description
latitude
longitude
locationDescription
status
clientRequestId
createdAt
acceptedAt
startedAt
completedAt
cancelledAt
updatedAt
```

## Review

```text
id
requestId
customerId
providerId
rating
comment
createdAt
updatedAt
```

## Notification

```text
id
userId
type
title
message
data
isRead
createdAt
```

## Conversation

```text
id
requestId
createdAt
updatedAt
```

## Message

```text
id
conversationId
senderId
message
createdAt
updatedAt
```

## ProviderVerification

```text
id
providerId
status
submittedData
reviewedBy
reviewedAt
rejectionReason
createdAt
updatedAt
```

The actual Sequelize schema should use appropriate UUID/integer choices consistently.

---

# 28. Database Constraints

Enforce important business rules at the database and service layers where practical.

Examples:

- Unique email.
- Valid user roles.
- Valid request statuses.
- One review per service request.
- Foreign-key integrity.
- Provider profile belongs to a provider user.
- Review belongs to a completed request.
- Message belongs to an authorized conversation.
- Categories have unique slugs.

---

# 29. Flutter Architecture

The Flutter application should use a maintainable feature-based architecture.

A reasonable structure:

```text
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   ├── routing/
│   └── utils/
├── features/
│   ├── auth/
│   ├── home/
│   ├── providers/
│   ├── requests/
│   ├── chat/
│   ├── reviews/
│   ├── notifications/
│   ├── profile/
│   └── provider_dashboard/
├── shared/
│   ├── widgets/
│   └── models/
└── main.dart
```

Adapt this to the existing Flutter project instead of blindly recreating it.

---

# 30. Flutter State Management

The project should use a proper state-management solution.

If the existing project already has one, preserve it.

If none has been selected, **Riverpod is preferred** for this project.

Avoid putting business logic directly inside widgets.

UI widgets should not directly contain database/API logic.

---

# 31. Flutter Networking

Create a centralized API client.

It should handle:

- Base URL.
- Authentication headers.
- JSON serialization.
- Request errors.
- Timeouts.
- Token management.
- Retry behavior where appropriate.

Do not scatter raw HTTP calls throughout widgets.

---

# 32. Offline Architecture

Offline functionality should be implemented as a first-class feature.

Recommended conceptual layers:

```text
UI
 ↓
State / Controller
 ↓
Repository
 ↓
Local Data Source ←→ Remote Data Source
 ↓                    ↓
SQLite/local DB       REST API
```

The repository decides whether data should come from local storage, remote API, or synchronization logic.

---

# 33. Offline Synchronization Rules

Every queued request should have:

- local ID;
- server ID once synchronized;
- synchronization state;
- retry count;
- created timestamp;
- last synchronization attempt;
- error information where useful.

Possible local states:

```text
PENDING_SYNC
SYNCING
SYNCED
FAILED
```

A failed request must not disappear.

The user should be able to see an appropriate status and retry.

---

# 34. Error, Loading, and Empty States

Every network-driven feature must implement:

### Loading

Display a clear loading state.

### Empty

Explain when there is no data.

Example:

> No nearby providers found.

### Error

Display a human-readable error and provide retry where appropriate.

### Offline

Explain when the device is offline and what the user can still do.

Never leave the UI stuck on an indefinite spinner.

---

# 35. Validation

Validation must exist on both:

- Flutter client;
- Node.js backend.

Client validation improves UX.

Backend validation provides actual security.

Never trust:

- user role;
- provider ID;
- customer ID;
- request status;
- review ownership;
- permissions;
- prices or other future business fields

sent from the client.

The backend must derive sensitive identity information from the authenticated user.

---

# 36. Authorization Rules

Examples:

### Customer

Can:

- create requests as themselves;
- view their own requests;
- cancel their eligible requests;
- send messages in conversations they belong to;
- review their completed requests.

Cannot:

- change another customer's requests;
- approve providers;
- change provider verification;
- modify another user's profile.

### Provider

Can:

- view requests assigned to themselves;
- update their own request statuses;
- manage their own provider profile;
- submit verification information;
- chat in their own request conversations.

Cannot:

- approve themselves;
- approve other providers;
- manipulate another provider's rating;
- modify unrelated requests.

### Admin

Can:

- review provider applications;
- approve/reject/verify providers;
- perform authorized moderation/admin operations.

---

# 37. Security Requirements

The implementation must:

- Hash passwords.
- Use JWT securely.
- Keep secrets in `.env`.
- Provide `.env.example`.
- Never commit `.env`.
- Validate incoming data.
- Sanitize/handle user-generated content appropriately.
- Apply authorization middleware.
- Avoid exposing internal errors.
- Use secure CORS configuration appropriate for deployment.
- Avoid hardcoded credentials.
- Avoid trusting client-supplied role/user IDs.
- Protect admin endpoints separately.

The agent should also update `.gitignore` if necessary.

---

# 38. Environment Configuration

At minimum, configuration should support:

```text
PORT=
DATABASE_URL=
DB_HOST=
DB_PORT=
DB_NAME=
DB_USER=
DB_PASSWORD=
JWT_SECRET=
JWT_EXPIRES_IN=
```

Additional variables may be added for:

- frontend API URL;
- storage;
- chat;
- external services;
- deployment.

Provide:

```text
.env.example
```

with placeholder values.

Never put real secrets into source control.

---

# 39. Localization

YegnaConnect is intended for Ethiopian users.

The application should be architected for:

- English;
- Amharic.

If full localization is not already implemented, at minimum avoid hardcoding user-facing strings throughout business logic.

Prepare a localization layer so additional languages can be added later.

---

# 40. Admin Web Application

The admin interface will be built after the initial mobile MVP work.

The backend must therefore expose clean admin APIs.

The admin web app should eventually support:

- Admin authentication.
- Provider applications.
- Provider verification.
- User/provider overview.
- Request overview.
- Moderation.
- Basic platform statistics.

The mobile app must not contain admin-only functionality.

---

# 41. Testing Requirements

The MVP should not be considered complete simply because the application compiles.

## Backend tests

At minimum test:

- Registration.
- Login.
- Authentication.
- Authorization.
- Provider admission.
- Provider verification.
- Provider discovery.
- Request creation.
- Request state transitions.
- Cancellation.
- Review creation.
- Duplicate review prevention.
- Notifications.
- Chat authorization.
- Offline request idempotency.

## Flutter tests

At minimum test critical flows:

- Login.
- Provider discovery.
- Filters.
- Provider profile.
- Request creation.
- Request state display.
- Review submission.
- Notification display.
- Offline queue behavior.

## Manual end-to-end test

A complete happy-path test must work:

```text
Register customer
        ↓
Register provider
        ↓
Provider submits verification
        ↓
Admin approves provider
        ↓
Customer searches provider
        ↓
Customer opens provider profile
        ↓
Customer creates request
        ↓
Provider receives request
        ↓
Provider accepts
        ↓
Provider starts service
        ↓
Provider completes service
        ↓
Customer reviews provider
```

---

# 42. Git and Development Practices

Use Git throughout development.

Commit changes in meaningful units.

Examples:

```text
feat(auth): implement JWT authentication
feat(providers): add provider discovery API
feat(requests): implement service request lifecycle
feat(chat): add request-based messaging
feat(notifications): add in-app notifications
feat(offline): implement request synchronization
fix(auth): handle expired tokens
test(requests): add request lifecycle tests
```

Do not make enormous commits containing unrelated features.

---

# 43. AI Agent Development Contract

The coding agent MUST follow these principles.

## Rule 1 — Inspect before changing

Before implementing anything:

- inspect the repository;
- inspect existing Flutter screens;
- inspect existing Node.js code;
- inspect existing database configuration;
- inspect `package.json`;
- inspect Flutter dependencies;
- inspect `.env`/`.env.example`;
- identify existing architecture.

Do not assume the repository is empty.

## Rule 2 — Preserve working code

If an existing feature works, do not rewrite it without a reason.

## Rule 3 — Integrate instead of duplicate

Do not create duplicate authentication systems, API clients, themes, models, or state-management systems.

## Rule 4 — Backend is authoritative

Business rules and authorization belong on the backend.

## Rule 5 — Build incrementally

Implement and verify one coherent feature at a time.

## Rule 6 — Do not fake functionality

Do not use mock data as a substitute for a feature that is supposed to work with the backend.

Temporary mocks are acceptable during isolated UI development but must be removed/replaced before completion.

## Rule 7 — Keep the architecture extensible

Implement today's MVP without making future features unnecessarily difficult.

## Rule 8 — Avoid premature complexity

Do not build:

- microservices;
- Kubernetes;
- event-driven distributed infrastructure;
- complex payment systems;
- recommendation engines;
- unnecessary AI systems

for this MVP.

A modular monolith is the preferred backend architecture.

## Rule 9 — Document important decisions

When a significant architectural decision is required, document it in the repository.

## Rule 10 — Keep API and client synchronized

Whenever an API contract changes:

- update backend;
- update Flutter models/repositories;
- update relevant tests;
- update API documentation.

---

# 44. Implementation Order

The recommended build order is:

## Phase 0 — Repository audit

- Inspect current project.
- Identify existing frontend.
- Identify existing backend.
- Identify existing dependencies.
- Identify database configuration.
- Identify incomplete work.

## Phase 1 — Backend foundation

- Express application.
- Environment configuration.
- PostgreSQL connection.
- Sequelize configuration.
- Base error handling.
- Base response format.
- API versioning.
- Authentication foundation.

## Phase 2 — Database

Create migrations/models for:

- Users.
- Categories.
- Provider profiles.
- Services.
- Provider verification.
- Requests.
- Reviews.
- Notifications.
- Conversations.
- Messages.

Add relationships and indexes.

## Phase 3 — Authentication

Implement:

- Registration.
- Login.
- JWT.
- Current user.
- Authentication middleware.
- Role authorization.

Integrate existing Flutter authentication UI.

## Phase 4 — Provider onboarding

Implement:

- Provider profile.
- Service categories.
- Services.
- Provider location.
- Verification submission.
- Verification state.

## Phase 5 — Provider discovery

Implement:

- Location.
- Nearby search.
- Category search.
- Provider name search.
- Distance filter.
- Rating filter.
- Verified filter.
- Pagination.

Connect this to Flutter.

## Phase 6 — Service requests

Implement:

- Request creation.
- Request list.
- Request details.
- Status lifecycle.
- Cancellation.
- Provider acceptance/rejection.
- Service start/completion.

## Phase 7 — Chat

Implement request-specific customer/provider messaging.

## Phase 8 — Notifications

Implement persistent in-app notifications.

## Phase 9 — Reviews

Implement 1–5 star reviews after completed requests.

## Phase 10 — Offline synchronization

Implement:

- local request storage;
- queue;
- connectivity detection;
- synchronization;
- idempotency;
- retry/failure handling.

## Phase 11 — UI integration/polish

Complete missing screens and connect all flows.

Do not spend the majority of development time redesigning already-completed screens.

## Phase 12 — Testing

Run:

- backend tests;
- Flutter tests;
- integration tests;
- manual end-to-end testing.

## Phase 13 — MVP stabilization

Fix:

- crashes;
- API inconsistencies;
- authorization bugs;
- synchronization bugs;
- UI dead ends;
- loading/error states;
- data integrity issues.

---

# 45. Definition of MVP Complete

YegnaConnect MVP is complete when all of the following are true:

- [ ] Customer registration works.
- [ ] Customer login works.
- [ ] Provider registration works.
- [ ] Provider admission works.
- [ ] Provider verification workflow works.
- [ ] Approved providers can appear in discovery.
- [ ] Customer location can be obtained.
- [ ] Nearby provider discovery works.
- [ ] Provider-name search works.
- [ ] Category search works.
- [ ] Distance filtering works.
- [ ] Rating filtering works.
- [ ] Verified filtering works.
- [ ] Provider profiles work.
- [ ] Customer can create a service request.
- [ ] Provider can receive the request.
- [ ] Provider can accept/reject the request.
- [ ] Request status transitions work.
- [ ] Eligible users can cancel requests.
- [ ] Provider can mark service in progress.
- [ ] Provider can mark service completed.
- [ ] Customer can review completed service.
- [ ] Duplicate reviews are prevented.
- [ ] Customer/provider request-based chat works.
- [ ] In-app notifications work.
- [ ] Offline request queue works.
- [ ] Offline requests synchronize successfully.
- [ ] Duplicate synchronization does not create duplicate requests.
- [ ] Loading states work.
- [ ] Empty states work.
- [ ] Error states work.
- [ ] Authentication and authorization are enforced.
- [ ] Secrets are not committed.
- [ ] Database migrations work from a clean environment.
- [ ] Backend tests for critical business logic pass.
- [ ] Critical Flutter flows are tested.
- [ ] End-to-end customer/provider flow works.

---

# 46. Explicitly Out of MVP

The following should NOT be implemented unless explicitly requested later:

- Online payments.
- Payment gateway integration.
- Subscription plans.
- Provider commissions.
- Complex pricing engine.
- Full appointment/calendar system.
- Recurring appointments.
- Push notifications.
- SMS notifications.
- Email notification system.
- Voice calls.
- Video calls.
- Social feed.
- Stories.
- Advanced social features.
- AI recommendations.
- AI chatbot.
- Advanced analytics.
- Complex loyalty system.
- Multi-vendor payment settlement.
- Cryptocurrency.
- Complex business accounting.
- Enterprise accounts.

Do not let these features expand the MVP.

---

# 47. Post-MVP Growth Roadmap

The MVP architecture should make future development possible without requiring a complete rewrite.

Potential post-MVP areas:

## Payments

- Telebirr.
- Chapa.
- Other Ethiopian payment providers.
- Escrow/payment confirmation.
- Provider payouts.

## Advanced scheduling

- Provider availability.
- Calendar.
- Time slots.
- Rescheduling.
- Recurring services.

## Notifications

- Push notifications.
- SMS.
- Email.

## Advanced chat

- Images.
- Documents.
- Voice messages.
- Rich messaging.

## Trust and safety

- Identity verification.
- More advanced provider verification.
- Report/block.
- Dispute resolution.
- Safety moderation.

## Discovery

- Better ranking.
- Personalized recommendations.
- Availability-aware search.
- Service popularity.

## Provider tools

- Earnings dashboard.
- Analytics.
- Booking calendar.
- Service management.
- Business profiles.

## Admin

- Analytics dashboard.
- User management.
- Provider management.
- Dispute management.
- Moderation.
- Reports.
- Platform configuration.

## Localization

- More Ethiopian languages.
- Better localized content.
- Regional service/category configuration.

---

# 48. Architectural Growth Principle

The MVP should be built as a **modular monolith**, not as a disposable prototype.

The application should be organized around clear domains:

```text
Auth
Users
Providers
Categories
Services
Requests
Reviews
Notifications
Chat
Verification
Admin
```

Each domain should have clear responsibilities.

This allows the project to evolve toward a larger architecture later without forcing the team to prematurely introduce microservices.

---

# 49. Product Principles

Every implementation decision should respect these principles:

### Simplicity

Build the smallest complete version of the feature.

### Trust

Provider verification and transparent ratings are core to the platform.

### Local relevance

The product is designed for Ethiopian users and local service discovery.

### Reliability

Offline support and clear request states are important because network reliability cannot always be assumed.

### Transparency

Customers should understand provider status, request status, and review information.

### Maintainability

Future developers and agents should be able to understand and extend the system.

### Security

Authentication, authorization, verification, and user data must be treated seriously from MVP.

### No unnecessary complexity

A working modular monolith is better than an over-engineered architecture.

---

# 50. Final Instruction to the AI Coding Agent

Before declaring any feature complete, verify:

```text
1. Is the UI implemented?
2. Is the backend endpoint implemented?
3. Is the database model/migration implemented?
4. Is authentication/authorization correct?
5. Is validation implemented?
6. Is loading/error/empty behavior handled?
7. Is the API integrated with Flutter?
8. Does the feature work with real persisted data?
9. Are important edge cases handled?
10. Are tests or meaningful manual verification available?
```

If the answer to any critical question is no, the feature is not complete.

**Do not stop after generating screens.**

YegnaConnect MVP is a working system, not a collection of static UI screens.

The final product must allow a real customer and a real provider to complete the full service-request lifecycle using the Flutter application and backend, with persistent PostgreSQL data and the required offline behavior.

