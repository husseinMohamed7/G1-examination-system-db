<h1 align="center">📝 ITI Examination System</h1>
<p align="center">

<p align="center">
  <img src="assets/ITI.png" alt="ITI Logo" width="200"/>
</p>

<p align="center">
  A database project designed to manage students, exams, questions, and grades efficiently.
</p>

---
## ERD
```mermaid
---
config:
  look: neo
  theme: neo
  layout: dagre
---
erDiagram
"answers.student_exam_results" {
    int exam_results_id "PK"
          int exam_student_id "FK"
          decimal exam_score ""
}
"answers.class_results" {
    int class_results_id "PK"
          int student_id "FK"
          int class_id "FK"
          decimal total_score ""
          bit status "CHECK"
}
"core.users" {
    int user_id "PK"
          varchar(20) username "UNIQUE"
          nvarchar(100) password ""
          varchar(20) user_type "CHECK"
          bit is_active ""
          datetime created_at ""
          datetime last_login ""
}
"core.managers" {
    int manager_id "PK"
          int user_id "FK"
          nvarchar(100) name ""
          varchar(100) email "UNIQUE"
}
"core.departments" {
    int department_id "PK"
          nvarchar(100) name ""
}
"core.tracks" {
    int track_id "PK"
          nvarchar(100) name ""
          int department_id "FK"
}
"core.branches" {
    int branch_id "PK"
          nvarchar(100) name ""
          nvarchar(100) location ""
}
"core.intakes" {
    int intake_id "PK"
          smallint intake_year ""
}
"core.instructors" {
    int instructor_id "PK"
          int user_id "FK"
          nvarchar(100) name ""
          varchar(100) email "UNIQUE"
          int department_id "FK"
}
"core.students" {
    int student_id "PK"
          int user_id "FK"
          nvarchar(100) name ""
          varchar(100) email "UNIQUE"
          int branch_id "FK"
          int track_id "FK"
          int intake_id "FK"
}
"courses.courses" {
    int course_id "PK"
          varchar(50) course_name "UNIQUE"
          nvarchar(200) description ""
          decimal max_degree "CHECK"
          decimal min_degree "CHECK"
}
"courses.class_offerings" {
    int class_id "PK"
          int course_id "FK"
          int instructor_id "FK"
          int intake_id "FK"
          int branch_id "FK"
          int track_id "FK"
}
"questions_bank.questions" {
    int question_id "PK"
          int course_id "FK"
          nvarchar(255) question_text ""
          varchar(10) question_type "CHECK"
}
"questions_bank.options" {
    int option_id "PK"
          int question_id "FK"
          nvarchar(255) option_text ""
          bit is_correct ""
}
"questions_bank.accepted_text_answers" {
    int text_answers_id "PK"
          int question_id "FK"
          nvarchar(500) accepted_pattern ""
}
"exams.exams" {
    int exam_id "PK"
          varchar(50) exam_type "CHECK"
          datetime start_time "CHECK"
          datetime end_time "CHECK"
          int total_time ""
          decimal total_degree ""
          int class_id "FK"
          int extra_time_minutes ""
          bit open_book ""
          bit allow_calculator ""
}
"exams.exam_questions" {
    int exam_id "FK, PK"
          int question_id "FK, PK"
          int question_degree ""
}
"exams.exam_students" {
    int exam_student_id "PK"
          int exam_id "FK, UNIQUE"
          int student_id "FK, UNIQUE"
          date exam_date ""
          time start_time "CHECK"
          time end_time "CHECK"
          decimal total_grade ""
          datetime submission_time ""
}
"answers.student_answers" {
    int student_answers_id "PK"
          int exam_student_id "FK, UNIQUE"
          int question_id "FK, UNIQUE"
          int option_id "FK"
          nvarchar(255) answer_text ""
          bit is_correct "CHECK"
          decimal manual_score ""
          bit auto_match "CHECK"
}
     "answers.student_exam_results" }|--|| "exams.exam_students": "records results for"
"answers.class_results" }|--|| "core.students": "summarizes performance of"
"answers.class_results" }|--|| "courses.class_offerings": "belongs to class"
"core.managers" }|--|| "core.users": "is user account for"
"core.tracks" |{--o| "core.departments": "is part of"
"core.instructors" }|--|| "core.users": "is user account for"
"core.instructors" |{--o| "core.departments": "teaches in"
"core.students" }|--|| "core.users": "is user account for"
"core.students" |{--o| "core.branches": "attends branch"
"core.students" |{--o| "core.tracks": "enrolled in"
"core.students" |{--o| "core.intakes": "belongs to intake"
"courses.class_offerings" }|--|| "courses.courses": "is offering of"
"courses.class_offerings" }|--|| "core.instructors": "taught by"
"courses.class_offerings" }|--|| "core.intakes": "scheduled for intake"
"courses.class_offerings" }|--|| "core.branches": "held at branch"
"courses.class_offerings" }|--|| "core.tracks": "for track"
"questions_bank.questions" }|--|| "courses.courses": "belongs to course"
"questions_bank.options" }|--|| "questions_bank.questions": "is option for"
"questions_bank.accepted_text_answers" }|--|| "questions_bank.questions": "accepted answer for"
"exams.exams" }|--|| "courses.class_offerings": "assigned to class"
"exams.exam_questions" }|--|| "exams.exams": "part of exam"
"exams.exam_questions" }|--|| "questions_bank.questions": "uses question"
"exams.exam_students" ||--|{ "exams.exams": "taken in exam"
"exams.exam_students" ||--|{ "core.students": "taken by"
"answers.student_answers" ||--|{ "exams.exam_students": "submitted by student"
"answers.student_answers" ||--|{ "questions_bank.questions": "answers question"
"answers.student_answers" |{--o| "questions_bank.options": "chooses option"

```

---
## Team Members
- [AbdAelrahman Mostafa Mohamed](https://github.com/Abdo71d)
- [Nora Magdy Mohamed](https://github.com/noramagdy)
- [Hussein Mohamed Suleiman](https://github.com/husseinmohamed7)
- [Mina Essam Azmy](https://github.com/minaessam95)
- [Maher Mahmoud Elmoghazi](https://github.com/maher-dataconsult)


## Key Features

The system is built to fulfill the following core requirements:

*   **Comprehensive User Management**: Supports distinct roles for Training Managers, Instructors, and Students, each with restricted access.
*   **Flexible Course & Exam Management**: Instructors can create and schedule exams for their courses, selecting questions from a diverse pool and assigning degrees.
*   **Advanced Question Handling**: Supports Multiple Choice (MC), True/False (TF), and Text-based questions with automated grading for MC/TF and intelligent checking for text answers.
*   **Organizational Structure Management**: Training managers can define branches, tracks, and academic intakes.
*   **Automated Result Calculation**: Stores student answers, calculates correct answers, and determines final student results for each course.
*   **Data Integrity & Security**: Ensures data integrity, efficient access, and role-based security with daily automatic backups.

## Technical Implementation Overview

The database is implemented in SQL Server, adhering to best practices for data organization, performance, and security. It is structured using dedicated filegroups and schemas to efficiently manage different data domains (e.g., core entities, courses, questions, exams, answers).

The system leverages a comprehensive set of database objects:
*   **Tables**: Store all core data related to users, courses, questions, exams, and student answers.
*   **Stored Procedures**: Encapsulate all system tasks, ensuring controlled data interaction and business logic enforcement.
*   **Functions**: Provide reusable logic for data validation and calculations.
*   **Views**: Offer simplified and aggregated data access for reporting and specific user roles.
*   **Triggers**: Automate data integrity checks and result calculations upon data modifications.
*   **Indexes**: Optimize query performance across critical tables.

## Directory Files Tree
```
.
├── Full_Database.sql
├── README.md
├── documentation/
│   ├── database_objects_description.pdf
│   ├── Docmentation.pdf
│   ├── ERD.drawio.png
│   └── Team Members Participation.txt
├── introduction/
│   ├── Case_Requirements.pdf
│   └── Case_study.pdf
├── objects/
│   ├── 1.tables.sql
│   ├── 2.indexes.sql
│   ├── 3.views.sql
│   ├── 4.stored_procedures.sql
│   ├── 5.functions.sql
│   └── 6.triggers.sql
├── team_members/
│   ├── Abdelrhman_Participation.sql
│   ├── Hussein_Participation.sql
│   ├── Maher_Participation.sql
│   ├── Mina_Participation.sql
│   ├── Nora_Participation.sql
│   └── Team Members Participation.pdf
└── testing/
    ├── DB_Dummy_Accounts.pdf
    ├── DB_Testing_Script.sql
    └── DB_Testing_sResults.txt
```
main
```
docker run -d -p 1433:1433 --name sql-examination-system examination-system-db
```

## Tech Stack
- SQL Server
- GitHub
- Trello
- Mermaid
- Docker
- VS code

## Usage and Testing

The system is designed to be interacted with primarily through the defined stored procedures and views, ensuring a controlled and secure environment. Test sheets containing test queries, their results, and comments are available to validate system functionality.
main
