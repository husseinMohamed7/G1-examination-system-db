-------------------------------------------------------------------------------
-- Maher's Participation
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
go

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

