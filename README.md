<h1 align="center">📝 ITI Examination System</h1>
<p align="center">

<p align="center">
  <img src="assets/ITI.png" alt="ITI Logo" width="200"/>
</p>

<p align="center">
  A database project designed to manage students, exams, questions, and grades efficiently.
</p>

---

## Team Members
- [AbdAelrahman Mostafa Mohamed](https://github.com/Abdo71d)
- [Nora Magdy Mohamed Esmat](https://github.com/noramagdy)
- [Hussein Mohamed Suleiman](https://github.com/husseinmohamed7)
- [Mina Essam Azmy](https://github.com/GitHubUsername)
- [Maher Mahmoud Elmoghazi](https://github.com/GitHubUsername)


## Tech Stack
- SQL Server
- GitHub
- Trello


A database project designed to manage students, exams, questions, and grades efficiently.

ERD

Team Members
AbdAelrahman Mostafa Mohamed
Nora Magdy Mohamed
Hussein Mohamed Suleiman
Mina Essam Azmy
Maher Mahmoud Elmoghazi
Key Features
The system is built to fulfill the following core requirements:

Comprehensive User Management: Supports distinct roles for Training Managers, Instructors, and Students, each with restricted access.
Flexible Course & Exam Management: Instructors can create and schedule exams for their courses, selecting questions from a diverse pool and assigning degrees.
Advanced Question Handling: Supports Multiple Choice (MC), True/False (TF), and Text-based questions with automated grading for MC/TF and intelligent checking for text answers.
Organizational Structure Management: Training managers can define branches, tracks, and academic intakes.
Automated Result Calculation: Stores student answers, calculates correct answers, and determines final student results for each course.
Data Integrity & Security: Ensures data integrity, efficient access, and role-based security with daily automatic backups.
Technical Implementation Overview
The database is implemented in SQL Server, adhering to best practices for data organization, performance, and security. It is structured using dedicated filegroups and schemas to efficiently manage different data domains (e.g., core entities, courses, questions, exams, answers).

The system leverages a comprehensive set of database objects:

Tables: Store all core data related to users, courses, questions, exams, and student answers.
Stored Procedures: Encapsulate all system tasks, ensuring controlled data interaction and business logic enforcement.
Functions: Provide reusable logic for data validation and calculations.
Views: Offer simplified and aggregated data access for reporting and specific user roles.
Triggers: Automate data integrity checks and result calculations upon data modifications.
Indexes: Optimize query performance across critical tables.
Directory Files Tree
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
Roles and Permissions
The system implements a robust role-based access control model with the following database roles:

training_manager: Manages users and core organizational entities.
instructor: Manages courses, questions, and exams.
student: Accesses and takes exams, views personal results.
Permissions are strictly enforced, denying direct access to core data schemas for these roles, ensuring interaction only through their designated API schemas.

Installation and Setup
The database can be set up by executing the Full_Database.sql script. This script handles:

Dropping and recreating the g1_examination_system database (if it exists).
Defining filegroups for optimal data storage.
Creating all schemas, tables, stored procedures, functions, views, and triggers.
Inserting seed data for initial setup.
Defining and granting permissions to server and database roles.
Note: The script contains conditional logic for Linux and Windows file paths for database files. Ensure the correct section is uncommented based on your operating system.

For Docker Users
Just run those command in same directory of Dockerfile

docker build -t examination-system-db .
docker run -d -p 1433:1433 --name sql-examination-system examination-system-db
Tech Stack
SQL Server
GitHub
Trello
Mermaid
VScode
Usage and Testing
The system is designed to be interacted with primarily through the defined stored procedures and views, ensuring a controlled and secure environment. Test sheets containing test queries, their results, and comments are available to validate system functionality.
