-------------------------------------------------------------------------------
-- Abdelrhman's Participation
-------------------------------------------------------------------------------

if exists (select 1 from sys.databases where name = 'g1_examination_system')
 begin
     alter database g1_examination_system set single_user with rollback immediate;
go

use master;
     drop database g1_examination_system;
 end
go

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

USE master;
go

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'manager' AND type = 'R')
 BEGIN
     CREATE SERVER ROLE manager; -- first account role as db_admin
 END
go

GRANT ALTER ANY LOGIN TO manager;
go

use g1_examination_system;
 create role training_manager; -- 2nd account role
 create role instructor;       -- 3rd account role
 create role student;          -- 4th account role
go

grant alter any user to training_manager;
go

grant alter any role to training_manager;
go

deny select, insert, update, delete on schema::core to training_manager, instructor, student;
go

deny select, insert, update, delete on schema::courses to training_manager, instructor, student;
go

deny select, insert, update, delete on schema::questions_bank to training_manager, instructor, student;
go

deny select, insert, update, delete on schema::exams to training_manager, instructor, student;
go

deny select, insert, update, delete on schema::answers to training_manager, instructor, student;
go

deny select, insert, update, delete on schema::dbo to training_manager, instructor, student;
go

deny execute on schema::instructor_api to training_manager, student;
go

deny select on schema::instructor_api to training_manager, student;
go

deny execute on schema::student_api to training_manager, instructor;
go

deny select on schema::student_api to training_manager, instructor;
go

deny execute on schema::manager_api to instructor, student;
go

deny select on schema::manager_api to instructor, student;
go

grant execute on schema::manager_api to training_manager;
go

grant select on schema::manager_api to training_manager;
go

grant execute on schema::instructor_api to instructor;
go

grant select on schema::instructor_api to instructor;
go

grant execute on schema::student_api to student;
go

grant select on schema::student_api to student;
 
 -- Manager
go

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Osama')
 BEGIN
go

CREATE LOGIN Osama WITH PASSWORD = 'P@ssw0rd';
 END
go

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Osama')
 BEGIN
go

CREATE USER Osama FOR LOGIN Osama;
 END
go

ALTER SERVER ROLE manager ADD MEMBER Osama;
go

ALTER ROLE training_manager ADD MEMBER Osama;
go

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Sarah')
 BEGIN
go

CREATE LOGIN Sarah WITH PASSWORD = 'P@ssw0rd';
 END
go

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Sarah')
 BEGIN
go

CREATE USER Sarah FOR LOGIN Sarah;
 END
go

ALTER ROLE instructor ADD MEMBER Sarah;
go

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Youmna')
 BEGIN
go

CREATE LOGIN Youmna WITH PASSWORD = 'P@ssw0rd';
 END
go

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Youmna')
 BEGIN
go

CREATE USER Youmna FOR LOGIN Youmna;
 END
go

ALTER ROLE instructor ADD MEMBER Youmna;
go

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Hussein7')
 BEGIN
go

CREATE LOGIN Hussein7 WITH PASSWORD = 'P@ssw0rd';
 END
go

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Hussein7')
 BEGIN
go

CREATE USER Hussein7 FOR LOGIN Hussein7;
 END
go

ALTER ROLE student ADD MEMBER Hussein7;
go

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'abdlrhman12')
 BEGIN
go

CREATE LOGIN abdlrhman12 WITH PASSWORD = 'P@ssw0rd';
 END
go

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'abdlrhman12')
 BEGIN
go

CREATE USER abdlrhman12 FOR LOGIN abdlrhman12;
 END
go

ALTER ROLE student ADD MEMBER abdlrhman12;
go

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Mina44')
 BEGIN
go

CREATE LOGIN Mina44 WITH PASSWORD = 'P@ssw0rd';
 END
go

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Mina44')
 BEGIN
go

CREATE USER Mina44 FOR LOGIN Mina44;
 END
go

ALTER ROLE student ADD MEMBER Mina44;
go

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Nora23')
 BEGIN
go

CREATE LOGIN Nora23 WITH PASSWORD = 'P@ssw0rd';
 END
go

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Nora23')
 BEGIN
go

CREATE USER Nora23 FOR LOGIN Nora23;
 END
go

ALTER ROLE student ADD MEMBER Nora23;
go

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Maher88')
 BEGIN
go

CREATE LOGIN Maher88 WITH PASSWORD = 'P@ssw0rd';
 END
go

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Maher88')
 BEGIN
go

CREATE USER Maher88 FOR LOGIN Maher88;
 END
go

ALTER ROLE student ADD MEMBER Maher88;
go

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
go

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
go

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
go

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
go

insert into exams.exams
         (exam_type, start_time, end_time, total_time, total_degree, class_id, extra_time_minutes, open_book, allow_calculator)
     values
         (@examtype, @starttime, @endtime, @totaltime, @totaldegree, @classid, @extratime, @openbook, @allowcalc);
 
     set @examid = scope_identity();
go

insert into exams.exam_questions (exam_id, question_id, question_degree)
     select @examid, questionid, questiondegree
     from @questions;
 
     print 'exam added successfully with examid = ' + cast(@examid as nvarchar(20));
 end
go

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

