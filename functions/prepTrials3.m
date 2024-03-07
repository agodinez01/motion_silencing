function [trial] = prepTrials3
format long

global scr setting params

params.dotColor         = 1;     % -1 = random hue (full saturation and brightness); avlues between 0 and 1: hue value for all dots
params.dotNumber        = [100]; % dot number

if (setting.block == 4) || (setting.block == 5) % Testing limits
    params.dotSpeed         = [0.9375, 1.875, 3.75, 7.5, 15, 30, 60, 120, 240, 480]; % [deg/s] dot speed 
else
    params.dotSpeed         = [3.75, 7.5, 15, 30, 60, 120];                          % [deg/s] dot speed
end
 
params.dotSpeedPerFrame = params.dotSpeed*(1/scr.measuredFrameRate) * pi/180;  % [pi/frame] Dot speed

if setting.block == 2
    params.dotSize             = [scr.pixelsPerDeg*0.55, scr.pixelsPerDeg*0.25];
else
    params.dotSize             = scr.pixelsPerDeg * 0.85;           % [pix] dot size of 1 dva
end 

% Stimulus positioning
params.minRad    = 5; % [dva] minimum distance of dots from center
params.maxRad    = 8; % [dva] maximum distance of dots from center
params.minRadPx  = params.minRad * scr.pixelsPerDeg;
params.maxRadPx  = params.maxRad * scr.pixelsPerDeg;
params.minRadLoc = [scr.center(1)-params.minRadPx, scr.center(2)-params.minRadPx, scr.center(1)+params.minRadPx, scr.center(2)+params.minRadPx];

% Stimulus timing
params.stationaryDuration = 3;   % [s] Stationary phase
params.interTrialInterval = 0.5; % [s]
params.framesPerSecond    = scr.measuredFrameRate;

% Stimulus color range
params.colMin = 0.0; % Color minimum
params.colMax = 0.7; % Color maximum

% Stimulus direction
params.angleMin = 0;
params.angleMax = 360;

% Sine wave parameters
params.amplitude = 0.15; % Change in luminance

params.nBlocks            = 1;

if setting.sessionNum == 0  % Practice round
    params.nTrialsPerCellInBlock = 1; 
else 
    params.nTrialsPerCellInBlock = 3;
end

params.randBlocks = 0;

for b = 1:params.nBlocks
    t = 0;
    for ntpc = 1:params.nTrialsPerCellInBlock
        for dnum = 1:size(params.dotNumber, 2)
            for dsize = 1:size(params.dotSize, 2)
                for dspd = 1:size(params.dotSpeed, 2)
                    
                    t = t+1; % Trial number 
                    trial(t).nStationary            = round(params.stationaryDuration*1000/scr.frameDuration); % Get number of frames given the duration of the stimulus presentation and duration of each frame
                    trial(t).nFrames                = round(params.stationaryDuration*2*1000/scr.frameDuration); 
                    trial(t).framesPerCycle         = round(1*scr.measuredFrameRate);
                    trial(t).originalFramesPerCycle = trial(t).framesPerCycle;
                    trial(t).angle                  = 2*pi*rand(params.dotNumber(dnum),1);
                    trial(t).radius                 = (params.maxRad+params.minRad)/2*ones(params.dotNumber(dnum),1);

                    % Determine the size of each dot
                    trial(t).dots(1).size    = params.dotSize(dsize)*ones(params.dotNumber(dnum),1);

                    % Calculate initial dot positions
                    if t == 1
                        trial(t).dots(1).r = params.minRad + (params.maxRad - params.minRad)*rand(params.dotNumber(dnum),1);
                        trial(t).dots(1).a = 2*pi*rand(params.dotNumber(dnum),1);
                        [x, y] = pol2cart(trial(t).dots(1).a, trial(t).dots(1).r);
                        trial(t).dots(1).x = x;
                        trial(t).dots(1).y = y;
        
                        % Translates dva to pix
                        trial(t).dots(1).xpix = x*scr.pixelsPerDeg + scr.center(1);
                        trial(t).dots(1).ypix = y*scr.pixelsPerDeg + scr.center(2);

                        % Check if any of the circles overlap
                        xy(:,1) = trial(t).dots(1).xpix;
                        xy(:,2) = trial(t).dots(1).ypix;
                        
                        circleRadius = params.dotSize(dsize)/2 * ones(params.dotNumber(dnum),1); % [px equal to 1 deg of visual angle]
                        circleRadius2 = circleRadius(:) + circleRadius(:)';
                        dxy = sqrt( (trial(t).dots(1).xpix - trial(t).dots(1).xpix').^2 +  (trial(t).dots(1).ypix - trial(t).dots(1).ypix').^2 );
        
                        lo = dxy <= circleRadius2;
                        lo(1:size(xy,1)+1:end) = false;
        
                        intersectingCircles = find(any(lo,2));
        
                        keepLooping = 0;
        
                        while keepLooping == 0 % Loop through until no more dots overlap
                            for i = 1:length(intersectingCircles)
                                trial(t).dots(1).r(intersectingCircles(1)) = params.minRad + (params.maxRad - params.minRad)*rand(1,1);
                                trial(t).dots(1).a(intersectingCircles(1)) = 2*pi*rand(1,1);
                                [x, y] = pol2cart(trial(t).dots(1).a(intersectingCircles(1)), trial(t).dots(1).r(intersectingCircles(1)));
                                trial(t).dots(1).x(intersectingCircles(1)) = x;
                                trial(t).dots(1).y(intersectingCircles(1)) = y;
                
                                % Translates dva to pix
                                trial(t).dots(1).xpix(intersectingCircles(1)) = x*scr.pixelsPerDeg + scr.center(1);
                                trial(t).dots(1).ypix(intersectingCircles(1)) = y*scr.pixelsPerDeg + scr.center(2);
            
                                xy(intersectingCircles(1),1) = trial(t).dots(1).xpix(intersectingCircles(1));
                                xy(intersectingCircles(1),2) = trial(t).dots(1).ypix(intersectingCircles(1));
            
                                dxy = sqrt( (trial(t).dots(1).xpix - trial(t).dots(1).xpix').^2 +  (trial(t).dots(1).ypix - trial(t).dots(1).ypix').^2 );
            
                                lo = dxy <= circleRadius2;
                                lo(1:size(xy,1)+1:end) = false;
                
                                intersectingCircles = find(any(lo,2));
                                length(intersectingCircles)
        
                                if ~isempty(intersectingCircles)
                                    keepLooping = 0;
                                elseif isempty(intersectingCircles)
                                    keepLooping = 1;
                                    break
                                end
                            end
                        end
                    elseif t > 1
                        trial(t).dots(1).xpix = trial(1).dots(1).xpix;
                        trial(t).dots(1).ypix = trial(1).dots(1).ypix;
                        trial(t).dots(1).r    = trial(1).dots(1).r;
                        trial(t).dots(1).a    = trial(1).dots(1).a;
                    end
    
                    % Determine the dot brightness for each dot and frame
                    if params.dotColor == -1 
                        % Set hue randomly, keep saturation and brightness
                        % at 1, then translate to rgb and add one column
                        % for alpha.
                        trial(t).dots(1).col = [hsv2rgb([rand(params.dotNumber(dnum),1) ones(params.dotNumber(dnum),2)]) ones(params.dotNumber(dnum),1)];
                    
                    elseif params.dotColor == 1 % Gray scale
                        
                        trial(t).dots(1).col      = (params.colMax-params.colMin).*rand(params.dotNumber(dnum),1) + params.colMin; % Get a gray scale value within the range we've specified [0.3, 0.7]
                        trial(t).dots(1).col      = repmat(trial(t).dots(1).col(:,1),1,3); % Make it three columns for RGB
               
                    else
                        trial(t).dots(1).col = [hsv2rgb([params.dotCol*ones(params.dotNumber(dnum),2)]) ones(params.dotNum(dnum), 1)];
                    end
    
                    % Make sine wave for flicker 
                    trial(t).samples       = 1:trial(t).nFrames;
                    trial(t).phaseShift    = randi([-100, 100], params.dotNumber(dnum), 1); % Vector for phase shift
                    trial(t).verticalShift = trial(t).dots(1).col(:,1) + params.amplitude;
                    trial(t).fullWaveForm  = params.amplitude * sind(360/scr.measuredFrameRate*trial(t).samples + trial(t).phaseShift) + trial(t).verticalShift;
    
                    trial(t).dots(1).col = repmat(trial(t).fullWaveForm(:,1),1,3);
    
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
    
                    % Calculate moving frames
                    for f = trial(t).nStationary: trial(t).nFrames 
                        % Determine the new gray value
                        trial(t).dots(f).col = trial(t).fullWaveForm(:,f);
                        trial(t).dots(f).col = repmat(trial(t).dots(f).col(:,1),1,3);
    
                        % Determine dot size for each dot and frame
                        % (constant at the moment)
                        trial(t).dots(f).size = trial(t).dots(f-1).size;

                        if (setting.block == 1) || (setting.block == 2) || (setting.block == 4) % Rotating
                        
                            if rem(t,2) == 1 % Make clockwise
                                trial(t).dots(f).a = trial(t).dots(f-1).a + params.dotSpeedPerFrame(dspd);
                            elseif rem(t,2) == 0 % Make counterclockwise  
                                trial(t).dots(f).a = trial(t).dots(f-1).a + (-1*params.dotSpeedPerFrame(dspd));
                            end
        
                            trial(t).dots(f).r = trial(t).dots(f-1).r;
                            [x,y] = pol2cart(trial(t).dots(f).a, trial(t).dots(f).r);
                            trial(t).dots(f).x = x;
                            trial(t).dots(f).y = y;
        
                            % Translate dva to pix
                            trial(t).dots(f).xpix = x*scr.pixelsPerDeg + scr.center(1);
                            trial(t).dots(f).ypix = y*scr.pixelsPerDeg + scr.center(2);
                        
                        elseif (setting.block == 3) || (setting.block == 5) % Random
                            if f == trial(t).nStationary
                                trial(t).dots(f).a = trial(t).angle;
                                trial(t).dots(f).r = trial(t).radius;
                            else
                                trial(t).dots(f).a = trial(t).dots(f-1).a;
                                trial(t).dots(f).r = trial(t).dots(f-1).r;
                            end

                            s = trial(t).dots(f).r*params.dotSpeedPerFrame(dspd);
                            
                            trial(t).dots(f).x = trial(t).dots(f-1).x + (s .*cos(trial(t).dots(f).a));
                            trial(t).dots(f).y = trial(t).dots(f-1).y + (s .*sin(trial(t).dots(f).a));

                            trial(t).dots(f).xpix = trial(t).dots(f).x * scr.pixelsPerDeg + scr.center(1);
                            trial(t).dots(f).ypix = trial(t).dots(f).y * scr.pixelsPerDeg + scr.center(2);

                            trial(t).dots(f).distance = sqrt((trial(t).dots(f).xpix - trial(t).dots(f-1).xpix).^2 + (trial(t).dots(f).ypix - trial(t).dots(f-1).ypix).^2);

                            for d = 1:params.dotNumber(dnum)
                                % Check if x, and y are within the circle
                                if ((trial(t).dots(f).xpix(d,1) - scr.center(1))^2 + (trial(t).dots(f).ypix(d,1) - scr.center(2))^2 < params.maxRadPx^2) && ((trial(t).dots(f).xpix(d,1) - scr.center(1))^2 + (trial(t).dots(f).ypix(d,1) - scr.center(2))^2 > params.minRadPx^2)
                                    continue
                                else
                                    trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1);
                                    trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1);
                                    trial(t).dots(f).a(d,1)    = trial(t).dots(f).a(d,1) + pi; % Make the angle negative to bounce back from a wall
                                end
                            end
                        end
                    end
    
                    % Save the data file
                    trial(t).dotNumber      = params.dotNumber(dnum);
                    trial(t).dotSpeed       = params.dotSpeed(dspd);
                    trial(t).dotColor       = params.dotColor;
                    trial(t).dotSize        = params.dotSize(dsize);
                end
            end
        end
    end
    r = randperm(t);
    params.b(b).trial = trial(r);
end
trial = trial(:, randperm(size(trial,2))); % Randomize trial order

% Make new variables, to be changed with frequency 
for t = 1:size(trial,2)
    for f = 1:trial(t).originalFramesPerCycle
        trial(t).newDots(f).size = trial(t).dots(f).size;
        trial(t).newDots(f).xpix = trial(t).dots(f).xpix;
        trial(t).newDots(f).ypix = trial(t).dots(f).ypix;
        trial(t).newDots(f).col  = trial(t).dots(f).col;
    end
end
