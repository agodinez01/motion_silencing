% Motion silencing experiment for SCIoI Project 02
% Angelica Godinez 2023 with code from Martin Rolfs & Richard Schweitzer
%
% TODO:
% Check start trial when continuing from previous session
% Check fixation requirement once all stim values are set!!

clear all;
close all;

addpath("data/", "functions/", "images/")

global general setting trial

computer = "dark";

setting.TEST          = 0; % test in dummy mode? 0=with EyeLink; 1=mouse as eye;
general.expName       = 'MSV1';

generalSetup; % Filename, eye, language.. ect

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
