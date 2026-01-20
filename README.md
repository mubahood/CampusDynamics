# Campus Dynamics - Student Management System

## Overview
Campus Dynamics is a comprehensive Educational Management Information System (EMIS) built on ASP.NET Web Forms for managing all aspects of higher education institutions.

## Technology Stack
- **Platform:** ASP.NET 4.0 Web Forms
- **UI Framework:** DevExpress v16.1
- **Database:** MySQL 5.x
- **Reporting:** Crystal Reports 13.0
- **ORM:** ADO.NET TableAdapters + DevExpress XPO

## Core Modules

### Academic Management
- **Admissions** - Application processing, applicant tracking, qualification verification
- **Student Information** - Student records, enrollment management, biographical data
- **Results** - Grade capture, transcript generation, academic records
- **Timetables** - Course scheduling and academic calendar
- **Graduate Programs** - Graduate student management

### Financial Management
- **Finance** - Student billing, fee collection, payment tracking
- **Core Accounting** - General ledger, financial reporting
- **Student Ledger** - Individual student account management

### Human Resources
- **Faculty Management** - Faculty information and assignments
- **HR Module** - Staff records and management

### Operations
- **Inventory** - Asset and inventory tracking
- **Residence** - Hostel and dormitory management

## API Endpoints
The system provides REST-like APIs for mobile and external integration:
- `/API/mobileapi.aspx` - Student data, results, ledger (JSON format)
- `/API/api_applicant_data.aspx` - Applicant information
- `/API/api_fees_structure.aspx` - Fee schedules
- `/API/id_verifier.aspx` - Identity verification

## Database Structure
Primary databases:
- `campus_dynamics` - Main operational database
- `campus_dynamics_admissions` - Admissions data
- `campus_dynamics_accounts` - Financial data

## Security
- ASP.NET Forms Authentication
- Role-based access control (Dean, Admin, Faculty, Staff)
- Session management with concurrent login prevention
- Module-level permissions

## Development Setup

### Prerequisites
- Visual Studio 2012 or later
- .NET Framework 4.0
- MySQL Server 5.x
- IIS 7.5 or later
- DevExpress v16.1 components

### Configuration
1. Update connection strings in `web.config`
2. Ensure MySQL databases are accessible
3. Configure IIS application pool (.NET 4.0, Integrated Pipeline)
4. Set appropriate file system permissions for upload folders

## Project Structure
```
├── API/                    # REST API endpoints
├── App_Code/              # Business logic layer
│   ├── Admissions/       # Admissions BLL
│   ├── Finance/          # Financial BLL
│   ├── Results/          # Academic results BLL
│   ├── StudentInfo/      # Student data BLL
│   └── ...
├── COOPERP/              # UI resources (CSS, JS, images)
├── UserControls/         # Reusable ASP.NET user controls
├── Security/             # User management pages
└── web.config           # Application configuration

```

## Git Ignore Policy
The following are excluded from version control:
- User upload folders (`Files/`, `Thumb/`)
- Build outputs (`Bin/`, `obj/`)
- Temporary folders (`DXTempFolder/`, `App_Data/UploadTemp/`)
- IDE files (`*.suo`, `.vs/`)
- Backup files (`*.bak`)

## License
Proprietary - Mount Royal University

## Support
For technical support, contact the IT department at Mount Royal University.
