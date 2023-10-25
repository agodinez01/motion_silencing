% Experimental loop

global general setting scr trial fixation params keys %#ok<*NUSED>

% Load instruction slides
if general.language == 'e'
    instruction1 = imread('instruction_1_e.JPG');
    instruction2 = imread('instruction_2_e.JPG');
elseif general.language == 'g'
    instruction1 = imread('instruction_1_g.JPG');
    instruction2 = imread('instruction_2_g.JPG');
end

% Make instruction textures
instruction1Text = Screen('MakeTexture', scr.window, instruction1);
instruction2Text = Screen('MakeTexture', scr.window, instruction2);

% NEED TO FIGURE THIS OUT
% Check if continuing from a previous session
if general.contPrevious == 'y' 
    startTrial = size(trial,2) - setting.trialsRemaining;
    general.expStartTime = GetSecs;
else
    startTrial = 1;
end

for t = startTrial:size(trial,2) % Start main loop

    % Jitter placement of stimulus in x and y
    addXpos       = randi([fixation.posJitterMin, fixation.posJitterMax]); % Random position for x jitter
    addYpos       = randi([fixation.posJitterMin, fixation.posJitterMax]); % Random position for y jitter
    
    params.fixPos = [scr.center(1)+addXpos scr.center(2)+addYpos];         % Fixation position in x and y pix centered

    % Interest area for fixation. In this case a total of 2 degrees
    params.interestArea  = [params.fixPos(1)-round(scr.pixelsPerDeg) params.fixPos(2)-round(scr.pixelsPerDeg)...
    params.fixPos(1)+round(scr.pixelsPerDeg) params.fixPos(2)+round(scr.pixelsPerDeg)];

    if t == 1
       
        Screen('DrawTexture', scr.window, instruction1Text, [], [0 0 scr.windowRect(3) scr.windowRect(4)]);
        Screen('Flip', scr.window)

        KbWait([], 2); % Wait for button press

        Screen('DrawTexture', scr.window, instruction2Text, [], [0 0 scr.windowRect(3) scr.windowRect(4)]);
        Screen('Flip', scr.window)

        KbWait([], 2); % Wait for button press

        str = sprintf(['Please maintain fixation at the dot. \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n' ...
            'Press the space bar to begin.']);
        
        DrawFormattedText(scr.window, str, 'center', 'center', 0);
        Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, fixation.fixCkCol_initial, params.fixPos, 2); % fixation dot
        Screen('Flip', scr.window);

        KbWait([], 2); % Wait for button press
    end

    % If we want to present breaks/ show progress, we need to add it here
        % Present breaks after every X time set by fixation.breakTime
%     if rem(t,10) == 0
%         str = sprintf(['Blink']);
% 
%         DrawFormattedText(scr.window, str, 'center', scr.windowRect(4) - 300, 0);
%         Screen('Flip', scr.window)
%         WaitSecs(fixation.breakTime);
% 
%         str = sprintf(['Please press space bar to continue']);
%         
%         DrawFormattedText(scr.window, str, 'center', scr.windowRect(4) - 300, 0);
%         Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.gray, [scr.center(1)+addXpos scr.center(2)+addYpos], 2); % fixation dot
%         Screen('Flip', scr.window)
% 
%         KbWait([], 2); % Wait for button press
%     end
% 
%     % Present progress every quarter
%     if (t == data.table(end,1)/4) || (t == data.table(end,1)/2) || (t == data.table(end,1) * 3/4)
%         
%         str = sprintf([strcat('Trial number ', num2str(t), ' out of '), num2str(data.table(end,1))]);
%         DrawFormattedText(scr.window, str, 'center', scr.windowRect(4) - 300, 0);
%         Screen('Flip', scr.window)
%         WaitSecs(fixation.breakTime);
%     end

    % Perform calibration as determined
%     % Perform calibration as determined (every quarter)
%     if mod(t, setting.performCalibration) == 0
%         if setting.TEST == 0
%             disp([num2str(Getsecs) ' Performing calibration now.']);
%             calibResult = EyelinkDoTrackerSetup(el);
%             if calibResult == el.TERMINATE_KEY
%                 return
%             end
%         end
%     else
%         calibResult = [];
%     end
    
    %---------------------------------------------------------------------%
    %%%%%%%%%%%%% Prepare Eyelink for recording this trial %%%%%%%%%%%%%%%%
    %---------------------------------------------------------------------%
    if setting.TEST==0 % Prepare EyeLink for recording this trial
        
        % This supplies a title at the bottom of the eyetracker display
        if t <= size(trial,2)
            Eyelink('command', 'record_status_message ''Trial %d of %d in block %d''', t, size(trial,2), general.block);
        end
        
        % This supplies a screen for the experimenter
        % clear tracker display
        Eyelink('Command', 'clear_screen %d', 0);
        
        % Fixation rectangle
        Eyelink('command','draw_box %d %d %d %d 15', ...
            params.interestArea(1), params.interestArea(2), params.interestArea(3), params.interestArea(4)); % 2 deg of visual angle from the fixation stimulus
        
        % this marks the start of the trial
        Eyelink('message', 'TRIALID %d', t);
        Eyelink('message', 'SYNCTIME');		% zero-plot time for EDFVIEW

        % start the recording if it has not started yet
        if ~setting.is_recording
            
            while ~setting.is_recording
                Eyelink('startrecording');	% start recording
                WaitSecs(.1);
                err=Eyelink('checkrecording'); 	% check recording status
                
                if err==0
                    setting.is_recording = 1;
                    Eyelink('message', 'RECORD_START');
                else
                    setting.is_recording = 0;
                    Eyelink('message', 'RECORD_FAILURE');
                end
            end
        end
    end
    %---------------------------------------------------------------------%
    %%%%%%%%%%%%%%%%%%%%%%%%%%% End EyeLink prep %%%%%%%%%%%%%%%%%%%%%%%%%%
    %---------------------------------------------------------------------%
    if setting.TEST==0
        Eyelink('message', 'TRIAL_START %d', t);
        Eyelink('message', 'SYNCTIME');
    end

    %% Initial fixation control here, needs to be passed in order to trigger stim
    % now run as long as the subject needs to complete fixation control

    % pre-allocate a few variables:
    % important: here we allow a shortcut to end the experiment
    params.doEscape       = 0; % 1: the experiment will be terminated (triggered by a keypress during fixation control)
    
    % pre-allocate fixation control variables
    params.fixReq         = 1;              % is set to 0 once fixation is passed
    params.fixaOn         = NaN;            % time when fixation dot is presented
    params.fixStart       = NaN;            % time when fixation starts
    params.fixBrokenCntr  = 0;              % is increased each time the fixation is broken
    params.fixBrokenTime  = NaN;            % last time when fixation was broken
    params.fixEnd         = NaN;            % time when fixation control is successful
    eldata.x              = NaN(1,1000000); % x coord
    eldata.y              = NaN(1,1000000); % y coord of Eye link
    eldata.t              = NaN(1,1000000); % eye link timestamp (when retrieved)
    eldata.t_eye          = NaN(1,1000000); % eye link timestamp
   
    % ... and a few control variables
    firstInsideFixLoc = 0;         % is set to 1 when the fixation is within range
    tframe            = 0;         % iterator for number of eyelink samples retrieved
    current_fix       = [NaN NaN]; % the current fixation [x, y]
    
    % Draw fixation to buffer
    Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % Fixation
    params.fixaOn = Screen('Flip', scr.window); % flip upon next refresh and mark it

    if setting.TEST == 0
        Eyelink('message', 'EVENT_fixaOn');
    end
    disp([num2str(params.fixaOn), ' Fixation on.']);

    %---------------------------------------------------------------------%
    %%%%%%%%%%%%%%%%%%%%%%%%%% Check Fixation Loop %%%%%%%%%%%%%%%%%%%%%%%%
    %---------------------------------------------------------------------%
    while params.fixReq == 1 && params.doEscape == 0
        
        % always check for new eye link or mouse data
        if setting.TEST == 0 % check eyelink
            
            if Eyelink('NewFloatSampleAvailable') > 0 % check whether there is a new sample available
                % get the sample in the form of an event structure
                tframe = tframe + 1;
                [eldata.x(tframe), eldata.y(tframe), eldata.t(tframe), eldata.t_eye(tframe), ~] = getCoord(el, setting, scr.window);
                currentFix = [eldata.x(tframe), eldata.y(tframe), eldata.t(tframe)];
                gotNewSample = 1;
            else
                gotNewSample = 0;
            end

             else % check mouse to simulate gaze samples
            
            if (tframe == 0) || (GetSecs - eldata.t(tframe) > 1/500) % simulating a sampling rate of 500 Hz
                tframe = tframe + 1;
                [eldata.x(tframe), eldata.y(tframe), eldata.t(tframe)] = getCoord(el, setting, scr.window);
                currentFix = [eldata.x(tframe), eldata.y(tframe), eldata.t(tframe)];
                gotNewSample = 1;
            else
                gotNewSample = 0;
            end
        end

         % have we got a new sample? then check whether it's within range
        if gotNewSample
            dist = hypot(currentFix(1) - params.fixPos(1), currentFix(2) - params.fixPos(2));
            
            % check whether the eye is currently in the fixation rect
            if dist < fixation.fixCkRad %isDotWithinCircle(current_fix, params.fixPos, fixation.fixCkRad) % fixation is in fixation circle

                % draw the dot in the middle of the circle:
                Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.white, [params.fixPos(1) params.fixPos(2)], 2); % fixation dot

                if firstInsideFixLoc == 0 % fixation is in the rect for the first time, or has been broken before
                    firstInsideFixLoc = 1;
                    params.fixStart = GetSecs;
                    
                    if setting.TEST == 0
                        Eyelink('message', 'EVENT_fixStart');
                    end
                
                else % fixation has been in the rect before
                    
                    % have we spent enough time (specified by fixDur) fixating,
                    % so that we can turn on the cue?
                    if GetSecs >= (params.fixStart + fixation.fixDurReq) % fixation passed
                        params.fixEnd = GetSecs;
                        
                        if setting.TEST == 0
                            Eyelink('message', 'EVENT_fixEnd');
                        end
                        
                        disp([num2str(GetSecs), ' Fixation successful.']);
                        params.fixReq = 0;   % fixation not required anymore -> show thestimulus
                    end
                end

                else % fixation is no longer in the circle

                Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % fixation dot
                
                % If the eye has been in the circle before and participant
                % has fixated but broken the fixation, record 
                if firstInsideFixLoc == 1
                    params.fixBrokenTime = GetSecs;
                    if setting.TEST == 0
                        Eyelink('message', 'EVENT_fixBroken');
                    end
                    
                    params.fixBrokenCntr = params.fixBrokenCntr + 1; % Increase fixation broken counter
                    % reset variables, because fixation was broken
                    firstInsideFixLoc = 0; % fixation is not in the rect anymore
                end
            end
        end

        % BREAK OUT OF THE LOOP and request a calibration IF fixation is still
        % required and the fixation is not in the target area ...
        if params.fixReq == 1 && firstInsideFixLoc == 0
            % 1. td.fixBrokenCntr has exceeded fixBrokenMax.
            if params.fixBrokenCntr >= fixation.fixBrokenMax
                disp([num2str(GetSecs), ' fixBrokenMax reached --> exiting Trial ', num2str(t)]);
                break
                % 2. a participant spends maxTimeWithoutFix after dot onset or after
                % last broken fixation without fixating the initial target
            elseif (isnan(params.fixBrokenTime) && GetSecs-params.fixaOn > fixation.maxTimeWithoutFix) || ...
                    (~isnan(params.fixBrokenTime) && GetSecs-params.fixBrokenTime > fixation.maxTimeWithoutFix)
                disp([num2str(GetSecs), ' maxTimeWithoutFix reached --> exiting Trial ', num2str(t)]);
                break
            end
        end
        
        Screen('Flip', scr.window); % flip upon next refresh

    end

    %---------------------------------------------------------------------%
    %%%%%%%%%%%%%%%%%%%%%%%% Check Fixation Loop End %%%%%%%%%%%%%%%%%%%%%%
    %---------------------------------------------------------------------%

    %% Stimulus presentation starts here
    if setting.TEST == 0
        Eyelink('message', 'TRIAL_START %d', t);
        Eyelink('message', 'SYNCTIME');
    end

    nF = trial(t).nFrames; % number of frames
    mfTest = zeros(1,nF);

    % predefine time stamps
    tStart = [];
    tEndMo = [];
    tResp0 = [];
    tClear = [];
    tResp  = [];

    % Draw fixation spot and flip
    Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % fixation dot
    tIni = Screen(scr.window, 'Flip');

    % clear keyboard buffer
    FlushEvents('KeyDown');

    trialDone = 0;
    frequencyChange = 1;
    replayRotation = 0;

    % First show the entire sequence
    for f = 1:trial(t).nStationary % Stationary part and response
        DrawFormattedText(scr.window, num2str(t), scr.xres - 200, scr.yres - 100, 0);
        Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % Fixation
        Screen('DrawDots', scr.window, [trial(t).dots(f).xpix+addXpos trial(t).dots(f).ypix+addYpos]', trial(t).dots(f).size', trial(t).dots(f).col', [], 2);
        Screen('DrawingFinished', scr.window);
        
        mfTest(f) = Screen('Flip', scr.window);
        replayRotation = 0;
    end
    
    for f = trial(t).nStationary:nF % Rotation part
        DrawFormattedText(scr.window, num2str(t), scr.xres - 200, scr.yres - 100, 0);
        Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % Fixation
        Screen('DrawDots', scr.window, [trial(t).dots(f).xpix+addXpos trial(t).dots(f).ypix+addYpos]', trial(t).dots(f).size', trial(t).dots(f).col', [], 2);
        Screen('DrawingFinished', scr.window);
        
        mfTest(f) = Screen('Flip', scr.window);
    end

    while trialDone == 0
        if replayRotation == 0
            for f = 1:trial(t).framesPerCycle % Stationary part and response
                DrawFormattedText(scr.window, num2str(t), scr.xres - 200, scr.yres - 100, 0);
                Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % Fixation
                Screen('DrawDots', scr.window, [trial(t).newDots(1).xpix+addXpos trial(t).newDots(1).ypix+addYpos]', trial(t).newDots(f).size', trial(t).newDots(f).col', [], 2);
                Screen('DrawingFinished', scr.window);
                
                mfTest(f) = Screen('Flip', scr.window);

                [keyIsDown, secs, keyCode] = KbCheck;

                if keyCode(keys.escape)
                    ShowCursor;
                    sca;
                    return
                elseif keyCode(keys.upKey)
                    % Make new sine wave for flicker
                    frequencyChange = frequencyChange + 0.05; % Increases frequency
                    fprintf('Frequency change = %s ',num2str(frequencyChange));

                    trial(t).framesPerCycle = round(1/frequencyChange * scr.measuredFrameRate);
                    trial(t).framesPerCycle
                    trial(t).newSamples = 1:trial(t).framesPerCycle;
        
                    % Make sine wave for flicker
                    trial(t).fullWaveFormNew = params.amplitude * sind(frequencyChange*(360/trial(t).originalFramesPerCycle)*trial(t).newSamples+trial(t).phaseShift) + trial(t).verticalShift;

                    tic
                    for i = 1:trial(t).framesPerCycle
                        % Reset variables
                        trial(t).newDots(i).size       = [];
                        trial(t).newDots(i).xpix       = [];
                        trial(t).newDots(i).ypix       = [];
                        trial(t).newDots(i).col        = [];

                        trial(t).newDots(i).size       = trial(t).dots(1).size;
                        trial(t).newDots(i).xpix       = trial(t).dots(1).xpix;
                        trial(t).newDots(i).ypix       = trial(t).dots(1).ypix;
                        trial(t).newDots(i).col(:,1:3) = repmat(trial(t).fullWaveFormNew(:,i),1,3);
                    end
                    toc
        
                    trialDone      = 0;
                    replayRotation = 0;
                    KbReleaseWait();
                    
                elseif keyCode(keys.downKey)

                    % Make new sine wave for flicker
                    if frequencyChange <= 0.05 % Make sure it cannot go lower than 0
                        frequencyChange = 0.05;
                    else
                        frequencyChange = frequencyChange - 0.05; % Decreases frequency in Hz
                    end
                    fprintf('Frequency change = %s ',num2str(frequencyChange));

                    trial(t).framesPerCycle = round(1/frequencyChange * 1000/scr.frameDuration); % [msec]
                    trial(t).framesPerCycle
                    trial(t).newSamples     = 1:trial(t).framesPerCycle;

                    % Make sine wave for flicker
                    trial(t).fullWaveFormNew =   params.amplitude * sind(frequencyChange*(360/trial(t).originalFramesPerCycle)*trial(t).newSamples + trial(t).phaseShift) + trial(t).verticalShift;
                    
                    tic
                    for i = 1:trial(t).framesPerCycle
                        % Reset variables
                        trial(t).newDots(i).size       = [];
                        trial(t).newDots(i).xpix       = [];
                        trial(t).newDots(i).ypix       = [];
                        trial(t).newDots(i).col        = [];

                        trial(t).newDots(i).size       = trial(t).dots(1).size;
                        trial(t).newDots(i).xpix       = trial(t).dots(1).xpix;
                        trial(t).newDots(i).ypix       = trial(t).dots(1).ypix;
                        trial(t).newDots(i).col(:,1:3) = repmat(trial(t).fullWaveFormNew(:,i),1,3);
                    end
                    toc
        
                    trialDone = 0;
                    replayRotation = 0;
                    KbReleaseWait();
        
                elseif keyCode(keys.space)
                    replayRotation = 1; % Show rotation
                    trialDone      = 0; % Do not finish trial
                    keepLooping    = 1;
                    break;
        
                elseif keyCode(keys.enter(1))
                    trialDone                 = 1;
                    replayRotation            = 2;
                    trial(t).flickerFrequency = frequencyChange;
                    
                    data(t, 1) = t;
                    data(t, 2) = trial(t).dotSpeed;
                    data(t, 3) = frequencyChange;

                end
            end
            
        elseif replayRotation == 1
            
            while keepLooping == 1

                for f = trial(t).nStationary:nF % Rotation part
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown && keyCode(keys.space)
                        DrawFormattedText(scr.window, num2str(t), scr.xres - 200, scr.yres - 100, 0);
                        Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % Fixation
                        Screen('DrawDots', scr.window, [trial(t).dots(f).xpix+addXpos trial(t).dots(f).ypix+addYpos]', trial(t).dots(f).size', trial(t).dots(f).col', [], 2);
                        Screen('DrawingFinished', scr.window);
                    
                        mfTest(f) = Screen('Flip', scr.window);

                    elseif ~keyIsDown
                        keepLooping    = 0;
                        replayRotation = 0;
                        break;
                    end
                end
            end
            replayRotation = 0;

        elseif replayRotation == 2
            trialDone = 1;
            if setting.TEST == 0
                Eyelink('message', 'TrialEnd %d', t)
            end

        end
    end
end % End main loop

if setting.TEST==0 % Post final message to Eyelink
    WaitSecs(0.1); % record additional 100 msec of data
    Eyelink('stoprecording'); 
    WaitSecs(0.9);
    Eyelink('command','clear_screen');
    Eyelink('command', 'record_status_message ''END''');
    
    PsychDataPixx('Close'); % Close DataPixx
end     

%End of experiment
DrawFormattedText(scr.window, 'Experiment has ended \n\n Thank you', 'center', 'center', scr.black);
Screen('Flip', scr.window);
KbStrokeWait;
