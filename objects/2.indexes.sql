-------------------------------------------------------------------------------
-- Indexes
-------------------------------------------------------------------------------
create nonclustered index ix_students_user_id
on core.students(user_id);

create nonclustered index ix_students_track_intake_branch
on core.students(track_id, intake_id, branch_id);

create nonclustered index ix_class_offerings_intake_id
on courses.class_offerings(intake_id);

create nonclustered index ix_options_question_id
on questions_bank.options(question_id);

create nonclustered index ix_exam_students_exam_id
on exams.exam_students(exam_id);

create nonclustered index ix_student_answers_question_id
on answers.student_answers(question_id);

create nonclustered index ix_student_answers_examstudent_question
on answers.student_answers(exam_student_id, question_id);
go