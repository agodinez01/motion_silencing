% Motion silencing experiment for SCIoI Project 02
% Angelica Godinez 2023 with code from Martin Rolfs & Richard Schweitzer
%
% TODO:
% Check fixation requirement once all stim values are set!!

clear all;
close all;

addpath(genpath("data/"), "functions/")

global general setting scr trial 

computer = "personal";

setting.TEST          = 1; % test in dummy mode? 0=with EyeLink; 1=mouse as eye;
general.expName       = 'MSV1';

%% Filename and dominant eye
general.subjectID     = input('\n Insert observer ID (e.g., 01): ', 's');
% Make sure the subject ID is a 2-digit number
assert(length(general.subjectID) == 2, '%s is not 2 digits! Please make sure that the subject ID is 2 digits (e.g., 01)', general.subjectID);
assert(length(str2num(general.subjectID)) == 1, '%s in not a number! Please make sure that the subject ID is a 2-digit number (e.g., 01) ', general.subjectID);

general.sessionNum    = input('\n Please enter the session number (0 for practice): ');
assert(isnumeric(general.sessionNum), '\n Please make sure the session number is numeric! ');

general.block         = input('\n Please enter the block number [1 or 2] : ');
assert((general.block == 1) || (general.block == 2), '\n Please make sure the block number is either 1 or 2. ');

% Get date and time for file name
general.dTime         = datetime('now');
general.dTime         = datestr(general.dTime);

% Make csv and matlab files
general.csvname       = strcat(convertMonth2Number(general.dTime), general.dTime(1:2), general.dTime(8:11), '_', general.dTime(13:14), general.dTime(16:17), general.dTime(19:20), '_', num2str(general.subjectID), '_', num2str(general.sessionNum), '_', num2str(general.block));
general.filename      = strcat(convertMonth2Number(general.dTime), general.dTime(1:2), general.dTime(8:11), '_', general.dTime(13:14), general.dTime(16:17), general.dTime(19:20), '_', num2str(general.subjectID), '_', num2str(general.sessionNum), '_', num2str(general.block), '.mat');
general.subjectCode   = strcat(general.subjectID, num2str(general.sessionNum), num2str(general.block));

% Check if the file already exists. If so, you have the option to continue
% where you left off. If not, it will create a new file
[general.filename, general.csvname, general.contPrevious, continueData] = doesFileExists(general.filename, general.csvname);

setting.eyeUsed = input('\n Which is the dominant eye of the participant? (Left= 0; Right= 1) :');
assert((setting.eyeUsed == 0) || (setting.eyeUsed == 1), '\n Make sure its 0 (left) or 1 (right) \n')

%% Display setup
% Set screen preference
Screen('Preference', 'SkipSyncTests', 0); % Make sure this is set to 0 when running actual experiment for accurate timing
PsychDefaultSetup(2); % Important default settings for Psychtoolbox

if setting.TEST == 1 % When in dummy mode, present screen to be half transparent
    PsychDebugWindowConfiguration(0, 0.5);
end

if (lower(computer) == "work") || (lower(computer) == "personal") 
    scr.screenWidth      = 53;     % [cm]
    scr.screenHeight     = 30;     % [cm]
    scr.viewingDistance  = 40;     % [cm]
    scr.frameRate        = 60;     % [Hz]
elseif lower(computer) == "dark"
    % VPixx/ DarkRoom
    scr.screenWidth     = 150;     % [cm]
    scr.screenHeight     = 84;     % [cm]
    scr.viewingDistance = 180;     % [cm]
end

scr.screens = Screen('Screens'); % Get the screen numbers.
screenNumber = max(scr.screens); % Draw on screen with max number

% Set DataPixx connection
if lower(computer) == "dark"
    
    PsychDataPixx('Open')
    %PsychDataPixx('StopAllSchedules');
            
    %Setup specific mode of the Datapixx
    PsychDataPixx('EnableVideoScanningBacklight');
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
    PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
    PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput') % Enables high gray level resolution output with bitstealing
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma'); % Setup gamma correction method using simple power function for all color channels
    PsychImaging('PrepareConfiguration');
end

%% Screen coordinates and color
% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. With our setup, values defined between 0 and 1.
scr.white       = WhiteIndex(screenNumber);
scr.black       = BlackIndex(screenNumber);
scr.gray        = GrayIndex(screenNumber);

% Open an on screen window using PsychImaging and color it white.
[scr.window, scr.windowRect] = PsychImaging('OpenWindow', screenNumber, scr.white);
Screen('BlendFunction', scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Enable alpha blending for anti-aliasing

% Get screen info
scr.config     = Screen('Resolution', screenNumber); % Resolution of screen
scr.xres       = scr.config.width;
scr.yres       = scr.config.height;
scr.frameRate  = scr.config.hz;

scr.frameDuration     = round(Screen('GetFlipInterval', scr.window) *1000);  % [s] Framre duration
scr.measuredFrameRate = 1000/ scr.frameDuration;                             % [fps] Frames per second

%assert(scr.frameRate == round(scr.measuredScreenFrameRate))

% Get the center coordinates of the window
scr.center       = round([scr.windowRect(3) scr.windowRect(4)]/2);
scr.pixelsPerDeg = tan(1*pi/180) * scr.viewingDistance/(scr.screenWidth/scr.config.width);

% Set screen font
Screen('TextFont', scr.window, 'Ariel');
Screen('TextSize', scr.window, 36);

%% Fixation
% Here we set the size of the arms of our fixation cross
%fixCrossDimPix = 20;
fixation.fixCrossDimPix = 1;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
fixation.xCoords      = [-fixation.fixCrossDimPix fixation.fixCrossDimPix 0 0];
fixation.yCoords      = [0 0 -fixation.fixCrossDimPix fixation.fixCrossDimPix];
fixation.allCoords    = [fixation.xCoords; fixation.yCoords];
fixation.posJitterMin = -60; % [px]
fixation.posJitterMax = 60;  % [px]

% Set the line width for our fixation cross
fixation.dotWidthPix       = 7.5;                  % [px]
fixation.fixCkRad          = 2 * scr.pixelsPerDeg; % [dva] 2 * degs of visual angle 
fixation.fixCkCol          = scr.gray;             % When fixating. Dot is gray
fixation.fixCkCol_initial  = scr.black;            % When NOT fixating, the dot it black
fixation.fixDurReq         = 0.5;                  % jitter this
fixation.fixBrokenMax      = 10;                   % Maximum times fixation can be broken
fixation.maxTimeWithoutFix = 5;                    % [s] Max time without fixation
fixation.breakTime         = 2;                    % [s] Break 'blink' time and trial number showing

%Maximum priority level
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);

%% Continue data or create new data matrix
if general.contPrevious == 'y' % If the file exists and there are still trials remaining, continue data
    data = continueData;
else                           % Otherwise, start a new data matrix

    params.dotColor   = 1;                            % -1 = random hue (full saturation and brightness); values between 0 and 1: hue value for all dots
    params.dotNumber  = [50, 100];                    % dot number
    params.dotSpeed   = [3.75, 7.5, 15, 30, 60, 120]; % [deg/s] dot speed from Suchow & Alvarez (2011)
    params.dotSize    = 10;                           % [pix] dot size 
    %params.dotSpeed   = [-80 -40 -20 20 40 80]; % [deg/s] dot speed (neg is ccw)

    params.dotSpeedPerFrame = params.dotSpeed*(scr.frameDuration/1000) * pi/180; % [px/frame] Dot speed
    %params.dotChange        =  

    % Stimulus positioning
    params.minRad = 5; % [dva] minimum distance of dots from center
    params.maxRad = 8; % [dva] maximum distance of dots from center

    % Stimulus timing
    params.trialDuration      = 2.5; % [s] trial duration
    params.interTrialInterval = 0.5; % [s]

    params.nBlocks            = general.block;
    
    if general.sessionNum == 0  % Practice round
        params.nTrialsPerCellInBlock = 1; 
    else 
        params.nTrialsPerCellInBlock = 2;
    end

    params.randBlocks = 0;

    for b = 1:params.nBlocks
        t = 0;
        for ntpc = 1:params.nTrialsPerCellInBlock
            for dnum = 1:size(params.dotNumber, 2)
                for dspd = 1:size(params.dotSpeed, 2)
                    t = t+1; % Trial number
                    trial(t).nFrames = round(params.trialDuration*1000/scr.frameDuration); % Get number of frames given the duration of the stimulus presentation and the duration of each frame
                    
                    % Calculate initial dot positions
                    trial(t).dots(1).r = params.minRad + (params.maxRad - params.minRad)*rand(params.dotNumber(dnum),1);
                    trial(t).dots(1).a = 2*pi*rand(params.dotNumber(dnum),1);
                    [x, y] = pol2cart(trial(t).dots(1).a, trial(t).dots(1).r);
                    trial(t).dots(1).x = x;
                    trial(t).dots(1).y = y;
                   
                    % Translates dva to pix
                    trial(t).dots(1).xpix = x*scr.pixelsPerDeg + scr.center(1);
                    trial(t).dots(1).ypix = y*scr.pixelsPerDeg + scr.center(2);

                    distances = pdist2(trial(t).dots(1).xpix, trial(t).dots(1).ypix);

                    if params.dotColor == -1 
                        % Set hue randomly, keep saturation and brightness
                        % at 1, then translate to rgb and add one column
                        % for alpha.
                        trial(t).dots(1).col = [hsv2rgb([rand(params.dotNumber(dnum),1) ones(params.dotNumber(dnum),2)]) ones(params.dotNumber(dnum),1)];
                    elseif params.dotColor == 1 % Gray scale figure this out. Might be able to use rgba values
                        trial(t).dots(1).col = rgb2gray([hsv2rgb([rand(params.dotNumber(dnum),1) ones(params.dotNumber(dnum),2)])]);
                        %trial(t).dots(1).col = rgb2gray([hsv2rgb([rand(params.dotNumber(dnum),1) ones(params.dotNumber(dnum),2)])]);
                    else
                        trial(t).dots(1).col = [hsv2rgb([params.dotCol*ones(params.dotNumber(dnum),2)]) ones(params.dotNum(dnum), 1)];
                    end

                    % Determine the size of each dot
                    trial(t).dots(1).size = params.dotSize*ones(params.dotNumber(dnum),1);

                    % Calculate all other frames
                    for f = 2:trial(t).nFrames
                        trial(t).dots(f).a = trial(t).dots(f-1).a+params.dotSpeedPerFrame(dspd);
                        trial(t).dots(f).r = trial(t).dots(f-1).r;
                        [x,y] = pol2cart(trial(t).dots(f).a, trial(t).dots(f).r);
                        trial(t).dots(f).x = x;
                        trial(t).dots(f).y = y;

                        % Translate dva to pix
                        trial(t).dots(f).xpix = x*scr.pixelsPerDeg + scr.center(1);
                        trial(t).dots(f).ypix = y*scr.pixelsPerDeg + scr.center(2);
                        
                        % Determine the new color (constant at the moment)
                        trial(t).dots(f).col = trial(t).dots(f-1).col;

                        % Determine dot size for each dot and frame
                        % (constant at the moment)
                        trial(t).dots(f).size = trial(t).dots(f-1).size; 
                    end
                    
                    % Save the data file
                    trial(t).dotNumber = params.dotNumber(dnum);
                    trial(t).dotSpeed  = params.dotSpeed(dspd);
                    trial(t).dotColor  = params.dotColor;
                    
                    % Make mat file
                    data.table(t,1) = t;
                    data.table(t,2) = params.dotNumber(dnum);
                    data.table(t,3) = params.dotSpeed(dspd);
                    data.table(t,4) = params.dotColor;
                end
            end
        end
        r = randperm(t);
        params.b(b).trial = trial(r);
    end
    
    if params.randBlocks
        params.blockOrder = randperm(b);
        params.b = params(params.blockOrder);
    else
        params.nTrialsPerBlock = t;
    end
end 

%trial = trial(:,randperm(size(trial,2))); % Randomize trial order

%% initialize eyelink-connection
if setting.TEST == 0
    edffilename = strcat(general.subjectCode, '.edf');
    el = EyelinkInitDefaults(scr.window);

    % Initialization of the connection with Eyelink Gazetracker
    % Exit program is this fails.
    if ~EyelinkInit(setting.TEST ~=0)
        fprintf('Eyelink Init aborted. \n');
        Eyelink('Shutdown');
        return;
    end

     % Create edf file
     i = Eyelink('openfile', edffilename);
     if i~= 0
        fprintf(1, 'Cannnot create EDF file ''%s'' ', edffilename);
        Eyelink('Shutdown');
     end

    %---------------------------------------%
    % general information on the experiment %
    %---------------------------------------%
    Eyelink('command', 'add_file_preamble_text ''Recorded with MSV1 by Angelica Godinez''');
    
    %   SET UP TRACKER CONFIGURATION
    Eyelink('command', 'calibration_type = HV9');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,BUTTON');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');
    Eyelink('command', 'heuristic_filter = 1 1');
    Eyelink('command', 'calibration_area_proportion = 0.8 0.8'); % reduce distance between points
    Eyelink('command', 'sample_rate = 500');
    
    %--------------------------------------------------------%
    % write descriptions of the experiment into the edf-file %
    %--------------------------------------------------------%
    Eyelink('message', 'BEGIN OF DESCRIPTIONS');
    Eyelink('message', 'Subject code: %s', general.subjectCode);
    Eyelink('message', 'END OF DESCRIPTIONS');
    
    %--------------------------------------%
    % modify a few of the default settings %
    %--------------------------------------%
    el.backgroundcolour = scr.white;		 % background color when calibrating
    el.foregroundcolour = scr.black;       % foreground color when calibrating
    el.calibrationfailedsound = 0;			 % no sounds indicating success of calibration
    el.calibrationsuccesssound = 0;
    % you must call this function to apply the changes from above (says Mario
    % Kleiner)
    EyelinkUpdateDefaults(el);
    
    % test mode of eyelink connection
    status = Eyelink('isconnected');
    switch status
        case -1
            fprintf(1, 'Eyelink in dummymode.\n\n');
        case  0
            fprintf(1, 'Eyelink not connected.\n\n');
        case  1
            fprintf(1, 'Eyelink connected.\n\n');
    end
    
    if Eyelink('isconnected')==el.notconnected
        Eyelink('closefile');
        Eyelink('shutdown');
        Screen('closeall');
        return;
    end
    
    err=el.ABORT_EXPT; 

    if err == el.TERMINATE_KEY
        return
    end
else
    el=[];
end

%% First calibration
setting.performCalibration = size(data.table,1)/4; % Perform a calibration every quarter

if setting.TEST == 0
    disp([num2str(GetSecs) ' Performing Calibration now.']);
    calibResult = EyelinkDoTrackerSetup(el);
    if calibResult==el.TERMINATE_KEY
        return
    end
    % remember that we're not automatically recording after calibration
    setting.isRecording = 0;
else
    calibResult = [];
end

%% Set keyboard
KbName('UnifyKeyNames');
keys.leftKey    = KbName('LeftArrow');
keys.rightKey   = KbName('RightArrow');
keys.downKey    = KbName('DownArrow');
keys.upKey      = KbName('UpArrow');
keys.quitKey    = KbName('q');
keys.space      = KbName('space');
keys.escape     = KbName('ESCAPE');
keys.enter      = KbName('return');

FlushEvents('keyDown');

%% Run trials

% % create data file
% datFile = sprintf('%s.dat',general.subjectCode);
% datFid = fopen(datFile, 'w');

% Check if continuing from a previous session
if general.contPrevious == 'y' 
    startTrial = size(data.table,1) - setting.trialsRemaining;
    general.expStartTime = GetSecs;
else
    startTrial = 1;
end

for t = startTrial:size(data.table,1) % Start main loop
    % Jitter placement of stimulus in x and y
    addXpos       = randi([fixation.posJitterMin, fixation.posJitterMax]); % Random position for x jitter
    addYpos       = randi([fixation.posJitterMin, fixation.posJitterMax]); % Random position for y jitter

    params.fixPos = [scr.center(1)+addXpos scr.center(2)+addYpos];         % Fixation position in x and y pix centered
    
    % Interest area for fixation. In this case a total of 2 degrees
    params.interestArea  = [params.fixPos(1)-round(scr.pixelsPerDeg) params.fixPos(2)-round(scr.pixelsPerDeg)...
        params.fixPos(1)+round(scr.pixelsPerDeg) params.fixPos(2)+round(scr.pixelsPerDeg)];

    % Presentation before the trial. Present instructions if it's the first
    % trial
    if t == 1
        str = sprintf(['ADD INSTRUCTIONS HERE']);
        
        %Screen('DrawTexture', scr.window, ADDTEXTUREPOINTER_HERE, [], [0 0 scr.windowRect(3) scr.windowRect(4)]);
        DrawFormattedText(scr.window, str, 'center', 'center', 0);
        Screen('Flip', scr.window)

        KbWait([], 2); % Wait for button press

        %Screen('DrawTexture', scr.window, ADDTEXTUREPOINTER2_HERE, [], [0 0 scr.windowRect(3) scr.windowRect(4)]); % Second set of instructions
        %Screen('Flip', scr.window);

        %KbWait([], 2); % Wait for button press

        str = sprintf(['Please maintain fixation at the dot. \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n' ...
            'Press the space bar to begin.']);
        
        DrawFormattedText(scr.window, str, 'center', 'center', 0);
        Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, fixation.fixCkCol_initial, params.fixPos, 2); % fixation dot
        Screen('Flip', scr.window);

        KbWait([], 2); % Wait for button press

        general.start = datestr(now); % record experiment start time and date
        general.expStartTime = GetSecs;

        WaitSecs(0.5);
    end

    % Present breaks after every X time set by fixation.breakTime
    if rem(t,10) == 0
        str = sprintf(['Blink']);

        DrawFormattedText(scr.window, str, 'center', scr.windowRect(4) - 300, 0);
        Screen('Flip', scr.window)
        WaitSecs(fixation.breakTime);

        str = sprintf(['Please press space bar to continue']);
        
        DrawFormattedText(scr.window, str, 'center', scr.windowRect(4) - 300, 0);
        Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.gray, [scr.center(1)+addXpos scr.center(2)+addYpos], 2); % fixation dot
        Screen('Flip', scr.window)

        KbWait([], 2); % Wait for button press
    end

    % Present progress every quarter
    if (t == data.table(end,1)/4) || (t == data.table(end,1)/2) || (t == data.table(end,1) * 3/4)
        
        str = sprintf([strcat('Trial number ', num2str(t), ' out of '), num2str(data.table(end,1))]);
        DrawFormattedText(scr.window, str, 'center', scr.windowRect(4) - 300, 0);
        Screen('Flip', scr.window)
        WaitSecs(fixation.breakTime);
    end

    % Perform calibration as determined (every quarter)
    if mod(t, setting.performCalibration) == 0
        if setting.TEST == 0
            disp([num2str(Getsecs) ' Performing calibration now.']);
            calibResult = EyelinkDoTrackerSetup(el);
            if calibResult == el.TERMINATE_KEY
                return
            end
        end
    else
        calibResult = [];
    end
    
    %---------------------------------------------------------------------%
    %%%%%%%%%%%%% Prepare Eyelink for recording this trial %%%%%%%%%%%%%%%%
    %---------------------------------------------------------------------%
    if setting.TEST==0 % Prepare EyeLink for recording this trial
        
        % This supplies a title at the bottom of the eyetracker display
        if t <= size(data.table,1)
            Eyelink('command', 'record_status_message ''Trial %d of %d in block %d''', t, size(data.table,1), general.block);
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
    data.x                = NaN(1,1000000); % x coord
    data.y                = NaN(1,1000000); % y coord of Eye link
    data.t                = NaN(1,1000000); % eye link timestamp (when retrieved)
    data.t_eye            = NaN(1,1000000); % eye link timestamp
   
    % ... and a few control variables
    firstInsideFixLoc = 0;         % is set to 1 when the fixation is within range
    tframe            = 0;         % iterator for number of eyelink samples retrieved
    current_fix       = [NaN NaN]; % the current fixation [x, y]

    % draw fixation to buffer
    Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % fixation dot
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
                [data.x(tframe), data.y(tframe), data.t(tframe), data.t_eye(tframe), ~] = getCoord(el, setting, scr.window);
                currentFix = [data.x(tframe), data.y(tframe), data.t(tframe)];
                gotNewSample = 1;
            else
                gotNewSample = 0;
            end
        
        else % check mouse to simulate gaze samples
            
            if (tframe == 0) || (GetSecs - data.t(tframe) > 1/500) % simulating a sampling rate of 500 Hz
                tframe = tframe + 1;
                [data.x(tframe), data.y(tframe), data.t(tframe)] = getCoord(el, setting, scr.window);
                currentFix = [data.x(tframe), data.y(tframe), data.t(tframe)];
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
                Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.gray, [params.fixPos(1) params.fixPos(2)], 2); % fixation dot
                
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

    % clear keyboard buffer
    FlushEvents('KeyDown');

    % predefine time stamps
    tStart = [];
    tEndMo = [];
    tResp0 = [];
    tClear = [];
    tResp  = [];
    
    % Draw fixation spot and flip
    %Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % fixation dot
    tIni = Screen(scr.window, 'Flip');

    keyPressed = 0;
    mfTest = zeros(1,nF);
    
    tEnd = tIni + params.trialDuration;
    
    for f = 1:nF

        Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % fixation dot
        % Draw dots
        Screen('DrawDots', scr.window, [trial(t).dots(f).xpix+addXpos trial(t).dots(f).ypix+addYpos]', trial(t).dots(f).size', trial(t).dots(f).col', [], 2);
        mfTest(f) = Screen(scr.window, 'Flip');

        % Check keyboard for response  NEED TO ADD RESPONSES HERE       
        [keyIsDown, secs, keyCode] = KbCheck;

        if keyCode(keys.escape)
            ShowCursor;
            sca;
            return
        elseif keyCode(keys.downKey)
            response = 1; % No after-image
        elseif keyCode(keys.upKey)
            response = 2; % 4-pointed star
        elseif keyCode(keys.leftKey)
            response = 3; % 8-pointed star single-colored
        elseif keyCode(keys.rightKey)
            response = 4; % 8-pointed star multicolored
        else
            response = 0; % Mistake
        end
        
    end

    

    %KbWait([], 2);
%     for f = 1:nF
%         % Draw fixation spot
%         Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % fixation dot
%         % Draw dots
%         Screen(scr.window, 'DrawDots', [trial(t).dots(f).xpix trial(t).dots(f).ypix]', trial(t).dots(f).size', trial(t).dots(f).col');
%         % Draw stimuli on screen and count missed flips
%         mfTest(f) = Screen(scr.window, 'Flip');
% %         if f == 1
% %             flipNow = tIni + params.trialDuration - scr.frameDuration/2000; % WHY 2000?
% %         else
% %             flipNow = mfTest(f-1)-scr.frameDuration/2000;
% %         end
%     end

    
    %mfTest(f) = Screen(scr.window, 'Flip', flipNow);

    % determie critical times
    if f == 1
        tStart = mfTest(f);           % first frame
    elseif f == nF
        tEndMo = mfTest(f);           % end of movement
    end

    if setting.TEST == 0 
        Eyelink('message', 'TrialEnd') 
    end

    data.table(t, size(data.table,2)) = response; 
    
    if setting.TEST == 0
        Eyelink('message', 'TRIAL_END %d', t);
        Eyelin('stoprecording');
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
sca;

