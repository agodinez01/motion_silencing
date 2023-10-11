clear all;
close all;

rng('shuffle')

% Here we call some default settings for setting up Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

general.block = 0;
general.sessionNum = 1;

%% Screen coordinates and color
scr.screenWidth      = 53;     % [cm]
scr.screenHeight     = 30;     % [cm]
scr.viewingDistance  = 40;     % [cm]
scr.frameRate        = 60;     % [Hz]

scr.screens = Screen('Screens');
screenNumber = max(scr.screens);

PsychDebugWindowConfiguration(0, 0.95);

scr.white       = WhiteIndex(screenNumber);
scr.black       = BlackIndex(screenNumber);
scr.gray        = GrayIndex(screenNumber);

[scr.window, scr.windowRect] = PsychImaging('OpenWindow', screenNumber, scr.gray);
Screen('BlendFunction', scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

scr.config     = Screen('Resolution', screenNumber); % Resolution of screen
scr.xres       = scr.config.width;
scr.yres       = scr.config.height;
scr.frameRate  = scr.config.hz;

scr.frameDuration     = round(Screen('GetFlipInterval', scr.window) *1000);  % [s] Framre duration
scr.measuredFrameRate = 1000/ scr.frameDuration;                             % [fps] Frames per second

scr.center       = round([scr.windowRect(3) scr.windowRect(4)]/2);
scr.pixelsPerDeg = tan(1*pi/180) * scr.viewingDistance/(scr.screenWidth/scr.config.width);

%% Fixation
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
fixation.fixCkCol          = scr.white;             % When fixating. Dot is gray
fixation.fixCkCol_initial  = scr.black;            % When NOT fixating, the dot it black
fixation.fixDurReq         = 0.5;                  % jitter this
fixation.fixBrokenMax      = 10;                   % Maximum times fixation can be broken
fixation.maxTimeWithoutFix = 5;                    % [s] Max time without fixation
fixation.breakTime         = 2;                    % [s] Break 'blink' time and trial number showing

%Maximum priority level
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);

%% Data matrix
params.dotColor         = 1;                            % -1 = random hue (full saturation and brightness); avlues between 0 and 1: hue value for all dots
params.dotNumber        = [100];                        % dot number
params.dotSpeed         = [3.75, 7.5, 15, 30, 60, 120]; % [deg/s] dot speed (neg is ccw)
params.dotSize          = 15;                           % [pix] dot size of 1 dva
params.dotSpeedPerFrame = params.dotSpeed*(scr.frameDuration/1000) * pi/180; % [px/frame] Dot speed 
params.dotColorChange   = 0.15;

% Stimulus positioning
params.minRad = 5; % [dva] minimum distance of dots from center
params.maxRad = 8; % [dva] maximum distance of dots from center

% Stimulus timing
params.stationaryDuration = 3;   % [s] Stationary phase
params.interTrialInterval = 0.5; % [s]
params.framesPerSecond    = 1000/scr.frameDuration;

% Stimulus color range
params.colMin = 0.0; % Color minimum
params.colMax = 0.7; % Color maximum

% Sine wave parameters
params.frequency = 1; % [Hz]
params.amplitude = 0.15; % Change in luminance
params.samples   = (0:1/(params.frequency*params.framesPerSecond):1);
params.phi       = 0; % Phase

params.nBlocks            = 1;

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
                trial(t).nStationary  = round(params.stationaryDuration*1000/scr.frameDuration); % Get number of frames given the duration of the stimulus presentation and duration of each frame
                trial(t).nFrames      = round(params.stationaryDuration*2*1000/scr.frameDuration); 

                % Calculate initial dot positions
                trial(t).dots(1).r = params.minRad + (params.maxRad - params.minRad)*rand(params.dotNumber(dnum),1);
                trial(t).dots(1).a = 2*pi*rand(params.dotNumber(dnum),1);
                [x, y] = pol2cart(trial(t).dots(1).a, trial(t).dots(1).r);
                trial(t).dots(1).x = x;
                trial(t).dots(1).y = y;

                % Translates dva to pix
                trial(t).dots(1).xpix = x*scr.pixelsPerDeg + scr.center(1);
                trial(t).dots(1).ypix = y*scr.pixelsPerDeg + scr.center(2);

                % Determine the dot brightness for each dot and frame
                if params.dotColor == -1 
                    % Set hue randomly, keep saturation and brightness
                    % at 1, then translate to rgb and add one column
                    % for alpha.
                    trial(t).dots(1).col = [hsv2rgb([rand(params.dotNumber(dnum),1) ones(params.dotNumber(dnum),2)]) ones(params.dotNumber(dnum),1)];
                
                elseif params.dotColor == 1 % Gray scale
                    trial(t).dots(1).colD(1:params.dotNumber(dnum)/2,:)                      = -1; % Make half of the array -1. This half gets lighter
                    trial(t).dots(1).colD(params.dotNumber(dnum)/2:params.dotNumber(dnum),:) = 1;  % Make the other half 1. This half gets darker
                    trial(t).dots(1).colD                                                    = Shuffle(trial(t).dots(1).colD); % shuffle them
                    
                    trial(t).dots(1).col      = (params.colMax-params.colMin).*rand(params.dotNumber(dnum),1) + params.colMin; % Get a gray scale value within the range we've specified [0.3, 0.7]
                    trial(t).dots(1).col      = repmat(trial(t).dots(1).col(:,1),1,3); % Make it three columns for RGB
            
                else
                    trial(t).dots(1).col = [hsv2rgb([params.dotCol*ones(params.dotNumber(dnum),2)]) ones(params.dotNum(dnum), 1)];
                end

                % Make sine wave for flicker 
                trial(t).samples       = 1:trial(t).nFrames;
                trial(t).phaseShift    = randi([-100, 100], params.dotNumber(dnum), 1); % Vector for phase shift
                trial(t).verticalShift = trial(t).dots(1).col(:,1) + params.amplitude;
                trial(t).fullWaveForm  = params.amplitude * sind((2*pi)*trial(t).samples+trial(t).phaseShift) + trial(t).verticalShift;  
                
                % trial(t).fullWaveForm  = params.amplitude * sind((2*pi)*trial(t).samples+params.phi);

                % Determine the size of each dot. Currently not
                % changing. If you make this variable dynamic, you
                % might want to move this to the top to be able to
                % calculate non-overlapping points correctly.
                trial(t).dots(1).size = params.dotSize*ones(params.dotNumber(dnum),1);

                % Calculate stationary frames
                for f = 2:trial(t).nStationary
                 
                    trial(t).dots(f).a = trial(t).dots(f-1).a;
                    trial(t).dots(f).r = trial(t).dots(f-1).r;
                    [x,y] = pol2cart(trial(t).dots(f).a, trial(t).dots(f).r);
                    trial(t).dots(f).x = x;
                    trial(t).dots(f).y = y;

                    trial(t).dots(f).xpix = x* scr.pixelsPerDeg + scr.center(1);
                    trial(t).dots(f).ypix = y* scr.pixelsPerDeg + scr.center(2);

                    % Determine the new gray value
                    trial(t).dots(f).col = trial(t).fullWaveForm(:,f);
                    trial(t).dots(f).col = repmat(trial(t).dots(f).col(:,1),1,3);

                    %trial(t).dots(f).col = trial(t).dots(1).col + (trial(t).fullWaveForm(f)*trial(t).dots(1).colD);

                    % Determine the size
                    trial(t).dots(f).size = trial(t).dots(f-1).size;

                end
                
                % Calculate rotating frames
                for f = trial(t).nStationary: trial(t).nFrames
                    if ntpc == 1 % Make clockwise
                        trial(t).dots(f).a = trial(t).dots(f-1).a+params.dotSpeedPerFrame(dspd);
                    elseif ntpc == 2 % Make counterclockwis
                        trial(t).dots(f).a = trial(t).dots(f-1).a+(-1*params.dotSpeedPerFrame(dspd));
                    end

                    trial(t).dots(f).r = trial(t).dots(f-1).r;
                    [x,y] = pol2cart(trial(t).dots(f).a, trial(t).dots(f).r);
                    trial(t).dots(f).x = x;
                    trial(t).dots(f).y = y;

                    % Translate dva to pix
                    trial(t).dots(f).xpix = x*scr.pixelsPerDeg + scr.center(1);
                    trial(t).dots(f).ypix = y*scr.pixelsPerDeg + scr.center(2);

                    % Determine the new gray value
                    trial(t).dots(f).col = trial(t).fullWaveForm(:,f);
                    trial(t).dots(f).col = repmat(trial(t).dots(f).col(:,1),1,3);
                    %trial(t).dots(f).col = trial(t).dots(1).col + (trial(t).fullWaveForm(f)*trial(t).dots(1).colD);

                    % Determine dot size for each dot and frame
                    % (constant at the moment)
                    trial(t).dots(f).size = trial(t).dots(f-1).size;
                end
                
                % Save the data file
                trial(t).dotNumber      = params.dotNumber(dnum);
                trial(t).dotSpeed       = params.dotSpeed(dspd);
                trial(t).dotColor       = params.dotColor;
                %trial(t).dotFlickerFreq = params.flicker(ffq);
            end
        end
    end
    r = randperm(t);
    params.b(b).trial = trial(r);
end

trial = trial(:,randperm(size(trial,2))); % Randomize trial order

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

startTrial = 1;

for t = startTrial:size(trial,2) % Start main loop
    % Jitter placement of stimulus in x and y
    addXpos       = randi([fixation.posJitterMin, fixation.posJitterMax]); % Random position for x jitter
    addYpos       = randi([fixation.posJitterMin, fixation.posJitterMax]); % Random position for y jitter
    
    params.fixPos = [scr.center(1)+addXpos scr.center(2)+addYpos];         % Fixation position in x and y pix centered

    nF = trial(t).nFrames; % number of frames
    mfTest = zeros(1,nF);

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
        % First, present the stationary stimulus, followed by the rotating
        % stimulus
        if replayRotation == 1
            for f = trial(t).nStationary:nF % Rotation part
                DrawFormattedText(scr.window, num2str(t), scr.xres - 200, scr.yres - 100, 0);
                Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % Fixation
                Screen('DrawDots', scr.window, [trial(t).dots(f).xpix+addXpos trial(t).dots(f).ypix+addYpos]', trial(t).dots(f).size', trial(t).dots(f).col', [], 2);
                Screen('DrawingFinished', scr.window);
                
                mfTest(f) = Screen('Flip', scr.window);
            end
            replayRotation = 0;
        elseif replayRotation == 0
            for f = 1:trial(t).nStationary % Stationary part and response
                DrawFormattedText(scr.window, num2str(t), scr.xres - 200, scr.yres - 100, 0);
                Screen('DrawDots', scr.window, fixation.allCoords, fixation.dotWidthPix, scr.black, [params.fixPos(1) params.fixPos(2)], 2); % Fixation
                Screen('DrawDots', scr.window, [trial(t).dots(f).xpix+addXpos trial(t).dots(f).ypix+addYpos]', trial(t).dots(f).size', trial(t).dots(f).col', [], 2);
                Screen('DrawingFinished', scr.window);
                
                mfTest(f) = Screen('Flip', scr.window);

                [keyIsDown, secs, keyCode] = KbCheck;
                KbReleaseWait;

                if keyCode(keys.escape)
                    ShowCursor;
                    sca;
                    return
                elseif keyCode(keys.upKey)
                    % Make new sine wave for flicker
                    frequencyChange = frequencyChange + 0.05; % Increases frequency
                    fprintf('Frequency change = %s ',num2str(frequencyChange));
        
                    % Make sine wave for flicker
                    trial(t).fullWaveFormNew = params.amplitude * sind(frequencyChange*(2*pi)*trial(t).samples+trial(t).phaseShift) + trial(t).verticalShift;
                    for i = 1:trial(t).nStationary
                        trial(t).dots(i).col(:,1:3) = repmat(trial(t).fullWaveFormNew(:,i),1,3);
                    end
        
                    trialDone = 0;
                    replayRotation = 0;
                    
                elseif keyCode(keys.downKey)
                    % Make new sine wave for flicker
                    frequencyChange = frequencyChange - 0.05; % Decreases frequency in Hz
                    
                    if frequencyChange == -0.05 % Make sure it cannot go lower than 0
                        frequencyChange = 0;
                    end
                    fprintf('Frequency change = %s ',num2str(frequencyChange));
        
                    % Make sine wave for flicker
                    trial(t).fullWaveFormNew = params.amplitude * sind(frequencyChange*(2*pi)*trial(t).samples + trial(t).phaseShift) + trial(t).verticalShift;
                    for i = 1:trial(t).nStationary
                        trial(t).dots(i).col(:,1:3) = repmat(trial(t).fullWaveFormNew(:,i),1,3);
                    end
        
                    trialDone = 0;
                    replayRotation = 0;
        
                elseif keyCode(keys.space)
                    replayRotation = 1; % Show rotation
                    trialDone = 0; % Do not finish trial
        
                elseif keyCode(keys.enter)
                    trialDone = 1;
                    replayRotation = 2;
                    trial(t).flickerFrequency = frequencyChange;
                end
            end
        elseif replayRotation == 2
            trialDone = 1;
        end
    end
end
Screen('Flip', scr.window); % Last flip

sca;
clear mex;