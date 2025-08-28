-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
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