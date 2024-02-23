function output = join_subject_files(files, subject)

sessions = find(contains(files, num2str(subject))); % Find all the sessions from the indicated subject

session_name = {};
session_idx = [];
session = {};

split = strfind(files{1}, '_'); % Find delimiter and store it as a variable for parsing

% Get session name, index and load csv file for all sessions 
for idx = 1:length(sessions)
    if str2num(files{sessions(idx)}(split(2)+1:split(3)-1)) ~= subject
        fprintf('File %s does not match subject number %s \n', files{sessions(idx)}, num2str(subject));
    elseif str2num(files{sessions(idx)}(split(2)+1:split(3)-1)) == subject
        fprintf('File %s matches subject number %s \n', files{sessions(idx)}, num2str(subject));
        %split = strfind(files{sessions(idx)}, '_'); % Find the delimiter and store it in a variable

        cell_block   = str2num(files{sessions(idx)}(split(4)+1));
        cell_session = str2num(files{sessions(idx)}(split(3)+1));

        session_name{cell_session,cell_block} = files{sessions(idx)};
        session_idx(idx) = find(contains(files, session_name{cell_session,cell_block}));
        session{cell_session, cell_block} = csvread(files{session_idx(idx)});
    
        [rows, columns] = size(session{cell_session, cell_block});
        session{cell_session, cell_block}(:,columns+1) = repelem(str2num(session_name{cell_session, cell_block}(split(3)+1)), length(session{cell_session, cell_block}))'; % Add session id 
        session{cell_session, cell_block}(:,columns+2) = repelem(str2num(session_name{cell_session, cell_block}(split(4)+1)), length(session{cell_session, cell_block}))'; % Add block id
    end
end

subData = vertcat(session{:});
output = subData;