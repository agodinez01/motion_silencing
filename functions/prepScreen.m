function prepScreen(computer)
computer = 'personal';

global scr fixation setting

% Set screen preference
Screen('Preference', 'SkipSyncTests', 0); % Make sure this is set to 0 when running actual experiment for accurate timing

%--------------------------------------------------------------------------
%                           Display setup
%--------------------------------------------------------------------------

if setting.TEST == 1 % When in dummy mode, set the screen to be half transparent to be able to see errors in the terminal
    PsychDebugWindowConfiguration(0, 0.80);
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

PsychDefaultSetup(2); % Important default settings for Psychtoolbox

scr.screens = Screen('Screens'); % Get the screen numbers.
screenNumber = max(scr.screens); % Draw on screen with max number

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
scr.white       = WhiteIndex(screenNumber);
scr.black       = BlackIndex(screenNumber);
scr.gray        = GrayIndex(screenNumber);

% % Open an on screen window using PsychImaging and color it white.
[scr.window, scr.windowRect] = PsychImaging('OpenWindow', screenNumber, scr.gray);
Screen('BlendFunction', scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Enable alpha blending for anti-aliasing

scr.config     = Screen('Resolution', screenNumber); % Resolution of screen
scr.xres       = scr.config.width;
scr.yres       = scr.config.height;
scr.frameRate  = scr.config.hz;

scr.frameDuration     = round(Screen('GetFlipInterval', scr.window) *1000);  % [s] Framre duration
scr.measuredFrameRate = 1000/ scr.frameDuration;                             % [fps] Frames per second

scr.center       = round([scr.windowRect(3) scr.windowRect(4)]/2);
scr.pixelsPerDeg = tan(1*pi/180) * scr.viewingDistance/(scr.screenWidth/scr.config.width);

% Set screen font
Screen('TextFont', scr.window, 'Ariel');
Screen('TextSize', scr.window, 36);

%--------------------------------------------------------------------------
%                           Fixation
%--------------------------------------------------------------------------

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