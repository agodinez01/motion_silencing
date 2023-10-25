global general setting

%% Filename and dominant eye
general.subjectID     = input('\n Insert observer ID (e.g., 01): ', 's');
% Make sure the subject ID is a 2-digit number
assert(length(general.subjectID) == 2, '%s is not 2 digits! Please make sure that the subject ID is 2 digits (e.g., 01)', general.subjectID);
assert(length(str2num(general.subjectID)) == 1, '%s in not a number! Please make sure that the subject ID is a 2-digit number (e.g., 01) ', general.subjectID);

general.sessionNum    = input('\n Please enter the session number (0 for practice): ');
assert(isnumeric(general.sessionNum), '\n Please make sure the session number is numeric! ');

general.block         = input('\n Please enter the block number [1, 2 or 3] : ');
assert((general.block == 1) || (general.block == 2) || (general.block == 3), '\n Please make sure the block number is 1, 2 or 3. ');

setting.eyeUsed = input('\n Which is the dominant eye of the participant? (Left= 0; Right= 1) :');
assert((setting.eyeUsed == 0) || (setting.eyeUsed == 1), '\n Make sure its 0 (left) or 1 (right) \n')

general.language      = input('\n German or English? [g or e]: ', 's');
assert((general.language == 'g' || general.language == 'e'), '\n Make sure its g (german) or e (english) \n')

% Get date and time for file name
general.dTime         = datetime('now');
general.dTime         = datestr(general.dTime);

% Make csv and matlab files
general.csvname       = strcat(convertMonth2Number(general.dTime), general.dTime(1:2), general.dTime(8:11), '_', general.dTime(13:14), general.dTime(16:17), general.dTime(19:20), '_', num2str(general.subjectID), '_', num2str(general.sessionNum), '_', num2str(general.block));
general.filename      = strcat(convertMonth2Number(general.dTime), general.dTime(1:2), general.dTime(8:11), '_', general.dTime(13:14), general.dTime(16:17), general.dTime(19:20), '_', num2str(general.subjectID), '_', num2str(general.sessionNum), '_', num2str(general.block), '.mat');
general.subjectCode   = strcat(general.subjectID, num2str(general.sessionNum), num2str(general.block));

% Check if the file already exists. If so, you have the option to continue
% where you left off. If not, it will create a new file
[general.filename, general.contPrevious, continueData] = doesFileExists(general.filename);
