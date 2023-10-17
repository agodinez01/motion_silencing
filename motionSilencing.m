% Motion silencing experiment for SCIoI Project 02
% Angelica Godinez 2023 with code from Martin Rolfs & Richard Schweitzer
%
% TODO:
% Check start trial when continuing from previous session
% Check fixation requirement once all stim values are set!!

clear all;
close all;

addpath("data/", "functions/")

global general setting scr trial fixation params keys

computer = "dark";

setting.TEST          = 1; % test in dummy mode? 0=with EyeLink; 1=mouse as eye;
general.expName       = 'MSV1';

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

%% Main loop
try
    % Prepare screen
    prepScreen(computer)

    if general.contPrevious == 'y' % If the file exists and there are still trials remaining, continue data
        trial = continueData.trial;
    else                           % Otherwise, start a new data matrix
        trial = prepTrials;
    end  

    % Initialize EyeLink connection
    if setting.TEST == 0
        [el, err] = initEyelink(general.subjectCode);
        if err == el.TERMINATE_KEY
            return
        end
    else
        el = [];
    end

    % a first calibration? Can also be done when starting a new block.
    first_calib_result = doCalibration(el);

    % Set keyboard
    setKeys;  
    
    experimentalLoop;
    
    % Shut everything down
    reddUp;

catch me
    rethrow(me);
    reddUp;
end

disp('Saving matfile...');

save(general.filename, 'trial'); % Save matfile
%writematrix(data.trial, strcat('../csv/',general.csvname, '.csv')); % Save csv file

Screen('CloseAll');
%cd('../mat/');
% Quickly vizualize data 
%fitDataPsychometric(general.filename)
clear mex;
