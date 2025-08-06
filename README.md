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
erDiagram
Users {
	int user_id PK ""  
	string username  ""  
	string password  ""  
	string user_type  ""  
    bool is_active
    datetime created_at
    datetime last_login
}

Manager {
	int manager_id PK ""  
	int user_id FK ""  
	string name  ""  
	string email  ""  
}

Instructor {
	int instructor_id PK ""  
	int user_id FK ""  
	string name  ""  
	string email  ""  
    int department_id FK ""
}

Student {
	int student_id PK ""  
	int user_id FK ""  
	string name  ""  
	string email  ""  
    int branch_id FK
	int track_id FK
	int intake_id FK
}

Department {
	int department_id PK ""  
	string name  ""  
}

Branch {
	int branch_id PK ""  
	string name  ""  
}

Track {
	int track_id PK ""  
	string name  ""  
}

Intake {
	int intake_id PK ""  
	int year  ""  
}

Course {
	int course_id PK ""  
	string name  ""  
	string description  ""  
	int max_degree  ""  
	int min_degree  ""  
}

Class_Offering {
	int class_id PK ""  
	int instructor_id FK ""  
	int course_id FK ""  
	int branch_id FK ""  
	int track_id FK ""  
	int intake_id FK ""  
}

Exam {
	int exam_id PK ""  
	string exam_type  ""  
	datetime start_time  ""  
	datetime end_time  ""  
	int total_time  ""  
	int total_degree  ""  
	int class_id FK ""  
	int extra_time_minutes  ""  
	bool open_book  ""  
	bool allow_calculator  ""  
}

Exam_Questions {
	int exam_id FK ""  
	int question_id FK ""  
	int question_degree  ""  
}

Exam_Student {
	int exam_student_id PK ""  
	int exam_id FK ""  
	int student_id FK ""  
	int class_id FK ""  
	date exam_date  ""  
	time start_time  ""  
	time end_time  ""  
	int total_grade  ""  
	datetime submission_time  ""  
}

Question_Type {
	int type_id PK ""  
	string type_name  ""  
}

Question {
	int question_id PK ""  
	int type_id FK ""  
	string question_text  ""  
}

Accepted_Text_Answers {
	int id PK ""  
	int question_id FK ""  
	string accepted_pattern  ""  
}

Options {
	int option_id PK ""  
	int question_id FK ""  
	string option_text  ""  
	bool is_correct  ""  
}

Student_Answer {
	int student_answer_id PK ""  
	int exam_student_id FK ""  
	int question_id FK ""  
	int option_id FK "nullable"  
	string answer_text  "nullable"  
	bool is_correct  "" 
    int manual_score 
}

Result {
	int result_id PK ""  
	int student_id FK ""  
	int class_id FK ""  
	int total_score  ""  
	bool status  ""  
}

Users ||--|| Instructor : "has"
Users ||--|| Student : "has"
Users ||--|| Manager : "has"

Department ||--o{ Track : "has"
Instructor ||--o{ Class_Offering : "teaches"
Course ||--o{ Class_Offering : "is_part_of"
Branch ||--o{ Class_Offering : "belongs_to"
Track ||--o{ Class_Offering : "belongs_to"
Intake ||--o{ Class_Offering : "is_for"
Student ||--o{ Class_Offering : "enrolls_in"

Exam ||--o{ Exam_Questions : "has_questions"
Exam ||--o{ Exam_Student : "has_students"
Class_Offering ||--o{ Exam : "has_exams"
Class_Offering ||--o{ Exam_Student : "takes_exam_for"

Question_Type ||--o{ Question : "has"
Question ||--o{ Options : "has"
Question ||--o{ Exam_Questions : "is_part_of"
Question ||--o{ Accepted_Text_Answers : "has"
Question||--o{Student_Answer:"is_answered"
Exam_Student ||--o{ Student_Answer : "provides"
Student ||--o{ Result : "gets"
Class_Offering ||--o{ Result : "belongs_to"
```

---
## Team Members
- [AbdAelrahman Mostafa Mohamed](https://github.com/Abdo71d)
- [Nora Magdy Mohamed](https://github.com/noramagdy)
- [Hussein Mohamed Suleiman](https://github.com/husseinmohamed7)
- [Mina Essam Azmy](https://github.com/minaessam95)
- [Maher Mahmoud Elmoghazi](https://github.com/maher-dataconsult)


## Tech Stack
- SQL Server
- GitHub
- Trello
- Mermaid
- VScode
