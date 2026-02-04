# Specialization Validator - Documentation

## Overview

The **Specialization Validator** is a batch operation tool that validates all specializations in the system to ensure they have the correct number of courses configured per study year. It helps administrators identify and fix specializations that are not properly set up.

## Location

- **UI**: Batch Operations dropdown menu → "Specialization Validator"
- **Files**:
  - Frontend: `COOPERP/NewScreens/UserControls/BatchOperations.ascx`
  - Backend: `COOPERP/App_Code/BatchOperationsHelper.cs`

## Validation Rules

The validator applies the following rules to determine if a specialization is "Fully Set":

### Minimum Course Requirements
| Study Year | Minimum Courses Required |
|------------|-------------------------|
| Year 1     | 5 courses               |
| Year 2     | 5 courses               |

### Maximum Course Limits
| Study Year | Maximum Courses Allowed |
|------------|------------------------|
| Year 1     | 12 courses             |
| Year 2     | 12 courses             |
| Year 3     | 12 courses             |

### Validation Logic
A specialization is marked as **"Fully Set"** only if:
1. Year 1 has at least 5 courses AND no more than 12 courses
2. Year 2 has at least 5 courses AND no more than 12 courses
3. Year 3 has no more than 12 courses (if applicable)

A specialization is marked as **"Not Fully Set"** if:
- Year 1 has fewer than 5 courses
- Year 2 has fewer than 5 courses
- Year 1 has more than 12 courses
- Year 2 has more than 12 courses
- Year 3 has more than 12 courses

## User Interface

### Modal Components

1. **Validation Rules Info Box**
   - Yellow warning box explaining the validation rules
   - Lists minimum and maximum course requirements

2. **Load Summary Button**
   - Fetches all specializations with their course counts
   - Shows loading indicator while processing

3. **Summary Statistics**
   - Total Specializations count
   - Fully Set count (green)
   - Not Fully Set count (red)

4. **Summary Table**
   - Columns: Specialization, Programme, Y1, Y2, Y3, Y4, Students, Status
   - Highlighted cells for years with validation issues (yellow background)
   - Shows student enrollment count per specialization
   - Status column shows "Fully Set" or "Not Fully Set" with issue details

5. **Apply Validation Button**
   - Updates `is_fully_set` field for all specializations based on validation rules
   - Shows confirmation dialog before applying
   - Reports number of specializations updated

## Database Tables

### acad_specialisation
| Column       | Description                          |
|--------------|--------------------------------------|
| spec_id      | Primary key                          |
| spec         | Specialization name                  |
| prog_id      | Foreign key to acad_programme        |
| is_fully_set | 'Yes' or 'No' - validation status    |

### acad_programmecourses
| Column           | Description                          |
|------------------|--------------------------------------|
| specialisation_id| Foreign key to acad_specialisation   |
| study_year       | Study year (1, 2, 3, 4)              |
| course_code      | Course identifier                    |

### acad_student
| Column         | Description                          |
|----------------|--------------------------------------|
| specialisation | Foreign key to acad_specialisation   |

## API Endpoints

### GET ?action=GetSpecSummary
Returns all specializations with course counts and student counts.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "specId": 1,
      "specName": "Computer Science",
      "progId": "BSC-CS",
      "progName": "Bachelor of Science in Computer Science",
      "y1Courses": 8,
      "y2Courses": 7,
      "y3Courses": 6,
      "y4Courses": 4,
      "studentCount": 150,
      "isFullySet": "Yes"
    }
  ]
}
```

### POST ?action=ApplySpecValidation
Applies validation rules to all specializations and updates their status.

**Response:**
```json
{
  "success": true,
  "updatedToYes": 5,
  "updatedToNo": 3
}
```

## Code Structure

### Backend Methods (BatchOperationsHelper.cs)

```csharp
// Data class for specialization summary
public class SpecializationSummary
{
    public int SpecId { get; set; }
    public string SpecName { get; set; }
    public string ProgId { get; set; }
    public string ProgName { get; set; }
    public int Y1Courses { get; set; }
    public int Y2Courses { get; set; }
    public int Y3Courses { get; set; }
    public int Y4Courses { get; set; }
    public int StudentCount { get; set; }
    public string IsFullySet { get; set; }
}

// Get all specializations with their details
public static List<SpecializationSummary> GetSpecializationSummary()

// Apply validation and update is_fully_set status
public static Dictionary<string, int> ApplySpecializationValidation()
```

### Frontend Functions (BatchOperations.ascx)

```javascript
// Modal management
function openSpecValidatorModal()
function closeSpecValidatorModal()
function resetSpecValidatorForm()

// Data loading and rendering
function loadSpecSummary()
function renderSpecSummary(data)

// Apply validation
function applySpecValidation()
```

## Usage Instructions

1. Navigate to a page that includes the BatchOperations user control
2. Click the "Batch Operations" button
3. Select "Specialization Validator" from the dropdown menu
4. Click "Load Specialization Summary" to view all specializations
5. Review the summary table:
   - Yellow highlighted cells indicate validation issues
   - Status column shows what's wrong with each specialization
6. Click "Apply Validation" to update all specialization statuses
7. Confirm the action when prompted
8. View the results showing how many specializations were updated

## Related Features

- **Student Results Validation**: Uses `is_fully_set` to determine if student results can be validated
- **Specialization Management**: `NewSpecialisations.aspx` for managing individual specializations
- **Programme Courses**: `NewProgrammeCourses.aspx` for adding courses to specializations

## Maintenance Notes

- The validation rules are hardcoded in `ApplySpecializationValidation()` method
- To modify rules, update the method in `BatchOperationsHelper.cs`
- Course counts are calculated from `acad_programmecourses` table
- Student counts are calculated from `acad_student` table

## Change Log

| Date       | Version | Changes                                    |
|------------|---------|-------------------------------------------|
| 2026-02-04 | 1.0     | Initial implementation                     |
