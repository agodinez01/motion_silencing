% Motion silencing experiment for SCIoI Project 02
% Angelica Godinez 2023 with code from Martin Rolfs & Richard Schweitzer

clear all;
close all;

addpath("data/", "functions/", "images/")

global setting trial

computer = "dark";

setting.TEST          = 0; % test in dummy mode? 0=with EyeLink; 1=mouse as eye;
setting.expName       = 'MoSi';

generalSetup; % Filename, eye, language.. ect

%% Main loop
try
    % Prepare screen
    prepScreen(computer)

    if setting.contPrevious == 'y' % If the file exists and there are still trials remaining, continue data
        trial = continueData.trial;
        params = continueData.params;
%         scr = continueData.scr;
%         setting = continueData.setting;
%         fixation = continueData.fixation;
%         eldata = continueData.eldata;
    else                           % Otherwise, start a new data matrix
        trial = prepTrials3;
    end  

    % Initialize EyeLink connection
    if setting.TEST == 0
        [el, err] = initEyelink(setting.subjectCode);
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
    eyeLinkCleanUp;

catch me
    rethrow(me);
    eyeLinkCleanUp;
end

disp('Saving matfile...');

save([setting.filename], 'trial', 'setting', 'scr', 'params', 'fixation', 'eldata')

Screen('CloseAll');
%cd('../mat/');
% Quickly vizualize data 
%fitDataPsychometric(general.filename)
clear mex;
