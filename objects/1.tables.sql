-------------------------------------------------------------------------------
-- Tables Creation
-------------------------------------------------------------------------------
use g1_examination_system
go
create schema core
go

create table core.users(
    user_id int primary key identity(1,1),
    username varchar(20) unique not null,
    password nvarchar(100) not null,
    user_type varchar(20) not null,
    is_active bit,
    created_at datetime not null default getdate(),
    last_login datetime null,

    constraint CK_users_usertype 
        check (user_type in ('student', 'instructor', 'manager'))
) on fg_core
go

create table core.managers(
    manager_id int primary key identity(1,1),
    user_id int not null,
    name nvarchar(100),
    email varchar(100) unique,

    constraint FK_manager_users foreign key(user_id)
        references core.users(user_id)
) on fg_core
go

create table core.departments(
    department_id int Primary key identity(1, 1),
    name nvarchar(100)
) on fg_core
go

create table core.tracks(
    track_id int Primary key identity(1, 1),
    name nvarchar(100),
    department_id int,
    
    constraint FK_tracks_departments foreign key(department_id)
        references core.departments(department_id)
) on fg_core
go

create table core.branches(
    branch_id int Primary key identity(1, 1),
    name nvarchar(100),
    location nvarchar(100)
) on fg_core
go

create table core.intakes(
    intake_id int primary key identity(1, 1),
    intake_year smallint
) on fg_core
go

create table core.instructors(
    instructor_id int primary key identity(1, 1),
    user_id int not null,
    name nvarchar(100),
    email varchar(100) unique, 
    department_id int,

    constraint FK_instructors_users foreign key(user_id)
        references core.users(user_id),
    constraint FK_instructors_departments foreign key(department_id)
        references core.departments(department_id)

) on fg_core
go

create table core.students(
    student_id int primary key identity(1, 1),
    user_id int not null,
    name nvarchar(100),
    email varchar(100) unique, 
    branch_id int,
    track_id int,
    intake_id int,

    constraint FK_students_users foreign key(user_id)
        references core.users(user_id),
    constraint FK_students_branches foreign key(branch_id)
        references core.branches(branch_id),
    constraint FK_students_tracks foreign key(track_id)
        references core.tracks(track_id),
    constraint FK_students_intakes foreign key(intake_id)
        references core.intakes(intake_id)
) on fg_core
go

create schema courses
go

create table courses.courses(
    course_id int primary key identity(1, 1),
    course_name varchar(50) not null,
    description nvarchar(200),
    max_degree decimal(5, 2) not null default 100.00,
    min_degree decimal(5, 2) not null default 60.00,

    constraint uq_course_name unique(course_name),
    constraint CK_courses_degree_range 
        check(
        max_degree > min_degree 
        and max_degree <= 100.00
        and min_degree >= 60.00
        )
) on fg_courses
go

create table courses.class_offerings(
    class_id int primary key identity(1, 1),
    course_id int not null,
    instructor_id int not null,
    intake_id int not null,
    branch_id int not null,
    track_id int not null,

    constraint FK_class_instructor foreign key(instructor_id)
        references core.instructors(instructor_id),
    constraint FK_class_intakes foreign key(intake_id)
        references core.intakes(intake_id),
    constraint FK_class_branches foreign key(branch_id)
        references core.branches(branch_id),
    constraint FK_class_tracks foreign key(track_id)
        references core.tracks(track_id),
    constraint FK_class_courses foreign key(course_id)
        references courses.courses(course_id)
) on fg_courses
go

create schema questions_bank
go

create table questions_bank.questions(
    question_id int not null primary key identity(1, 1),
    course_id int not null,
    question_text nvarchar(255) not null,
    question_type varchar(10) not null,

    constraint CK_question_question_type 
        check (question_type in ('MC', 'TF', 'text')),
    constraint FK_questions_courses foreign key(course_id)
        references courses.courses(course_id)
) on fg_questions
go

create table questions_bank.options (
    option_id int primary key identity(1, 1),
    question_id int not null,
    option_text nvarchar(255) not null,
    is_correct bit not null default 0,

    constraint FK_options_questions foreign key(question_id)
        references questions_bank.questions(question_id)
) on fg_questions
go

create table questions_bank.accepted_text_answers (
    text_answers_id int primary key identity(1, 1),
    question_id int not null,
    accepted_pattern nvarchar(500) not null,

    constraint FK_textanswers_questions foreign key(question_id)
        references questions_bank.questions(question_id)
) on fg_questions
go

create schema exams
go

create table exams.exams (
    exam_id int primary key identity(1, 1),
    exam_type varchar(50) not null default 'main',
    start_time datetime not null,
    end_time datetime not null,
    total_time int not null,
    total_degree decimal(5, 2) not null,
    class_id int not null,
    extra_time_minutes int null default 0,
    open_book bit not null default 0,
    allow_calculator bit not null default 0,

    constraint ck_exam_type
        check(exam_type in ('main', 'corrective')),
    constraint fk_exams_class foreign key(class_id)
        references courses.class_offerings(class_id),
    constraint ck_exams_time check (end_time > start_time)
) on fg_exams
go

create table exams.exam_questions (
    exam_id int not null,
    question_id int not null,
    question_degree int not null,

    constraint pk_exam_questions primary key (exam_id, question_id),
    constraint fk_exam_questions_exam foreign key(exam_id)
        references exams.exams(exam_id),
    constraint fk_exam_questions_question foreign key(question_id)
        references questions_bank.questions(question_id)
) on fg_exams
go

create table exams.exam_students (
    exam_student_id int primary key identity(1, 1),
    exam_id int not null,
    student_id int not null,
    exam_date date not null,
    start_time time not null,
    end_time time not null,
    -- drop the total_grade 
    submission_time datetime null,

    constraint fk_exam_students_exam foreign key(exam_id)
        references exams.exams(exam_id),
    constraint fk_exam_students_student foreign key(student_id)
        references core.students(student_id),
    constraint ck_exam_students_time check (end_time > start_time),
    constraint uq_exam_students unique (exam_id, student_id)
) on fg_exams
go

create schema answers
go

create table answers.student_answers(
    student_answers_id int primary key identity(1,1),
    exam_student_id int not null,
    question_id int not null,
    option_id int null,
    answer_text nvarchar(255),
    is_correct bit default 0,
    manual_score decimal(5, 2) null,
    auto_match bit default 0,

    constraint fk_studentanswers_examstudent foreign key(exam_student_id)
        references exams.exam_students(exam_student_id),
    constraint fk_studentanswers_question foreign key(question_id)
        references questions_bank.questions(question_id),
    constraint fk_studentanswers_option foreign key(option_id)
        references questions_bank.options(option_id),
    constraint uq_questions_examstudent unique(exam_student_id, question_id),
    constraint ck_auto_match check(auto_match in (0, 1)),
    constraint ck_is_correct check(is_correct in (0, 1))
) on fg_answers
go


create table answers.student_exam_results(
    exam_results_id int primary key identity(1, 1),
    exam_student_id int not null,
    exam_score decimal(5,2),

    constraint fk_exresults_student foreign key(exam_student_id)
        references exams.exam_students(exam_student_id)
) on fg_answers
go

create table answers.class_results(
    class_results_id int primary key identity(1, 1),
    student_id int not null,
    class_id int not null,
    total_score decimal(5,2),
    status bit not null default 0,

    constraint fk_classresults_student foreign key(student_id)
        references core.students(student_id),
    constraint fk_classresults_class foreign key(class_id)
        references courses.class_offerings(class_id),
    constraint ck_status check(status in (0, 1))

) on fg_answers
go

create schema manager_api
go
create schema instructor_api
go
create schema student_api
go
