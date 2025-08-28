-------------------------------------------------------------------------------
-- Triggers
-------------------------------------------------------------------------------
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