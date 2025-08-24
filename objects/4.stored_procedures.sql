-------------------------------------------------------------------------------
-- Stored Procedures
-------------------------------------------------------------------------------
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