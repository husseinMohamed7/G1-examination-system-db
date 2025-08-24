-------------------------------------------------------------------------------
-- Nora's Participation
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