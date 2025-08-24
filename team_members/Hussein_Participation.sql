-------------------------------------------------------------------------------
-- Hussein's Participation
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
go

insert into core.users (username, password, user_type, is_active)
         values (@username, @password, @user_type, @is_active);
         
         set @user_id = scope_identity();
         
         -- insert into specific table
         if @user_type = 'manager'
go

insert into core.managers (user_id, name, email) values (@user_id, @name, @email);
         else if @user_type = 'instructor'
go

insert into core.instructors (user_id, name, email, department_id) values (@user_id, @name, @email, @department_id);
         else if @user_type = 'student'
go

insert into core.students (user_id, name, email, branch_id, track_id, intake_id) values (@user_id, @name, @email, @branch_id, @track_id, @intake_id);
         
         commit transaction;
         
         -- create login and user with elevated privileges
         set @sql = '
         begin try
             -- create login
go

create login [' + @username + '] with password = ''' + @password + ''';
             
             -- add to server role if manager
             ' + case when @user_type = 'manager' then 'alter server role manager add member [' + @username + '];' else '' end + '
             
             -- switch to database context
             use [' + db_name() + '];
             
             -- create user
go

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
go

if exists(select 1 from sys.database_principals where name = @current_username)
                     exec('drop user [' + @current_username + ']');
go

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
go

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

