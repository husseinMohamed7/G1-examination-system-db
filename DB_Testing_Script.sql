USE g1_examination_system;
GO
-------------------------------------------------------------------------------
-- Table Queries
-------------------------------------------------------------------------------

-- core schema tables
SELECT * FROM core.users;
SELECT * FROM core.managers;
SELECT * FROM core.departments;
SELECT * FROM core.tracks;
SELECT * FROM core.branches;
SELECT * FROM core.intakes;
SELECT * FROM core.instructors;
SELECT * FROM core.students;
GO

-- courses schema tables
SELECT * FROM courses.courses;
SELECT * FROM courses.class_offerings;
GO

-- questions_bank schema tables
SELECT * FROM questions_bank.questions;
SELECT * FROM questions_bank.options;
SELECT * FROM questions_bank.accepted_text_answers;
GO

-- exams schema tables
SELECT * FROM exams.exams;
SELECT * FROM exams.exam_questions;
SELECT * FROM exams.exam_students;
GO

-- answers schema tables
SELECT * FROM answers.student_answers;
SELECT * FROM answers.student_exam_results;
SELECT * FROM answers.class_results;
GO

-- Example INSERT statements (use with caution, as these might conflict with existing data or constraints)
INSERT INTO core.departments (name) VALUES ('New Department');
GO
INSERT INTO core.branches (name, location) VALUES ('New Branch', 'New City');
GO

-- Example UPDATE statement
UPDATE core.departments SET name = 'Updated Department' WHERE department_id = 1;
GO

-------------------------------------------------------------------------------
-- Stored Procedure Queries
-------------------------------------------------------------------------------

-- manager_api schema stored procedures
-- manager_api.sp_add_user (Example - requires careful parameter selection to avoid conflicts)
EXEC manager_api.sp_add_user @username = 'testuser1', @password = 'P@ssw0rd1', @user_type = 'student', @name = 'Test User One', @email = 'test1@example.com', @branch_id = 1, @track_id = 1, @intake_id = 1;
GO

EXEC manager_api.sp_edit_branch @name = 'Cairo Branch', @location = 'Cairo';
GO
EXEC manager_api.sp_edit_track @name = 'Cloud Computing', @departmentid = 1;
GO
EXEC manager_api.sp_edit_intake @intakeyear = 2026;
GO
EXEC manager_api.sp_edit_department @departmentname = 'Software Engineering';
GO
EXEC manager_api.sp_delete_core_entity @type = 'branch', @id = 2; -- Use with caution, this deletes the 'Cairo Branch' created above
GO

-- instructor_api schema stored procedures
EXEC instructor_api.sp_compute_final_exam_result @exam_student_id = 7;
GO
EXEC instructor_api.sp_manual_score_update @student_answer_id = 1, @manual_score = 18.00;
GO
EXEC instructor_api.sp_searchexams @course_name = 'sql fundamentals', @exam_type = 'main';
GO

-- Declare a table variable for questions
DECLARE @questions AS exams.questionlist;
INSERT INTO @questions (questionid, questiondegree) VALUES (1, 20), (2, 15);
EXEC instructor_api.sp_add_exam 
    @instructorid = 2, 
    @courseid = 1, 
    @classid = 1, 
    @examid = 0,
    @examtype = 'main', 
    @starttime = '2025-09-01 09:00:00', 
    @endtime = '2025-09-01 11:00:00', 
    @totaltime = 120, 
    @extratime = 10, 
    @openbook = 0, 
    @allowcalc = 1, 
    @questions = @questions;
GO
EXEC instructor_api.sp_searchstudents @studentname = 'Hussein Mohamed';
GO

-------------------------------------------------------------------------------
-- student_api schema stored procedures
-------------------------------------------------------------------------------

exec as login = 'Nora23';

-- take an exam
exec student_api.sp_take_exam 
    @username = 'Nora23', 
    @exam_id = 1;

-- submit an answer
exec student_api.sp_submit_answer 
    @username = 'Nora23',
    @exam_id = 1,
    @question_id = 10,
    @option_id = 2;  

-- submit answers
exec student_api.sp_submit_answer 
    @username = 'Nora23',
    @exam_id = 1,
    @question_id = 11,
    @answer_text = N'My written answer';

-- view submitted answers
exec student_api.sp_get_submitted_answers 
    @username = 'Nora23',
    @exam_id = 1;

-- return to the original execution context
revert;
go

-------------------------------------------------------------------------------
-- Function Queries
-------------------------------------------------------------------------------

-- instructor_api schema functions
SELECT instructor_api.fn_check_mcq_answers(1); -- Checks if option_id 1 is correct
GO
SELECT instructor_api.fn_check_text_answers(3, 'create table students'); -- Checks if text answer for question_id 3 is valid
GO

-------------------------------------------------------------------------------
-- View Queries
-------------------------------------------------------------------------------

-- manager_api schema views
SELECT * FROM manager_api.vw_all_users;
SELECT * FROM manager_api.vw_system_dashboard;
SELECT * FROM manager_api.vw_course_performance;
SELECT * FROM manager_api.vw_instructor_performance;
SELECT * FROM manager_api.vw_student_progress;
SELECT * FROM manager_api.vw_exam_details;
SELECT * FROM manager_api.vw_questions_overview;
SELECT * FROM manager_api.vw_departments_overview;
SELECT * FROM manager_api.vw_branches_overview;
GO

-- instructor_api schema views
SELECT * FROM instructor_api.vw_questions;
SELECT * FROM instructor_api.vw_question_types;
SELECT * FROM instructor_api.vw_question_options;
SELECT * FROM instructor_api.vw_accepted_text_answers;
SELECT * FROM courses.courses;
SELECT * FROM courses.class_offerings;
SELECT * FROM instructor_api.vw_exams;
SELECT * FROM instructor_api.vw_exam_question_details;
SELECT * FROM instructor_api.vw_exam_students;
SELECT * FROM instructor_api.vw_student_result;
SELECT * FROM instructor_api.vw_exam_details;
GO