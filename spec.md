# OpportunityTracker

## Current State
New project. No existing code.

## Requested Changes (Diff)

### Add
- Opportunity data model: id, title, company, role, eligibility, deadline, link, source (WhatsApp/Email/Other), description, tags, createdAt, status (open/closed/saved)
- Backend CRUD: create, list, update, delete opportunities; search/filter by keyword, status, deadline
- Sample seed data: 5-6 realistic internship/opportunity entries
- Frontend: Dashboard with opportunity cards showing company, role, deadline, eligibility, and link
- Frontend: Add opportunity form with paste-in unstructured text field + structured fields
- Frontend: Search bar + filters (status, deadline, source)
- Frontend: Deadline urgency indicators (overdue, due soon, upcoming)
- Frontend: Detail view per opportunity

### Modify
N/A

### Remove
N/A

## Implementation Plan
1. Backend: Define Opportunity type and stable storage; implement create/read/update/delete/search queries
2. Backend: Seed sample data on first init
3. Frontend: Layout with sidebar nav (All, Saved, Deadlines)
4. Frontend: Opportunity card grid with urgency color-coding
5. Frontend: Search + filter bar
6. Frontend: Add/Edit modal with structured form + raw text paste area
7. Frontend: Empty states and loading states
