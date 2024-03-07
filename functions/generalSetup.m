global setting

%% Filename and dominant eye
setting.subjectID     = input('\n Insert observer ID (e.g., 01): ', 's');
% Make sure the subject ID is a 2-digit number
assert(length(setting.subjectID) == 2, '%s is not 2 digits! Please make sure that the subject ID is 2 digits (e.g., 01)', setting.subjectID);
assert(length(str2num(setting.subjectID)) == 1, '%s in not a number! Please make sure that the subject ID is a 2-digit number (e.g., 01) ', setting.subjectID);

setting.sessionNum    = input('\n Please enter the session number (0 for practice): ');
assert(isnumeric(setting.sessionNum), '\n Please make sure the session number is numeric! ');

setting.block         = input('\n Please enter the block number [1, 2 or 3] : ');
assert((setting.block == 1) || (setting.block == 2) || (setting.block == 3)  || (setting.block == 4)  || (setting.block == 5), '\n Please make sure the block number is 1, 2, 3, 4 or 5. ');

setting.eyeUsed = input('\n Which is the dominant eye of the participant? (Left= 0; Right= 1) :');
assert((setting.eyeUsed == 0) || (setting.eyeUsed == 1), '\n Make sure its 0 (left) or 1 (right) \n')

setting.language      = input('\n German or English? [g or e]: ', 's');
assert((setting.language == 'g' || setting.language == 'e'), '\n Make sure its g (german) or e (english) \n')

% Get date and time for file name
setting.dTime         = datetime('now');
setting.dTime         = datestr(setting.dTime);

% Make csv and matlab files
setting.csvname       = strcat(convertMonth2Number(setting.dTime), setting.dTime(1:2), setting.dTime(8:11), '_', setting.dTime(13:14), setting.dTime(16:17), setting.dTime(19:20), '_', num2str(setting.subjectID), '_', num2str(setting.sessionNum), '_', num2str(setting.block));
setting.filename      = strcat(convertMonth2Number(setting.dTime), setting.dTime(1:2), setting.dTime(8:11), '_', setting.dTime(13:14), setting.dTime(16:17), setting.dTime(19:20), '_', num2str(setting.subjectID), '_', num2str(setting.sessionNum), '_', num2str(setting.block), '.mat');
setting.subjectCode   = strcat(setting.subjectID, num2str(setting.sessionNum), num2str(setting.block));

% Check if the file already exists. If so, you have the option to continue
% where you left off. If not, it will create a new file
[setting.filename, setting.contPrevious, continueData] = doesFileExists(setting.filename);
