function [trial] = prepTrials

global scr general params

params.dotColor         = 1;                            % -1 = random hue (full saturation and brightness); avlues between 0 and 1: hue value for all dots
params.dotNumber        = [100];                        % dot number
params.dotSpeed         = [3.75, 7.5, 15, 30, 60, 120]; % [deg/s] dot speed (neg is ccw)
params.dotSize          = 10;                           % [pix] dot size of 1 dva
params.dotSpeedPerFrame = params.dotSpeed*(scr.frameDuration/1000) * pi/180; % [px/frame] Dot speed 

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
    params.nTrialsPerCellInBlock = 3;
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

                    % Determine the size
                    trial(t).dots(f).size = trial(t).dots(f-1).size;

                end

                % Calculate rotating frames
                for f = trial(t).nStationary: trial(t).nFrames
                    if rem(t,2) == 1 % Make clockwise
                        trial(t).dots(f).a = trial(t).dots(f-1).a+params.dotSpeedPerFrame(dspd);
                    elseif rem(t,2) == 0 % Make counterclockwis
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

                    % Determine dot size for each dot and frame
                    % (constant at the moment)
                    trial(t).dots(f).size = trial(t).dots(f-1).size;
                end

                % Save the data file
                trial(t).dotNumber      = params.dotNumber(dnum);
                trial(t).dotSpeed       = params.dotSpeed(dspd);
                trial(t).dotColor       = params.dotColor;
            end
        end
    end
    r = randperm(t);
    params.b(b).trial = trial(r);
end
trial = trial(:, randperm(size(trial,2))); % Randomize trial order