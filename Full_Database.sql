-------------------------------------------------------------------------------
-- database creation
-------------------------------------------------------------------------------
-- if linux:
-------------------------------------------------------------------------------
if exists (select 1 from sys.databases where name = 'g1_examination_system')
begin
    alter database g1_examination_system set single_user with rollback immediate;
    use master;
    drop database g1_examination_system;
end
create database g1_examination_system
ON 
PRIMARY (
    name='g1_examination_system_Data',
    filename='/var/opt/mssql/data/g1_iti/g1_examination_system.mdf',
    size=50MB,
    maxsize=200MB,
    filegrowth=10%
),
filegroup fg_core
(
    name = 'g1_examination_system_fg_core',
    filename = '/var/opt/mssql/data/g1_iti/g1_examination_system_fg_core.ndf',
    size = 20MB,
    maxsize = 100MB,
    filegrowth = 10%
),
filegroup fg_courses
(
    name = 'g1_examination_system_fg_courses',
    filename = '/var/opt/mssql/data/g1_iti/g1_examination_system_fg_courses.ndf',
    size = 10MB,
    maxsize = 100MB,
    filegrowth = 10%
),
filegroup fg_questions
(
    name = 'g1_examination_system_fg_questions',
    filename = '/var/opt/mssql/data/g1_iti/g1_examination_system_fg_questions.ndf',
    size = 10MB,
    maxsize = 100MB,
    filegrowth = 10%
),
filegroup fg_exams
(
    name = 'g1_examination_system_fg_exams',
    filename = '/var/opt/mssql/data/g1_iti/g1_examination_system_fg_exams.ndf',
    size = 10MB,
    maxsize = 100MB,
    filegrowth = 10%
),
filegroup fg_answers
(
    name = 'g1_examination_system_fg_answers',
    filename = '/var/opt/mssql/data/g1_iti/g1_examination_system_fg_answers.ndf',
    size = 10MB,
    maxsize = 100MB,
    filegrowth = 10%
)
log on (
    name='g1_examination_system_Log',
    filename='/var/opt/mssql/data/g1_iti/g1_examination_system_Log.ldf',
    size=10MB,
    maxsize=60MB,
    filegrowth=10%
)
go

-------------------------------------------------------------------------------
-- if windows:
-------------------------------------------------------------------------------

-- if exists (select 1 from sys.databases where name = 'g1_examination_system')
-- begin
--     alter database g1_examination_system set single_user with rollback immediate;
--     use master;
--     drop database g1_examination_system;
-- end
-- create database g1_examination_system
-- on 
-- primary (
--     name = 'g1_examination_system_data',
--     filename = 'c:\program files\microsoft sql server\mssql16.mssqlserver\mssql\data\g1_examination_system.mdf',
--     size = 50mb,
--     maxsize = 200mb,
--     filegrowth = 10%
-- ),
-- filegroup fg_core
-- (
--     name = 'g1_examination_system_fg_core',
--     filename = 'c:\program files\microsoft sql server\mssql16.mssqlserver\mssql\data\g1_examination_system_fg_core.ndf',
--     size = 20mb,
--     maxsize = 100mb,
--     filegrowth = 10%
-- ),
-- filegroup fg_courses
-- (
--     name = 'g1_examination_system_fg_courses',
--     filename = 'c:\program files\microsoft sql server\mssql16.mssqlserver\mssql\data\g1_examination_system_fg_courses.ndf',
--     size = 10mb,
--     maxsize = 100mb,
--     filegrowth = 10%
-- ),
-- filegroup fg_questions
-- (
--     name = 'g1_examination_system_fg_questions',
--     filename = 'c:\program files\microsoft sql server\mssql16.mssqlserver\mssql\data\g1_examination_system_fg_questions.ndf',
--     size = 10mb,
--     maxsize = 100mb,
--     filegrowth = 10%
-- ),
-- filegroup fg_exams
-- (
--     name = 'g1_examination_system_fg_exams',
--     filename = 'c:\program files\microsoft sql server\mssql16.mssqlserver\mssql\data\g1_examination_system_fg_exams.ndf',
--     size = 10mb,
--     maxsize = 100mb,
--     filegrowth = 10%
-- ),
-- filegroup fg_answers
-- (
--     name = 'g1_examination_system_fg_answers',
--     filename = 'c:\program files\microsoft sql server\mssql16.mssqlserver\mssql\data\g1_examination_system_fg_answers.ndf',
--     size = 10mb,
--     maxsize = 100mb,
--     filegrowth = 10%
-- )
-- log on (
--     name = 'g1_examination_system_log',
--     filename = 'c:\program files\microsoft sql server\mssql16.mssqlserver\mssql\data\g1_examination_system_log.ldf',
--     size = 10mb,
--     maxsize = 60mb,
--     filegrowth = 10%
-- );
-- go

-------------------------------------------------------------------------------
-- core schema creation
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

-------------------------------------------------------------------------------
-- courses schema creation
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- questions_bank schema creation
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- exams schema creation
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- answers schema creation
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- api schemas creation
-------------------------------------------------------------------------------
create schema manager_api
go
create schema instructor_api
go
create schema student_api
go

-------------------------------------------------------------------------------
-- Seed data insertion to core and the roles to core.users
-------------------------------------------------------------------------------

insert into core.users(username, password, user_type, is_active)
values
--('test1','P@ssw0rd', 'manager', 1),
('Osama', 'P@ssw0rd', 'manager', 1),
('Sarah', 'P@ssw0rd', 'instructor', 1),
('Youmna', 'P@ssw0rd', 'instructor', 1),
('Hussein7', 'P@ssw0rd', 'student', 1),
('abdlrhman12', 'P@ssw0rd', 'student', 1),
('Mina44', 'P@ssw0rd', 'student', 1),
('Nora23', 'P@ssw0rd', 'student', 1),
('Maher88', 'P@ssw0rd', 'student', 1),
('sa', 'm@ho', 'manager', 1)
go

insert into core.managers(user_id, name, email)
values
--(11, 'test user', 'test1@gmai.com'),
(1, 'Osama Mohamed Ali', 'osama12m@gmail.com'),
(2,'sa','hello@world.com')
go

insert into core.departments(name)
values('data')
go

insert into core.tracks(name, department_id)
values('data engineering', 1)
go

insert into core.branches(name, location)
values('iti-Minia', 'Minia University - Minia')
go

insert into core.intakes(intake_year)
values(2025)
go

insert into core.instructors(user_id, name, email, department_id)
values
(3, 'Youmna Sallama', 'youmna44s@gmail.com', 1),
(2, 'Sarah Emad', 'sarah44e@gmail.com', 1)
go

insert into core.students(user_id, name, email, branch_id, track_id, intake_id)
values
(4, 'Hussein Mohamed', 'hussein7mohamed8@gmail.com', 1, 1, 1),
(5, 'AbdAelrahman Mostafa', 'abdo12m@gmail.com', 1, 1, 1),
(6, 'Mina Essam', 'mina33e@gmail.com', 1, 1, 1),
(7, 'Nora Magdy', 'nora88m@gmail.com', 1, 1, 1),
(8, 'Maher Mahmoud', 'maher244m@gmail.com', 1, 1, 1)
go

-------------------------------------------------------------------------------
-- Roles difinition
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Server role creation(manager)
-- give this role the permisions to alter logins
USE master;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'manager' AND type = 'R')
BEGIN
    CREATE SERVER ROLE manager; -- first account role as db_admin
END
GRANT ALTER ANY LOGIN TO manager;
GO

use g1_examination_system;
create role training_manager; -- 2nd account role
create role instructor;       -- 3rd account role
create role student;          -- 4th account role

grant alter any user to training_manager;
grant alter any role to training_manager;

deny select, insert, update, delete on schema::core to training_manager, instructor, student;
deny select, insert, update, delete on schema::courses to training_manager, instructor, student;
deny select, insert, update, delete on schema::questions_bank to training_manager, instructor, student;
deny select, insert, update, delete on schema::exams to training_manager, instructor, student;
deny select, insert, update, delete on schema::answers to training_manager, instructor, student;
deny select, insert, update, delete on schema::dbo to training_manager, instructor, student;
deny execute on schema::instructor_api to training_manager, student;
deny select on schema::instructor_api to training_manager, student;
deny execute on schema::student_api to training_manager, instructor;
deny select on schema::student_api to training_manager, instructor;
deny execute on schema::manager_api to instructor, student;
deny select on schema::manager_api to instructor, student;

grant execute on schema::manager_api to training_manager;
grant select on schema::manager_api to training_manager;
grant execute on schema::instructor_api to instructor;
grant select on schema::instructor_api to instructor; 
grant execute on schema::student_api to student;
grant select on schema::student_api to student;

-- Manager
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Osama')
BEGIN
    CREATE LOGIN Osama WITH PASSWORD = 'P@ssw0rd';
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Osama')
BEGIN
    CREATE USER Osama FOR LOGIN Osama;
END
GO
ALTER SERVER ROLE manager ADD MEMBER Osama;
ALTER ROLE training_manager ADD MEMBER Osama;
GO

-- Instructors
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Sarah')
BEGIN
    CREATE LOGIN Sarah WITH PASSWORD = 'P@ssw0rd';
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Sarah')
BEGIN
    CREATE USER Sarah FOR LOGIN Sarah;
END
GO
ALTER ROLE instructor ADD MEMBER Sarah;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Youmna')
BEGIN
    CREATE LOGIN Youmna WITH PASSWORD = 'P@ssw0rd';
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Youmna')
BEGIN
    CREATE USER Youmna FOR LOGIN Youmna;
END
GO
ALTER ROLE instructor ADD MEMBER Youmna;
GO

-- Students
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Hussein7')
BEGIN
    CREATE LOGIN Hussein7 WITH PASSWORD = 'P@ssw0rd';
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Hussein7')
BEGIN
    CREATE USER Hussein7 FOR LOGIN Hussein7;
END
GO
ALTER ROLE student ADD MEMBER Hussein7;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'abdlrhman12')
BEGIN
    CREATE LOGIN abdlrhman12 WITH PASSWORD = 'P@ssw0rd';
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'abdlrhman12')
BEGIN
    CREATE USER abdlrhman12 FOR LOGIN abdlrhman12;
END
GO
ALTER ROLE student ADD MEMBER abdlrhman12;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Mina44')
BEGIN
    CREATE LOGIN Mina44 WITH PASSWORD = 'P@ssw0rd';
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Mina44')
BEGIN
    CREATE USER Mina44 FOR LOGIN Mina44;
END
GO
ALTER ROLE student ADD MEMBER Mina44;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Nora23')
BEGIN
    CREATE LOGIN Nora23 WITH PASSWORD = 'P@ssw0rd';
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Nora23')
BEGIN
    CREATE USER Nora23 FOR LOGIN Nora23;
END
GO
ALTER ROLE student ADD MEMBER Nora23;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Maher88')
BEGIN
    CREATE LOGIN Maher88 WITH PASSWORD = 'P@ssw0rd';
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Maher88')
BEGIN
    CREATE USER Maher88 FOR LOGIN Maher88;
END
GO
ALTER ROLE student ADD MEMBER Maher88;
GO

-------------------------------------------------------------------------------
-- Seed data insertion to courses schema
-------------------------------------------------------------------------------

insert into courses.courses(course_name, description, max_degree, min_degree)
values
('sql fundamentals', 'introduction to sql and database management', 100.00, 60.00),
('python programming', 'basic to intermediate python programming', 100.00, 60.00),
('data analysis', 'data analysis using python and pandas', 100.00, 60.00)
go

insert into courses.class_offerings(course_id, instructor_id, intake_id, branch_id, track_id)
values
(1, 2, 1, 1, 1),
(2, 1, 1, 1, 1),
(3, 2, 1, 1, 1)
go

-------------------------------------------------------------------------------
-- Seed data insertion to questions_bank schema
-------------------------------------------------------------------------------

insert into questions_bank.questions(course_id, question_text, question_type)
values
(1, 'what does sql stand for?', 'mc'),
(1, 'select statement is used to retrieve data from database', 'tf'),
(1, 'write the sql command to create a table named students', 'text'),
(1, 'which clause is used to filter rows in sql?', 'mc'),
(1, 'primary key can contain null values', 'tf'),

(2, 'which of the following is the correct way to create a list in python?', 'mc'),
(2, 'python is case-sensitive language', 'tf'),
(2, 'write a python function to calculate factorial of a number', 'text'),
(2, 'what is the output of: print(type(5.0))?', 'mc'),
(2, 'python uses indentation to define code blocks', 'tf'),

(3, 'which library is commonly used for data manipulation in python?', 'mc'),
(3, 'pandas dataframe can store data of different types', 'tf'),
(3, 'write code to read a csv file using pandas', 'text'),
(3, 'what method is used to get basic statistics of a dataframe?', 'mc'),
(3, 'missing values in pandas are represented by nan', 'tf')
go

insert into questions_bank.options(question_id, option_text, is_correct)
values
(1, 'structured query language', 1),
(1, 'simple query language', 0),
(1, 'standard query language', 0),
(1, 'system query language', 0),

(4, 'where', 1),
(4, 'select', 0),
(4, 'from', 0),
(4, 'order by', 0),

(6, '[1, 2, 3, 4]', 1),
(6, '(1, 2, 3, 4)', 0),
(6, '{1, 2, 3, 4}', 0),
(6, 'list(1, 2, 3, 4)', 0),

(9, '<class "float">', 1),
(9, '<class "int">', 0),
(9, '<class "double">', 0),
(9, '<class "number">', 0),

(11, 'pandas', 1),
(11, 'numpy', 0),
(11, 'matplotlib', 0),
(11, 'seaborn', 0),

(14, 'describe()', 1),
(14, 'info()', 0),
(14, 'head()', 0),
(14, 'shape()', 0)
go

insert into questions_bank.options(question_id, option_text, is_correct)
values
(2, 'true', 1),
(2, 'false', 0),
(5, 'true', 0),
(5, 'false', 1),
(7, 'true', 1),
(7, 'false', 0),
(10, 'true', 1),
(10, 'false', 0),
(12, 'true', 1),
(12, 'false', 0),
(15, 'true', 1),
(15, 'false', 0);
go

insert into questions_bank.accepted_text_answers(question_id, accepted_pattern)
values
(3, 'create table students'),
(3, 'create table "students"'),
(3, 'create table [students]'),
(8, 'def factorial'),
(8, 'factorial'),
(8, 'def.*factorial.*return'),
(13, 'pd.read_csv'),
(13, 'pandas.read_csv'),
(13, 'read_csv')
go

-------------------------------------------------------------------------------
-- Seed data insertion to exams schema
-------------------------------------------------------------------------------

insert into exams.exams(exam_type, start_time, end_time, total_time, total_degree, class_id, extra_time_minutes, open_book, allow_calculator)
values
('main', '2025-08-15 09:00:00', '2025-08-15 11:00:00', 120, 100.00, 1, 15, 0, 0),
('main', '2025-08-16 10:00:00', '2025-08-16 12:00:00', 120, 100.00, 2, 15, 0, 1),
('main', '2025-08-17 09:00:00', '2025-08-17 11:30:00', 150, 100.00, 3, 20, 1, 1),
('corrective', '2025-08-25 14:00:00', '2025-08-25 16:00:00', 120, 100.00, 1, 0, 0, 0)
go

insert into exams.exam_questions(exam_id, question_id, question_degree)
values
(1, 1, 20),
(1, 2, 15),
(1, 3, 30),
(1, 4, 20),
(1, 5, 15),

(2, 6, 20),
(2, 7, 15),
(2, 8, 35),
(2, 9, 20),
(2, 10, 10),

(3, 11, 25),
(3, 12, 15),
(3, 13, 35),
(3, 14, 15),
(3, 15, 10),

(4, 1, 25),
(4, 3, 40),
(4, 4, 25),
(4, 5, 10)
go


insert into exams.exam_students(exam_id, student_id, exam_date, start_time, end_time)
values
(1, 1, '2025-08-15', '09:00:00', '11:00:00'),
(1, 2, '2025-08-15', '09:00:00', '11:00:00'),
(1, 3, '2025-08-15', '09:00:00', '11:00:00'),
(1, 4, '2025-08-15', '09:00:00', '11:00:00'),
(1, 5, '2025-08-15', '09:00:00', '11:00:00'),

(2, 1, '2025-08-16', '10:00:00', '12:00:00'),
(2, 2, '2025-08-16', '10:00:00', '12:00:00'),
(2, 3, '2025-08-16', '10:00:00', '12:00:00'),
(2, 4, '2025-08-16', '10:00:00', '12:00:00'),

(3, 2, '2025-08-17', '09:00:00', '11:30:00'),
(3, 3, '2025-08-17', '09:00:00', '11:30:00'),
(3, 5, '2025-08-17', '09:00:00', '11:30:00')
go

-------------------------------------------------------------------------------
-- Seed data insertion to answers schema
-------------------------------------------------------------------------------

-- The trg_auto_grade_student_answer trigger will automatically populate 
-- the student_exam_results and class_results tables when these answers are inserted.
-- Therefore, manual inserts into those tables have been removed.
insert into answers.student_answers(exam_student_id, question_id, option_id, answer_text)
values
(1, 1, 1, null),
(1, 2, 21, null),
(1, 3, null, 'create table students (id int, name varchar(50))'),
(1, 4, 5, null),
(1, 5, 24, null),

(2, 1, 2, null),
(2, 2, 21, null),
(2, 3, null, 'create table students'),
(2, 4, 5, null),
(2, 5, 23, null),

(3, 1, 1, null),
(3, 2, 21, null),
(3, 3, null, 'create table students (student_id int primary key, name nvarchar(100))'),
(3, 4, 6, null),
(3, 5, 24, null),

(6, 6, 9, null),
(6, 7, 25, null),
(6, 8, null, 'def factorial(n): return 1 if n <= 1 else n * factorial(n-1)'),
(6, 9, 13, null),

(7, 6, 9, null),
(7, 7, 25, null),
(7, 8, null, 'def factorial(x): result = 1; for i in range(1, x+1): result *= i; return result'),
(7, 9, 14, null)
go


-------------------------------------------------------------------------------
-- create or alter all stored procedures 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- user management procedures - add, update, delete
-------------------------------------------------------------------------------

-- add new user
-- add the user to core.users and his own table instructor, manager or student
-- add the user to the system login and the role 
create or alter procedure manager_api.sp_add_user
    @username varchar(20),
    @password nvarchar(100),
    @user_type varchar(20),
    @name nvarchar(100) = null,
    @email varchar(100) = null,
    @department_id int = null,
    @branch_id int = null,
    @track_id int = null,
    @intake_id int = null,
    @is_active bit = 1
as
begin
    set nocount on;
    begin try
        begin transaction;
        
        declare @user_id int;
        declare @sql nvarchar(max);
        
        -- insert into users table first
        insert into core.users (username, password, user_type, is_active)
        values (@username, @password, @user_type, @is_active);
        
        set @user_id = scope_identity();
        
        -- insert into specific table
        if @user_type = 'manager'
            insert into core.managers (user_id, name, email) values (@user_id, @name, @email);
        else if @user_type = 'instructor'
            insert into core.instructors (user_id, name, email, department_id) values (@user_id, @name, @email, @department_id);
        else if @user_type = 'student'
            insert into core.students (user_id, name, email, branch_id, track_id, intake_id) values (@user_id, @name, @email, @branch_id, @track_id, @intake_id);
        
        commit transaction;
        
        -- create login and user with elevated privileges
        set @sql = '
        begin try
            -- create login
            create login [' + @username + '] with password = ''' + @password + ''';
            
            -- add to server role if manager
            ' + case when @user_type = 'manager' then 'alter server role manager add member [' + @username + '];' else '' end + '
            
            -- switch to database context
            use [' + db_name() + '];
            
            -- create user
            create user [' + @username + '] for login [' + @username + '];
            
            -- add to database role
            ' + case 
                when @user_type = 'manager' then 'alter role training_manager add member [' + @username + '];'
                when @user_type = 'instructor' then 'alter role instructor add member [' + @username + '];'
                when @user_type = 'student' then 'alter role student add member [' + @username + '];'
                else ''
            end + '
            
            select ''success'' as status;
        end try
        begin catch
            select error_message() as error_message;
        end catch';
        
        -- execute with sysadmin privileges
        exec sp_executesql @sql;
        
        select 
            @user_id as user_id,
            @username as username,
            @user_type as user_type,
            'user created successfully with all privileges' as message;
            
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;

        select 
            ERROR_NUMBER() as error_number,
            ERROR_MESSAGE() as error_message,
            'failed to create user' as status;
            
    end catch
end
go



-------------------------------------------------------------------------------
-- update user info based on what changed
-- we change it in the role and login
-- transactions to ensure we did it all right 
create or alter procedure manager_api.sp_update_user_auth
    @user_id int,
    @new_username varchar(20) = null,
    @new_password nvarchar(100) = null,
    @new_user_type varchar(20) = null,
    @new_is_active bit = null
with execute as owner
as
begin
    set nocount on;
    begin try
        begin transaction;
        
        declare @current_username varchar(20);
        declare @current_password nvarchar(100);
        declare @current_user_type varchar(20);
        declare @current_is_active bit;
        
        -- get current values
        select @current_username = username,
               @current_password = password,
               @current_user_type = user_type,
               @current_is_active = is_active
        from core.users 
        where user_id = @user_id;
        
        if @@rowcount = 0
        begin
            raiserror('user with id %d not found.', 16, 1, @user_id);
            rollback transaction;
            return;
        end

        -- set defaults if null
        set @new_username = isnull(@new_username, @current_username);
        set @new_password = isnull(@new_password, @current_password);
        set @new_user_type = isnull(@new_user_type, @current_user_type);
        set @new_is_active = isnull(@new_is_active, @current_is_active);

        -- update login/user if username or password changed
        if @current_username <> @new_username or @current_password <> @new_password
        begin
            if @current_username <> @new_username
            begin
                -- check if username already exists
                if exists(select 1 from sys.server_principals where name = @new_username)
                begin
                    raiserror('username %s already exists.', 16, 1, @new_username);
                    rollback transaction;
                    return;
                end
                
                -- create new login
                exec('create login [' + @new_username + '] with password = ''' + @new_password + '''');
                
                -- add to server role if manager
                if @new_user_type = 'manager'
                    exec('alter server role manager add member [' + @new_username + ']');
                
                -- create new user
                exec('create user [' + @new_username + '] for login [' + @new_username + ']');

                -- add to database roles
                if @new_user_type = 'manager'
                    exec('alter role training_manager add member [' + @new_username + ']');
                else if @new_user_type = 'instructor'
                    exec('alter role instructor add member [' + @new_username + ']');
                else if @new_user_type = 'student'
                    exec('alter role student add member [' + @new_username + ']');

                -- drop old user and login
                if exists(select 1 from sys.database_principals where name = @current_username)
                    exec('drop user [' + @current_username + ']');
                if exists(select 1 from sys.server_principals where name = @current_username)
                    exec('drop login [' + @current_username + ']');
            end
            else
            begin
                -- just change password
                exec('alter login [' + @current_username + '] with password = ''' + @new_password + '''');
            end
        end

        -- handle role changes if needed
        if @current_user_type <> @new_user_type
        begin
            -- remove from old database role
            if @current_user_type = 'manager'
                exec('alter role training_manager drop member [' + @new_username + ']');
            else if @current_user_type = 'instructor'
                exec('alter role instructor drop member [' + @new_username + ']');
            else if @current_user_type = 'student'
                exec('alter role student drop member [' + @new_username + ']');

            -- remove from old server role if applicable
            if @current_user_type = 'manager'
                exec('alter server role manager drop member [' + @new_username + ']');

            -- add to new database role
            if @new_user_type = 'manager'
                exec('alter role training_manager add member [' + @new_username + ']');
            else if @new_user_type = 'instructor'
                exec('alter role instructor add member [' + @new_username + ']');
            else if @new_user_type = 'student'
                exec('alter role student add member [' + @new_username + ']');

            -- add to new server role if applicable
            if @new_user_type = 'manager'
                exec('alter server role manager add member [' + @new_username + ']');
        end

        -- handle is_active changes
        if @current_is_active <> @new_is_active
        begin
            if @new_is_active = 0
                exec('alter login [' + @new_username + '] disable');
            else
                exec('alter login [' + @new_username + '] enable');
        end

        -- update core.users table
        update core.users 
        set username = @new_username,
            password = @new_password,
            user_type = @new_user_type,
            is_active = @new_is_active
        where user_id = @user_id;

        commit transaction;

        select 
            @user_id as user_id, 
            @new_username as username, 
            @new_user_type as user_type,
            'authentication updated successfully' as message;

    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
            
        declare @errmsg nvarchar(4000) = error_message();
        
        select 
            error_number() as error_number,
            @errmsg as error_message, 
            'failed to update authentication' as status;
            
        raiserror(@errmsg, 16, 1);
    end catch
end
go

-------------------------------------------------------------------------------
-- update user info
-- update based on the user type
create or alter procedure manager_api.sp_update_user_details
    @user_id int,
    @new_name nvarchar(100) = null,
    @new_email varchar(100) = null,
    @new_department_id int = null,
    @new_branch_id int = null,
    @new_track_id int = null,
    @new_intake_id int = null
with execute as owner
as
begin
    set nocount on;
    
    begin try
        declare @user_type varchar(20);
        declare @rows_affected int = 0;

        -- get user type
        select @user_type = user_type 
        from core.users 
        where user_id = @user_id;

        if @user_type is null
        begin
            raiserror('user with id %d not found.', 16, 1, @user_id);
            return;
        end

        -- update based on user type
        if @user_type = 'manager'
        begin
            update core.managers
            set name = isnull(@new_name, name),
                email = isnull(@new_email, email)
            where user_id = @user_id;
            
            set @rows_affected = @@rowcount;
        end
        else if @user_type = 'instructor'
        begin
            update core.instructors
            set name = isnull(@new_name, name),
                email = isnull(@new_email, email),
                department_id = isnull(@new_department_id, department_id)
            where user_id = @user_id;
            
            set @rows_affected = @@rowcount;
        end
        else if @user_type = 'student'
        begin
            update core.students
            set name = isnull(@new_name, name),
                email = isnull(@new_email, email),
                branch_id = isnull(@new_branch_id, branch_id),
                track_id = isnull(@new_track_id, track_id),
                intake_id = isnull(@new_intake_id, intake_id)
            where user_id = @user_id;
            
            set @rows_affected = @@rowcount;
        end

        -- check if update was successful
        if @rows_affected = 0
        begin
            raiserror('no records were updated. user details may not exist for user_id %d.', 16, 1, @user_id);
            return;
        end

        -- success response
        select 
            @user_id as user_id, 
            @user_type as user_type, 
            @rows_affected as rows_updated,
            'details updated successfully' as message;

    end try
    begin catch
        declare @errmsg nvarchar(4000) = error_message();
        
        select 
            error_number() as error_number,
            @errmsg as error_message,
            'failed to update user details' as status;
            
        raiserror(@errmsg, 16, 1);
    end catch
end
go

-------------------------------------------------------------------------------
-- delete user
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- DONT TRY THIS on students, instructors;
-- it will raise error if the student, instructor belongs to any other table 
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
create or alter procedure manager_api.sp_delete_user
    @user_id int
with execute as owner
as
begin
    set nocount on;
    declare @username nvarchar(100);
    declare @user_type nvarchar(20);
    declare @sql nvarchar(500);

    begin try
        begin transaction;

        -- get user info
        select @username = username, @user_type = user_type
        from core.users
        where user_id = @user_id;

        if @@rowcount = 0
        begin
            raiserror('user with id %d not found.', 16, 1, @user_id);
            rollback transaction;
            return;
        end

        -- delete from specific table based on type
        if @user_type = 'manager'
            delete from core.managers where user_id = @user_id;
        else if @user_type = 'instructor'
            delete from core.instructors where user_id = @user_id;
        else if @user_type = 'student'
            delete from core.students where user_id = @user_id;

        -- delete from users table
        delete from core.users where user_id = @user_id;

        commit transaction;

        -- try to drop sql server user (ignore errors)
        begin try
            if exists (select 1 from sys.database_principals where name = @username)
            begin
                set @sql = 'drop user [' + @username + ']';
                exec(@sql);
            end
        end try
        begin catch
            -- ignore any errors
        end catch

        -- try to drop sql server login (ignore errors)
        begin try
            if exists (select 1 from sys.server_principals where name = @username)
            begin
                set @sql = 'drop login [' + @username + ']';
                exec(@sql);
            end
        end try
        begin catch
            print 'Could not drop login: ' + ERROR_MESSAGE();
        end catch

        -- success response
        select
            @user_id as deleted_user_id,
            @username as deleted_username,
            @user_type as deleted_user_type,
            'user deleted successfully' as message;

    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
            
        declare @errmsg nvarchar(4000) = error_message();
        
        select
            error_number() as error_number,
            @errmsg as error_message,
            'failed to delete user' as status;

        raiserror(@errmsg, 16, 1);
    end catch
end
go

-------------------------------------------------------------------------------
-- branch, track, intake management procedures - add, update, delete
-- insert new branch if @branchid is null, otherwise update existing branch.
-------------------------------------------------------------------------------

-- edit branch
create or alter procedure manager_api.sp_edit_branch
   @branchid int = null,     -- null means insert new branch
   @name nvarchar(100),
   @location nvarchar(100)
   with execute as owner
as
begin
   set nocount on;  


   if @branchid is null
   begin
       -- insert new branch
       insert into core.branches (name, location)
       values (@name, @location);


       -- return new branch id
       select scope_identity() as newbranchid;
   end
   else
   begin
       -- update existing branch
       update core.branches
       set name = @name,
           location = @location
       where branch_id = @branchid;


       -- return updated branch id
       select @branchid as updatedbranchid;
   end
end
go

-------------------------------------------------------------------------------
-- edit branch
create or alter procedure manager_api.sp_edit_track
    @trackid int = null,     -- null means insert new track
    @name nvarchar(100),
    @departmentid int
    with execute as owner
as
begin
   set nocount on;


   if @trackid is null
   begin
       -- insert new track
       insert into core.tracks (name, department_id)
       values (@name, @departmentid);


       -- return new track id
       select scope_identity() as newtrackid;
   end
   else
   begin
       -- update existing track
       update core.tracks
       set name = @name,
           department_id = @departmentid
       where track_id = @trackid;


       -- return updated track id
       select @trackid as updatedtrackid;
   end
end
go

-------------------------------------------------------------------------------
-- edit intake
create or alter procedure manager_api.sp_edit_intake
    @intakeid int = null,       -- null means insert new intake
    @intakeyear smallint
    with execute as owner
as
begin
   set nocount on;


   if @intakeid is null
   begin
       -- insert new intake
       insert into core.intakes (intake_year)
       values (@intakeyear);


       -- return new intake id
       select scope_identity() as newintakeid;
   end
   else
   begin
       -- update existing intake
       update core.intakes
       set intake_year = @intakeyear
       where intake_id = @intakeid;


       -- return updated intake id
       select @intakeid as updatedintakeid;
   end
end
go
-------------------------------------------------------------------------------
-- edit department
create or alter procedure manager_api.sp_edit_department
    @departmentid int = null,       -- null means insert new department
    @departmentname nvarchar(100)
    with execute as owner
as
begin
    set nocount on;

    if @departmentid is null
    begin
        -- insert new department
        insert into core.departments (name)
        values (@departmentname);

        -- return new department id
        select scope_identity() as newdepartmentid;
    end
    else
    begin
        -- update existing department
        update core.departments
        set name = @departmentname
        where department_id = @departmentid;

        -- return updated department id
        select @departmentid as updateddepartmentid;
    end
end
go

-------------------------------------------------------------------------------
-- delete based on type and id of the core schema
-- ('branch', 'track', 'intake', 'department')
create or alter procedure manager_api.sp_delete_core_entity
    @type varchar(20),  -- 'branch', 'track', 'intake', 'department'
    @id int
    with execute as owner
as
begin
    set nocount on;
    
    if @type = 'branch'
        delete from core.branches where branch_id = @id;
    else if @type = 'track'
        delete from core.tracks where track_id = @id;
    else if @type = 'intake'
        delete from core.intakes where intake_id = @id;
    else if @type = 'department'
        delete from core.departments where department_id = @id;
    else
        raiserror('Invalid type. Must be branch, track, intake, or department.', 16, 1);
end
go




-------------------------------------------------------------------------------
-- instructor api
-------------------------------------------------------------------------------


create or alter procedure instructor_api.sp_compute_final_exam_result
    @exam_student_id int
with execute as owner
as
begin
    set nocount on;

    declare @student_id int,
            @class_id int,
            @total_score decimal(5,2),
            @status bit;

    select
        @student_id = es.student_id,
        @class_id = e.class_id
    from exams.exam_students es
    join exams.exams e
        on es.exam_id = e.exam_id
    where es.exam_student_id = @exam_student_id;

    if @student_id is null or @class_id is null
    begin
        print 'no matching exam_student_id found.';
        return;
    end

    select @total_score =
        sum(
            isnull(manual_score, 0) +
            case when is_correct = 1 then 1 else 0 end
        )
    from answers.student_answers
    where exam_student_id = @exam_student_id;

    if @total_score is null set @total_score = 0;

    set @status = case when @total_score >= 60 then 1 else 0 end;

    if exists (select 1 from answers.student_exam_results where exam_student_id = @exam_student_id)
        update answers.student_exam_results
        set exam_score = @total_score
        where exam_student_id = @exam_student_id;
    else
        insert into answers.student_exam_results (exam_student_id, exam_score)
        values (@exam_student_id, @total_score);

    if exists (select 1 from answers.class_results where student_id = @student_id and class_id = @class_id)
        update answers.class_results
        set total_score = @total_score, status = @status
        where student_id = @student_id and class_id = @class_id;
    else
        insert into answers.class_results (student_id, class_id, total_score, status)
        values (@student_id, @class_id, @total_score, @status);
end
go

create or alter procedure instructor_api.sp_manual_score_update
    @student_answer_id int,
    @manual_score decimal(5,2)
with execute as owner
as
begin
    set nocount on;

    declare @exam_student_id int;

    update answers.student_answers
    set manual_score = @manual_score
    where student_answers_id = @student_answer_id;

    select @exam_student_id = exam_student_id
    from answers.student_answers
    where student_answers_id = @student_answer_id;

    exec instructor_api.sp_compute_final_exam_result @exam_student_id = @exam_student_id;
end
go


create or alter procedure instructor_api.sp_searchexams
    @course_name nvarchar(100) = null,
    @exam_type nvarchar(50) = null,
    @instructor nvarchar(100) = null,
    @exam_date datetime = null
with execute as owner
as
begin
     select e.exam_id,
        e.exam_type,
        c.course_id,
        c.course_name,
        i.instructor_id,
        i.name        
     from courses.class_offerings cco
        join courses.courses c on c.course_id=cco.course_id
        join core.instructors i on i.instructor_id=cco.instructor_id 
        join exams.exams e on e.class_id=cco.class_id
     where 
        (@course_name is null or c.course_name =@course_name)
        and (@exam_type is null or e.exam_type = @exam_type)
        and (@instructor is null or i.name = @instructor)
end 
go

create type exams.questionlist as table
(
    questionid int not null,
    questiondegree decimal(5,2) not null
);
go

create or alter procedure instructor_api.sp_add_exam
    @instructorid int,
    @courseid int,
    @classid int,
    @examid int,
    @examtype nvarchar(50),
    @starttime datetime,
    @endtime datetime,
    @totaltime decimal(5,2),
    @extratime int,
    @openbook bit,
    @allowcalc bit,
    @questions exams.questionlist readonly
with execute as owner    
as
begin
    if not exists (
        select 1
        from courses.class_offerings co
        where co.course_id = @courseid
          and co.instructor_id = @instructorid
    )
    begin
        print 'error: instructor is not assigned to this course.';
        return;
    end

    declare @totaldegree decimal(5,2);
    select @totaldegree = sum(questiondegree) from @questions;

    declare @maxdegree decimal(5,2);
    select @maxdegree = c.max_degree
    from courses.courses c
    where c.course_id = @courseid;

    declare @mindegree decimal(5,2);
    select @mindegree = c.min_degree
    from courses.courses c
    where c.course_id = @courseid;
    
    if @totaldegree > @maxdegree
    begin
        print 'error: total degrees exceed course maximum.';
        return;
    end

    insert into exams.exams
        (exam_type, start_time, end_time, total_time, total_degree, class_id, extra_time_minutes, open_book, allow_calculator)
    values
        (@examtype, @starttime, @endtime, @totaltime, @totaldegree, @classid, @extratime, @openbook, @allowcalc);

    set @examid = scope_identity();

    insert into exams.exam_questions (exam_id, question_id, question_degree)
    select @examid, questionid, questiondegree
    from @questions;

    print 'exam added successfully with examid = ' + cast(@examid as nvarchar(20));
end
go

create or alter procedure instructor_api.sp_searchstudents @studentname nvarchar(50) =null,@email nvarchar(50) =null ,@intakeid int= null
with execute as owner
as 
begin
    select student_id,name,email,branch_id,track_id,intake_id
    from core.students
      where 
        (@studentname is null or name = @studentname )
        and (@email is null or email like '%' + @email + '%')
        and (@intakeid is null or intake_id = @intakeid);
end
go

-------------------------------------------------------------------------------
-- student api
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- student_api.sp_get_dashboard
-- This procedure retrieves a summary of student information
-- and their exam statistics for the dashboard.
-------------------------------------------------------------------------------
create or alter procedure student_api.sp_get_dashboard
with execute as owner
as
begin
    set nocount on;

    declare @username sysname;

    set @username = ORIGINAL_LOGIN();

    select 
        s.name 'Student name',
        s.email 'Email',
        b.name 'Branch name',
        t.name 'Track name',
        i.intake_year 'Intake Year',
        (select count(*) 
         from exams.exam_students es
         where es.student_id = s.student_id) as 'Total Exams',
        (select count(*) 
         from exams.exam_students es
         where es.student_id = s.student_id 
         and getdate() < dateadd(second, 0, cast(es.exam_date as datetime) + cast(es.end_time as datetime))) as 'Not Completed Exams'
    from core.users u
    join core.students s on u.user_id = s.user_id
    left join core.branches b on s.branch_id = b.branch_id
    left join core.tracks t on s.track_id = t.track_id
    left join core.intakes i on s.intake_id = i.intake_id
    left join core.users acc on s.student_id = acc.user_id
    where u.username = @username; 
end
go
-------------------------------------------------------------------------------
-- student_api.sp_get_student_exams
-- This procedure fetches a list of upcoming exams
-- for the currently logged-in student.
-------------------------------------------------------------------------------
create or alter procedure student_api.sp_get_student_exams
with execute as owner
as
begin
    set nocount on;

    declare @username sysname;
    set @username = ORIGINAL_LOGIN();

    select 
        es.exam_student_id   as 'exam_student_id',
        c.course_name       as 'Course Name',
        e.exam_type         as 'Exam Type',
        es.exam_date        as 'Exam Date',
        es.start_time       as 'Start Time',
        es.end_time         as 'End Time',
        e.total_time        as 'Total Duration (min)',
        e.total_degree      as 'Total Degree',
        e.open_book         as 'Open Book',
        e.allow_calculator  as 'Allow Calculator'
    from core.users u
    join core.students s 
        on u.user_id = s.user_id
    join exams.exam_students es 
        on s.student_id = es.student_id
    join exams.exams e 
        on es.exam_id = e.exam_id
    join courses.class_offerings co 
        on e.class_id = co.class_id
    join courses.courses c 
        on co.course_id = c.course_id
    where u.username = @username 
    and getdate() < dateadd(second, 0, cast(es.exam_date as datetime) + cast(es.end_time as datetime))
    order by es.exam_date, es.start_time;
end
go
-------------------------------------------------------------------------------
-- student_api.sp_take_exam
-- This procedure validates a student's eligibility for a specific exam
-- and returns its questions and options.
-------------------------------------------------------------------------------
create or alter procedure student_api.sp_take_exam
    @username varchar(50),
    @exam_id int
as
begin
    set nocount on;

    declare @student_id int;

    -- get student_id from username
    select @student_id = s.student_id
    from core.students s
    join core.users u on u.user_id = s.user_id
    where u.username = @username;

    if @student_id is null
    begin
        raiserror('student not found for given username', 16, 1);
        return;
    end

    -- prevent duplicate exam_student
    if not exists (
        select 1
        from exams.exam_students es
        where es.exam_id = @exam_id
          and es.student_id = @student_id
    )
    begin
        insert into exams.exam_students (exam_id, student_id, exam_date, start_time, end_time)
        values (@exam_id, @student_id, cast(getdate() as date), cast(getdate() as time), dateadd(minute, 60, cast(getdate() as time)));
    end

    -- return exam questions
    select q.question_id, q.question_text, q.question_type, o.option_id, o.option_text
    from exams.exam_questions eq
    join questions_bank.questions q on q.question_id = eq.question_id
    left join questions_bank.options o on o.question_id = q.question_id
    where eq.exam_id = @exam_id;
end
go

--------------------------------------------------------------------------------

create or alter procedure student_api.sp_submit_answer
    @username varchar(50),
    @exam_id int,
    @question_id int,
    @option_id int = null,
    @answer_text nvarchar(255) = null
as
begin
    set nocount on;

    declare @student_id int, @exam_student_id int;

    -- get student_id from username
    select @student_id = s.student_id
    from core.students s
    join core.users u on u.user_id = s.user_id
    where u.username = @username;

    if @student_id is null
    begin
        raiserror('student not found for given username', 16, 1);
        return;
    end

    -- get exam_student_id
    select @exam_student_id = es.exam_student_id
    from exams.exam_students es
    where es.exam_id = @exam_id
      and es.student_id = @student_id;

    if @exam_student_id is null
    begin
        raiserror('student is not registered for this exam', 16, 1);
        return;
    end

    -- check if answer already exists
    if exists (
        select 1
        from answers.student_answers sa
        where sa.exam_student_id = @exam_student_id
          and sa.question_id = @question_id
    )
    begin
        -- update existing answer
        update answers.student_answers
        set option_id   = @option_id,
            answer_text = @answer_text
        where exam_student_id = @exam_student_id
          and question_id = @question_id;
    end
    else
    begin
        -- insert new answer
        insert into answers.student_answers (exam_student_id, question_id, option_id, answer_text)
        values (@exam_student_id, @question_id, @option_id, @answer_text);
    end
end
go

--------------------------------------------------------------------------------

create or alter procedure student_api.sp_get_submitted_answers
    @username varchar(50),
    @exam_id int
as
begin
    set nocount on;

    declare @student_id int, @exam_student_id int;

    -- get student_id from username
    select @student_id = s.student_id
    from core.students s
    join core.users u on u.user_id = s.user_id
    where u.username = @username;

    if @student_id is null
    begin
        raiserror('student not found for given username', 16, 1);
        return;
    end

    -- get exam_student_id
    select @exam_student_id = es.exam_student_id
    from exams.exam_students es
    where es.exam_id = @exam_id
      and es.student_id = @student_id;

    if @exam_student_id is null
    begin
        raiserror('student is not registered for this exam', 16, 1);
        return;
    end

    -- return submitted answers
    select sa.question_id, sa.option_id, sa.answer_text
    from answers.student_answers sa
    where sa.exam_student_id = @exam_student_id;
end
go

-------------------------------------------------------------------------------
-- create views
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- user management views
-------------------------------------------------------------------------------

-- comprehensive user view with all details
create or alter view manager_api.vw_all_users as
select 
    u.user_id,
    u.username,
    u.user_type,
    u.is_active,
    u.created_at,
    u.last_login,
    -- get name based on user type
    case 
        when u.user_type = 'manager' then m.name
        when u.user_type = 'instructor' then i.name
        when u.user_type = 'student' then s.name
        else 'n/a'
    end as full_name,
    -- get email based on user type
    case 
        when u.user_type = 'manager' then m.email
        when u.user_type = 'instructor' then i.email
        when u.user_type = 'student' then s.email
        else 'n/a'
    end as email,
    -- additional details for students
    case when u.user_type = 'student' then b.name else null end as branch_name,
    case when u.user_type = 'student' then t.name else null end as track_name,
    case when u.user_type = 'student' then in_t.intake_year else null end as intake_year,
    -- additional details for instructors
    case when u.user_type = 'instructor' then d.name else null end as department_name
from core.users u
left join core.managers m on u.user_id = m.user_id and u.user_type = 'manager'
left join core.instructors i on u.user_id = i.user_id and u.user_type = 'instructor'
left join core.students s on u.user_id = s.user_id and u.user_type = 'student'
left join core.branches b on s.branch_id = b.branch_id
left join core.tracks t on s.track_id = t.track_id
left join core.intakes in_t on s.intake_id = in_t.intake_id
left join core.departments d on i.department_id = d.department_id;
go
-------------------------------------------------------------------------------
-- system statistics views
-------------------------------------------------------------------------------

-- overall system statistics
create or alter view manager_api.vw_system_dashboard as
select 
    (select count(*) from core.users where is_active = 1) as active_users,
    (select count(*) from core.users where is_active = 0) as inactive_users,
    (select count(*) from core.students) as total_students,
    (select count(*) from core.instructors) as total_instructors,
    (select count(*) from core.managers) as total_managers,
    (select count(*) from courses.courses) as total_courses,
    (select count(*) from courses.class_offerings) as total_classes,
    (select count(*) from exams.exams) as total_exams,
    (select count(*) from questions_bank.questions) as total_questions;
go

-- course performance statistics
create or alter view manager_api.vw_course_performance as
select 
    c.course_id,
    c.course_name,
    c.description,
    count(distinct co.class_id) as total_classes,
    count(distinct e.exam_id) as total_exams,
    count(distinct es.student_id) as students_participated,
    avg(cast(ser.exam_score as decimal(5,2))) as average_score,
    min(ser.exam_score) as min_score,
    max(ser.exam_score) as max_score,
    count(case when ser.exam_score >= c.min_degree then 1 end) as passed_students,
    count(case when ser.exam_score < c.min_degree then 1 end) as failed_students
from courses.courses c
left join courses.class_offerings co on c.course_id = co.course_id
left join exams.exams e on co.class_id = e.class_id
left join exams.exam_students es on e.exam_id = es.exam_id
left join answers.student_exam_results ser on es.exam_student_id = ser.exam_student_id
group by c.course_id, c.course_name, c.description, c.min_degree;
go

-- instructor performance view
create or alter view manager_api.vw_instructor_performance as
select 
    i.instructor_id,
    i.name as instructor_name,
    i.email,
    d.name as department,
    count(distinct co.class_id) as classes_taught,
    count(distinct co.course_id) as courses_taught,
    count(distinct es.student_id) as students_taught,
    avg(cast(ser.exam_score as decimal(5,2))) as avg_student_score,
    count(case when ser.exam_score >= 60 then 1 end) as students_passed,
    count(case when ser.exam_score < 60 then 1 end) as students_failed
from core.instructors i
left join core.departments d on i.department_id = d.department_id
left join courses.class_offerings co on i.instructor_id = co.instructor_id
left join exams.exams e on co.class_id = e.class_id
left join exams.exam_students es on e.exam_id = es.exam_id
left join answers.student_exam_results ser on es.exam_student_id = ser.exam_student_id
group by i.instructor_id, i.name, i.email, d.name;
go

-- student progress tracking
CREATE OR ALTER VIEW manager_api.vw_student_progress AS
SELECT 
    s.student_id,
    s.name AS student_name,
    s.email,
    b.name AS branch,
    t.name AS track,
    int_t.intake_year,
    COUNT(DISTINCT cr.class_id) AS classes_enrolled,
    COUNT(DISTINCT CASE WHEN cr.status = 1 THEN cr.class_id END) AS classes_passed,
    COUNT(DISTINCT CASE WHEN cr.status = 0 THEN cr.class_id END) AS classes_failed,
    AVG(CAST(cr.total_score AS DECIMAL(5,2))) AS overall_average,
    MAX(cr.total_score) AS highest_score,
    MIN(cr.total_score) AS lowest_score
FROM core.students s
LEFT JOIN core.branches b ON s.branch_id = b.branch_id
LEFT JOIN core.tracks t ON s.track_id = t.track_id
LEFT JOIN core.intakes int_t ON s.intake_id = int_t.intake_id
LEFT JOIN answers.class_results cr ON s.student_id = cr.student_id
GROUP BY s.student_id, s.name, s.email, b.name, t.name, int_t.intake_year;
GO

-------------------------------------------------------------------------------
-- exam management views
-------------------------------------------------------------------------------

-- detailed exam information
create or alter view manager_api.vw_exam_details as
select 
    e.exam_id,
    e.exam_type,
    e.start_time,
    e.end_time,
    e.total_time,
    e.total_degree,
    c.course_name,
    i.name as instructor_name,
    b.name as branch_name,
    t.name as track_name,
    int_t.intake_year,
    count(distinct es.student_id) as registered_students,
    count(distinct case when es.submission_time is not null then es.student_id end) as submitted_students,
    avg(cast(ser.exam_score as decimal(5,2))) as average_score
from exams.exams e
join courses.class_offerings co on e.class_id = co.class_id
join courses.courses c on co.course_id = c.course_id
join core.instructors i on co.instructor_id = i.instructor_id
join core.branches b on co.branch_id = b.branch_id
join core.tracks t on co.track_id = t.track_id
join core.intakes int_t on co.intake_id = int_t.intake_id
left join exams.exam_students es on e.exam_id = es.exam_id
left join answers.student_exam_results ser on es.exam_student_id = ser.exam_student_id
group by e.exam_id, e.exam_type, e.start_time, e.end_time, e.total_time, 
         e.total_degree, c.course_name, i.name, b.name, t.name, int_t.intake_year;
go

-- question bank overview
create or alter view manager_api.vw_questions_overview as
select 
    c.course_name,
    q.question_type,
    count(*) as question_count,
    avg(case when sa.is_correct = 1 then 1.0 else 0.0 end) * 100 as success_rate
from questions_bank.questions q
join courses.courses c on q.course_id = c.course_id
left join answers.student_answers sa on q.question_id = sa.question_id
group by c.course_id, c.course_name, q.question_type;
go

-------------------------------------------------------------------------------
-- organizational views
-------------------------------------------------------------------------------

-- department overview
create or alter view manager_api.vw_departments_overview as
select 
    d.department_id,
    d.name as department_name,
    count(distinct i.instructor_id) as total_instructors,
    count(distinct t.track_id) as total_tracks,
    count(distinct s.student_id) as total_students
from core.departments d
left join core.instructors i on d.department_id = i.department_id
left join core.tracks t on d.department_id = t.department_id
left join core.students s on t.track_id = s.track_id
group by d.department_id, d.name;
go

-- branch statistics
create or alter view manager_api.vw_branches_overview as
select 
    b.branch_id,
    b.name as branch_name,
    b.location,
    count(distinct s.student_id) as total_students,
    count(distinct co.class_id) as total_classes,
    count(distinct co.course_id) as courses_offered
from core.branches b
left join core.students s on b.branch_id = s.branch_id
left join courses.class_offerings co on b.branch_id = co.branch_id
group by b.branch_id, b.name, b.location;
go




-------------------------------------------------------------------------------
-- instructor_api views
-------------------------------------------------------------------------------
create or alter view instructor_api.vw_questions as
select 
    q.question_id,
    q.question_text,
    q.course_id,
    c.course_name,
    i.instructor_id,
    i.name as instructor_name
from questions_bank.questions q
join courses.courses c 
    on q.course_id = c.course_id
join courses.class_offerings co 
    on co.course_id = c.course_id
join core.instructors i 
    on co.instructor_id = i.instructor_id;
go

create or alter view instructor_api.vw_question_types as
select distinct 
    q.question_type
from questions_bank.questions q;
go

create or alter view instructor_api.vw_question_options as
select 
    o.option_id,
    o.question_id,
    o.option_text,
    o.is_correct
from questions_bank.options o
join questions_bank.questions q 
    on o.question_id = q.question_id
where q.question_type in ('mc', 'tf');
go

create or alter view instructor_api.vw_accepted_text_answers as
select 
    ata.text_answers_id,
    ata.question_id,
    ata.accepted_pattern,
    q.question_text
from questions_bank.accepted_text_answers ata
join questions_bank.questions q 
    on ata.question_id = q.question_id;
go

create or alter view instructor_api.vw_courses as
select 
    c.course_id,
    c.course_name,
    c.description,
    c.max_degree,
    c.min_degree,
    i.instructor_id,
    i.name as instructor_name
from courses.courses c
join courses.class_offerings co 
    on co.course_id = c.course_id
join core.instructors i 
    on co.instructor_id = i.instructor_id;
go

create or alter view instructor_api.vw_class_offerings as
select 
    co.class_id,
    co.course_id,
    c.course_name,
    co.instructor_id,
    i.name as instructor_name,
    co.branch_id,
    b.name as branch_name,
    co.track_id,
    t.name as track_name,
    co.intake_id,
    it.intake_year
from courses.class_offerings co
join courses.courses c 
    on co.course_id = c.course_id
join core.instructors i 
    on co.instructor_id = i.instructor_id
join core.branches b 
    on co.branch_id = b.branch_id
join core.tracks t 
    on co.track_id = t.track_id
join core.intakes it 
    on co.intake_id = it.intake_id;
go

create or alter view instructor_api.vw_exams as
select 
    e.exam_id,
    e.exam_type,
    e.start_time,
    e.end_time,
    e.total_time,
    e.total_degree,
    e.class_id,
    co.course_id,
    c.course_name,
    i.instructor_id,
    i.name as instructor_name
from exams.exams e
join courses.class_offerings co 
    on e.class_id = co.class_id
join courses.courses c 
    on co.course_id = c.course_id
join core.instructors i 
    on co.instructor_id = i.instructor_id;
go

create or alter view instructor_api.vw_exam_question_details as
select 
    eq.exam_id,
    eq.question_id,
    q.question_text,
    eq.question_degree,
    e.class_id,
    co.course_id,
    i.instructor_id
from exams.exam_questions eq
join questions_bank.questions q 
    on eq.question_id = q.question_id
join exams.exams e 
    on eq.exam_id = e.exam_id
join courses.class_offerings co 
    on e.class_id = co.class_id
join core.instructors i 
    on co.instructor_id = i.instructor_id;
go


create or alter view instructor_api.vw_exam_students as
select
    es.exam_student_id,
    es.exam_id,
    e.exam_type,
    es.student_id,
    s.name as student_name,
    co.class_id,
    co.course_id,
    c.course_name,
    es.exam_date,
    es.start_time,
    es.end_time,
    e.open_book,
    e.allow_calculator,
    es.submission_time
from exams.exam_students es
join core.students s 
    on es.student_id = s.student_id
join exams.exams e 
    on es.exam_id = e.exam_id
join courses.class_offerings co 
    on e.class_id = co.class_id
join courses.courses c 
    on co.course_id = c.course_id;
go


create or alter view instructor_api.vw_student_result
as
with examresults as (
    select 
        s.student_id,
        s.name as student_name,
        e.exam_id,
        e.exam_type,
        null as course_id,
        null as course_name,
        e.total_degree as total_score,
        null as status
    from exams.exam_students es
    inner join core.students s on es.student_id = s.student_id
    inner join exams.exams e on es.exam_id = e.exam_id
),
courseresults as (
    select 
        s.student_id,
        s.name as student_name,
        null as exam_id,
        null as exam_type,
        c.course_id,
        c.course_name,
        cr.total_score,
        cr.status
    from answers.class_results cr
    inner join core.students s on cr.student_id = s.student_id
    inner join courses.class_offerings cl on cr.class_id = cl.class_id
    inner join courses.courses c on cl.course_id = c.course_id
)
select * from examresults
union all
select * from courseresults;
go

create or alter view instructor_api.vw_exam_details
as
with examinfo as (
    select 
        e.exam_id,
        e.exam_type,
        e.start_time,
        e.end_time,
        e.total_time,
        e.total_degree,
        e.extra_time_minutes,
        e.open_book,
        e.allow_calculator,
        c.course_name,
        i.name as instructor_name,
        cl.class_id
    from exams.exams e
    inner join courses.class_offerings cl on e.class_id = cl.class_id
    inner join courses.courses c on cl.course_id = c.course_id
    inner join core.instructors i on cl.instructor_id = i.instructor_id
),
examquestions as (
    select 
        eq.exam_id,
        q.question_id,
        q.question_text,
        q.question_type,
        eq.question_degree
    from exams.exam_questions eq
    inner join questions_bank.questions q on eq.question_id = q.question_id
)
select 
    ei.exam_id,
    ei.exam_type,
    ei.start_time,
    ei.end_time,
    ei.total_time,
    ei.total_degree,
    ei.extra_time_minutes,
    ei.open_book,
    ei.allow_calculator,
    ei.course_name,
    ei.instructor_name,
    ei.class_id,
    q.question_id,
    q.question_text,
    q.question_type,
    q.question_degree
from examinfo ei
inner join examquestions q on ei.exam_id = q.exam_id;
go


-------------------------------------------------------------------------------
-- create all functions
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- instructor_api functions
-------------------------------------------------------------------------------


-- 1) fn_check_mcq_answers (simple lookup)
create or alter function instructor_api.fn_check_mcq_answers (@option_id int)
returns bit
with execute as owner
as
begin
    declare @is_correct bit = 0;

    select @is_correct = is_correct
    from questions_bank.options
    where option_id = @option_id;

    return isnull(@is_correct, 0);
end
go

-- 2) fn_check_text_answers (normalized, case-insensitive patindex)
create or alter function instructor_api.fn_check_text_answers
(
    @question_id int,
    @answer_text nvarchar(max)
)
returns bit
with execute as owner
as
begin
    declare @normalized_answer nvarchar(max);
    declare @exists_match bit = 0;

    if @answer_text is null
        return 0;

    -- normalize: lower, trim
    set @normalized_answer = lower(ltrim(rtrim(@answer_text)));

    -- remove common punctuation
    set @normalized_answer = replace(@normalized_answer, '.', '');
    set @normalized_answer = replace(@normalized_answer, ',', '');
    set @normalized_answer = replace(@normalized_answer, ';', '');
    set @normalized_answer = replace(@normalized_answer, ':', '');
    set @normalized_answer = replace(@normalized_answer, '?', '');
    set @normalized_answer = replace(@normalized_answer, '!', '');
    set @normalized_answer = replace(@normalized_answer, '"', '');
    set @normalized_answer = replace(@normalized_answer, '''', '');

    -- collapse multiple spaces
    while charindex('  ', @normalized_answer) > 0
        set @normalized_answer = replace(@normalized_answer, '  ', ' ');

    -- check accepted patterns (patterns should be stored in lowercase or we lower them here)
    if exists (
        select 1
        from questions_bank.accepted_text_answers a
        where a.question_id = @question_id
          and patindex('%' + lower(a.accepted_pattern) + '%', @normalized_answer) > 0
    )
        set @exists_match = 1;

    return @exists_match;
end
go


-------------------------------------------------------------------------------
-- create all indexes
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- core schema indexes
-------------------------------------------------------------------------------
-- index on students.user_id
create nonclustered index ix_students_user_id
on core.students(user_id);

-- composite index on students(track_id, intake_id, branch_id)
create nonclustered index ix_students_track_intake_branch
on core.students(track_id, intake_id, branch_id);

-------------------------------------------------------------------------------
-- courses schema indexes
-------------------------------------------------------------------------------
-- index on class_offerings.intake_id
create nonclustered index ix_class_offerings_intake_id
on courses.class_offerings(intake_id);

-------------------------------------------------------------------------------
-- questions_bank schema indexes
-------------------------------------------------------------------------------
-- index on options.question_id
create nonclustered index ix_options_question_id
on questions_bank.options(question_id);

-------------------------------------------------------------------------------
-- exams schema indexes
-------------------------------------------------------------------------------
-- index on exam_students.exam_id
create nonclustered index ix_exam_students_exam_id
on exams.exam_students(exam_id);

-------------------------------------------------------------------------------
-- answers schema indexes
-------------------------------------------------------------------------------
-- index on student_answers.question_id
create nonclustered index ix_student_answers_question_id
on answers.student_answers(question_id);

-------------------------------------------------------------------------------
-- answers schema composite index
-------------------------------------------------------------------------------
-- composite index on (exam_student_id, question_id)
create nonclustered index ix_student_answers_examstudent_question
on answers.student_answers(exam_student_id, question_id);
go

-------------------------------------------------------------------------------
-- triggers
-------------------------------------------------------------------------------
-- trigger to auto-grade answers when inserted/updated
create or alter trigger answers.trg_auto_grade_student_answer
on answers.student_answers
after insert, update
as
begin
    -- auto-grade: update is_correct / auto_match / manual_score based on question type and answers
    update sa
    set
        sa.is_correct = 
            case 
                when q.question_type in ('mc','tf') then instructor_api.fn_check_mcq_answers(sa.option_id)
                when q.question_type = 'text' then instructor_api.fn_check_text_answers(q.question_id, sa.answer_text)
                else 0
            end,
        sa.auto_match = 
            case 
                when q.question_type in ('mc','tf') then 1  
                when q.question_type = 'text' and instructor_api.fn_check_text_answers(q.question_id, sa.answer_text) = 1 then 1
                else 0
            end,
        sa.manual_score =
            case
                when sa.manual_score is not null then sa.manual_score 
                when q.question_type in ('mc','tf') and instructor_api.fn_check_mcq_answers(sa.option_id) = 1 
                    then isnull(eq.question_degree,0)
                when q.question_type = 'text' and instructor_api.fn_check_text_answers(q.question_id, sa.answer_text) = 1 
                    then null 
                else sa.manual_score 
            end
    from answers.student_answers sa
    join inserted i on sa.student_answers_id = i.student_answers_id
    join questions_bank.questions q on sa.question_id = q.question_id
    left join exams.exam_questions eq on eq.question_id = sa.question_id
    left join exams.exam_students es on sa.exam_student_id = es.exam_student_id
    where eq.exam_id = es.exam_id;

    -- recompute exam total and class result for affected students
    declare cur cursor local fast_forward for
    select distinct es.exam_student_id, s.student_id, e.class_id
    from inserted i
    join answers.student_answers sa on i.student_answers_id = sa.student_answers_id
    join exams.exam_students es on sa.exam_student_id = es.exam_student_id
    join exams.exams e on es.exam_id = e.exam_id
    join core.students s on es.student_id = s.student_id;

    open cur;

    declare @exam_student int, @stud_id int, @class_id int;

    fetch next from cur into @exam_student, @stud_id, @class_id;
    while @@fetch_status = 0
    begin
        exec instructor_api.sp_compute_final_exam_result @exam_student_id = @exam_student;
        fetch next from cur into @exam_student, @stud_id, @class_id;
    end

    close cur;
    deallocate cur;
end
go


-------------------------------------------------------------------------------
-- Trigger: Prevent student from starting exam outside allowed time
-------------------------------------------------------------------------------
create or alter trigger exams.trg_start_exam
on exams.exam_students
after insert
as
begin
    declare @starttime datetime,
            @endtime datetime,
            @now datetime,
            @exam_student_id int;

    -- Get the inserted exam_student ID
    select @exam_student_id = exam_student_id from inserted;
    set @now = GETDATE();

    -- Get the exam start and end time
    select
        @starttime = start_time,
        @endtime = end_time
    from exams.exam_students
    where exam_student_id = @exam_student_id;

    -- Check if current time is outside the exam time
    if @now < @starttime or @now > @endtime
    begin
        raiserror('You cannot start the exam outside the allowed time', 16, 1);
        rollback;
    end
end;
go

-------------------------------------------------------------------------------
-- Trigger: Prevent student from submitting after exam end time
-------------------------------------------------------------------------------
create or alter trigger exams.trg_exam_end_time
on exams.exam_students
after insert
as
begin
    declare @now datetime,
            @endtime datetime,
            @exam_student_id int;

    -- Get the inserted exam_student ID
    select @exam_student_id = exam_student_id from inserted;
    set @now = GETDATE();

    -- Get the exam end time
    select @endtime = end_time
    from exams.exam_students
    where exam_student_id = @exam_student_id;

    -- Check if current time is after the exam end time
    if @now > @endtime
    begin
        raiserror('The exam time is over. You must exit now.', 16, 1);
        rollback;
    end
end;
go