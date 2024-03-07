function [trial] = prepTrials2
format long

global scr setting params

params.dotColor         = 1;     % -1 = random hue (full saturation and brightness); avlues between 0 and 1: hue value for all dots
params.dotNumber        = [100]; % dot number
params.dotSpeed         = [3.75, 7.5, 15, 30, 60, 120];                      % [deg/s] dot speed 
params.dotSpeedPerFrame = params.dotSpeed*(scr.frameDuration/1000) * pi/180; % [px/frame] Dot speed
params.dotPxPerFrame    = params.dotSpeed*(scr.frameDuration/1000) * scr.pixelsPerDeg; 
params.direction        = [0,1,2,3]; % 0=horizontal, 1=vertial, 2=diagonal-same-dir, 3=diagonal-diff-dir
params.directionPosNeg  = [0,1]; % 0=positive direction; 1=negative direction
% params.colors           = ['r','b', 'g', 'm','y', 'c', 'k'];
% params.colorCode        = [1, 2, 3, 4, 5, 6, 7];

if (setting.block == 1) || (setting.block == 3) % Experiment 1
    params.dotSize             = scr.pixelsPerDeg * 0.5;           % [pix] dot size of 1 dva
elseif setting.block == 2
    params.dotSize             = [scr.pixelsPerDeg*0.55, scr.pixelsPerDeg*0.25];
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

% Sine wave parameters
params.frequency = 1;    % [Hz]
params.amplitude = 0.15; % Change in luminance
params.samples   = (0:1/(params.frequency*params.framesPerSecond):1);
params.phi       = 0;    % Phase

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
%                     figure(1);
%                     viscircles(scr.center,params.maxRadPx);
%                     hold on;
                    
                    t = t+1; % Trial number 
                    trial(t).nStationary            = round(params.stationaryDuration*1000/scr.frameDuration); % Get number of frames given the duration of the stimulus presentation and duration of each frame
                    trial(t).nFrames                = round(params.stationaryDuration*2*1000/scr.frameDuration); 
                    trial(t).framesPerCycle         = round(1*scr.measuredFrameRate);
                    trial(t).originalFramesPerCycle = trial(t).framesPerCycle;
                    trial(t).dotDirection           = repmat(params.direction, 1, round(params.dotNumber/length(params.direction)));
                    trial(t).dotDirMore             = repmat(params.directionPosNeg, 1, params.dotNumber/length(params.directionPosNeg));
%                     trial(t).dotColors              = repmat(params.colorCode, 1, round(trial(t).nFrames/length(params.colorCode)));
    
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

                        if (setting.block == 1) || (setting.block == 2) % Rotating
                        
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
                        
                        elseif setting.block == 3 % Random
                        
                            for d=1:length(trial(t).dotDirection) % Check the direction of the dot
                                
                                if trial(t).dotDirection(d) == 0       % Horizontal
                                    trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1); % Keep y constant
    
                                    if trial(t).dotDirMore(d) == 0     % positive
                                        trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1) + params.dotPxPerFrame(dspd);
                                    elseif trial(t).dotDirMore(d) == 1 % Negative
                                        trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1) - params.dotPxPerFrame(dspd);
                                    end
%                                     plot(trial(t).dots(f).xpix(d,1), trial(t).dots(f).ypix(d,1), strcat(params.colors(trial(t).dotColors(f)), '.'))
                                        
                                    % Check if x, and y are within the circle
                                    if (trial(t).dots(f).xpix(d,1) - scr.center(1))^2 + (trial(t).dots(f).ypix(d,1) - scr.center(2))^2 < params.maxRadPx^2 % If wihin the circle, keep it
                                        continue
                                    else                                                                                                                   % If not, go in the opposite direction
                                        trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1);
                                        if trial(t).dotDirMore(d) == 0
                                            trial(t).dotDirMore(d) = 1; % Change the direction
                                        elseif trial(t).dotDirMore(d) == 1
                                            trial(t).dotDirMore(d) = 0;
                                        end
                                    end

                                elseif trial(t).dotDirection(d) == 1   % Vertical
                                    trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1); % Keep x constant

                                    if trial(t).dotDirMore(d) == 0     % positive
                                        trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1) + params.dotPxPerFrame(dspd);
                                    elseif trial(t).dotDirMore(d) == 1 % Negative
                                        trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1) - params.dotPxPerFrame(dspd);
                                    end
%                                     plot(trial(t).dots(f).xpix(d,1), trial(t).dots(f).ypix(d,1), strcat(params.colors(trial(t).dotColors(f)), '.'))

                                    % Check if x, and y are within the circle
                                    if (trial(t).dots(f).xpix(d,1) - scr.center(1))^2 + (trial(t).dots(f).ypix(d,1) - scr.center(2))^2 < params.maxRadPx^2 % If wihin the circle, keep it
                                        continue
                                    else                                                                                                                   % If not, go in the opposite direction 
                                        trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1);
                                        if trial(t).dotDirMore(d) == 0
                                            trial(t).dotDirMore(d) = 1; % Change the direction
                                        elseif trial(t).dotDirMore(d) == 1
                                            trial(t).dotDirMore(d) = 0;
                                        end
                                    end
    
                                elseif trial(t).dotDirection(d) == 2    % Diagonal same signs

                                    if trial(t).dotDirMore(d) == 0     % positive
                                        trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1) + params.dotPxPerFrame(dspd);
                                        trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1) + params.dotPxPerFrame(dspd);
                                    elseif trial(t).dotDirMore(d) == 1 % Negative
                                        trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1) - params.dotPxPerFrame(dspd);
                                        trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1) - params.dotPxPerFrame(dspd);
                                    end

                                    % Check if x, and y are within the circle
                                    if (trial(t).dots(f).xpix(d,1) - scr.center(1))^2 + (trial(t).dots(f).ypix(d,1) - scr.center(2))^2 < params.maxRadPx^2 % If wihin the circle, keep it
                                        continue
                                    else                                                                                                                   % If not, go in the opposite direction
                                        trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1);
                                        trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1);

                                        if trial(t).dotDirMore(d) == 0
                                            trial(t).dotDirMore(d) = 1; % Change the direction
                                        elseif trial(t).dotDirMore(d) == 1
                                            trial(t).dotDirMore(d) = 0;
                                        end
                                    end
    
                                elseif trial(t).dotDirection(d) == 3   % Diagonal opposite signs

                                    if trial(t).dotDirMore(d) == 0     % positive x, negative y
                                        trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1) + params.dotPxPerFrame(dspd);
                                        trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1) - params.dotPxPerFrame(dspd);
                                    elseif trial(t).dotDirMore(d) == 1 % Negative x, positive y
                                        trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1) - params.dotPxPerFrame(dspd);
                                        trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1) + params.dotPxPerFrame(dspd);
                                    end

                                    % Check if x, and y are within the circle
                                    if (trial(t).dots(f).xpix(d,1) - scr.center(1))^2 + (trial(t).dots(f).ypix(d,1) - scr.center(2))^2 < params.maxRadPx^2 % If wihin the circle, keep it
                                        continue
                                    else                                                                                                                   % If not, go in the opposite direction
                                        trial(t).dots(f).xpix(d,1) = trial(t).dots(f-1).xpix(d,1);
                                        trial(t).dots(f).ypix(d,1) = trial(t).dots(f-1).ypix(d,1);

                                        if trial(t).dotDirMore(d) == 0
                                            trial(t).dotDirMore(d) = 1; % Change the direction
                                        elseif trial(t).dotDirMore(d) == 1
                                            trial(t).dotDirMore(d) = 0;
                                        end
                                    end
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