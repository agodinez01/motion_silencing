function prepScreen(computer)
computer = 'personal';

global scr fixation setting

% Set screen preference
Screen('Preference', 'SkipSyncTests', 0); % Make sure this is set to 0 when running actual experiment for accurate timing

%--------------------------------------------------------------------------
%                           Display setup
%--------------------------------------------------------------------------

if (lower(computer) == "work") || (lower(computer) == "personal") 
    scr.screenWidth = 53;         % in cm
    scr.screenHeight = 30;        % in cm
    scr.viewingDistance = 40;     % in cm
    scr.frameRate = 60;         % Hz
elseif lower(computer) == "dark"
    % VPixx/ DarkRoom
    scr.screenWidth = 150;        %cm
    scr.screenHeight = 84;        %cm
    scr.viewingDistance = 180;    %cm
    
end

% Here we call some default settings for setting up Psychtoolbox
%PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
scr.screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(scr.screens);

if setting.TEST == 1 % When in dummy mode, set the screen to be half transparent to be able to see errors in the terminal
    PsychDebugWindowConfiguration(0, 0.5);
end

%--------------------------------------------------------------------------
%                           DataPixx connection
%--------------------------------------------------------------------------

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

%--------------------------------------------------------------------------
%                    Screen coordinates and color
%--------------------------------------------------------------------------

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. With our setup, values defined between 0 and 1.
scr.white = WhiteIndex(screenNumber);
scr.black = BlackIndex(screenNumber);
scr.gray = GrayIndex(screenNumber);
scr.bgColor = scr.white;
scr.fgColor = scr.black;

% % Open an on screen window using PsychImaging and color it white.
[scr.window, scr.windowRect] = PsychImaging('OpenWindow', screenNumber, scr.white);

% Get screen info
scr.config = Screen('Resolution', screenNumber); % Resolution of screen
scr.xres = scr.config.width;
scr.yres = scr.config.height;
scr.frameRate = scr.config.hz;

scr.frameDuration = round(Screen('GetFlipInterval', scr.window) *1000);
scr.measuredFrameRate = 1000/ scr.frameDuration;  

%assert(scr.frameRate == round(scr.measuredScreenFrameRate))

% Get the center coordinates of the window
scr.center       = round([scr.windowRect(3) scr.windowRect(4)]/2);
scr.pixelsPerDeg = tan(1*pi/180) * scr.viewingDistance/(scr.screenWidth/scr.config.width);

%Everything in terms of pixels...
scr.pixelFixationXY            = round(FixationCenterOffsetXY * scr.pixelsPerDeg) + scr.center; %[x y]
scr.pixelFixationXYCentered    = round(FixationCenterOffsetXY * scr.pixelsPerDeg) + [0 0];

% Enable alpha blending for anti-aliasing
Screen('BlendFunction', scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Set screen font
Screen('TextFont', scr.window, 'Ariel');
Screen('TextSize', scr.window, 36);

%--------------------------------------------------------------------------
%                           Fixation
%--------------------------------------------------------------------------

% Here we set the size of the arms of our fixation cross
%fixCrossDimPix = 20;
fixation.fixCrossDimPix = 1;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
fixation.xCoords   = [-fixation.fixCrossDimPix fixation.fixCrossDimPix 0 0];
fixation.yCoords   = [0 0 -fixation.fixCrossDimPix fixation.fixCrossDimPix];
fixation.allCoords = [fixation.xCoords; fixation.yCoords];

% Set the line width for our fixation cross
fixation.dotWidthPix       = 7.5;
fixation.fixCkRad          = 2 * scr.pixelsPerDeg; % 2 degs of visual angle
fixation.fixCkCol          = scr.gray;
fixation.fixCkCol_initial  = scr.black;
fixation.fixDurReq         = 0.5; % jitter this
fixation.fixBrokenMax      = 10;
fixation.maxTimeWithoutFix = 5;

%Maximum priority level
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);