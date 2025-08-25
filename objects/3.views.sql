-------------------------------------------------------------------------------
-- Views
-------------------------------------------------------------------------------
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