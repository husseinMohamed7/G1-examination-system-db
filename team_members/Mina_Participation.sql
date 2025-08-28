-------------------------------------------------------------------------------
-- Mina's Participation
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
go

if not exists (
         select 1
         from exams.exam_students es
         where es.exam_id = @exam_id
           and es.student_id = @student_id
     )
     begin
go

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
go

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
go

insert into answers.student_answers (exam_student_id, question_id, option_id, answer_text)
         values (@exam_student_id, @question_id, @option_id, @answer_text);
     end
 end
go

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

