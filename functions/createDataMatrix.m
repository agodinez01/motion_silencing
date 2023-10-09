function dataMatrix = createDataMatrix(sampling_rate, num_trials)

global setting data scr keys general stim fixation const %#ok<*NUSED>

% Creates data matrix

num_trials = 2;

const.samplingRate = 60; % Hz
const.rameRate = 1/const.samplingRate;
const.backgroundColor = [1.0 1.0 1.0 1.0];
 
stim.presentationTime = 500; % ms

stim.gaborDimPix = 55; % gabor dimension in pixels
stim.gaborDimDeg = stim.gaborDimPix * scr.pielsPerDegree; % gabor dimension in degrees

stim.sigma = stim.gaborDimPix / 6; % sigma of Gaussian. gabor_dim_pix / 6
stim.sigmaDeg = stim.gaborDimDeg / 6; 

stim.orientation = 90;
stim.contrast = 0.5;
stim.aspectRatio = 1.0;

% Spatial frequency (cycles per degree)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
stim.nCycles = 3 ; % 3 * scr.pixelsPerDegree;
stim.frequency = stim.nCycles / stim.gaborDimPx;

% Build a procedural gabor texture
stim.gabortex = CreateProceduralGabor(scr.window, stim.gaborDimPix, stim.gaborDimPix,...
    [], const.backgroundColor, 1, 0.5);

% Position of the gabors
stim.dim = 8;
[x, y] = meshgrid(-stim.dim:stim.dim, -stim.dim:stim.dim);

% Calculate the distance in "Gabor numbers" of each gabor from the center
% of the array
stim.dist = sqrt(x.^2 + y.^2);

% Cut out inner annulus 
stim.innerDist = 3.5;
x(stim.dist <= stim.innerDist) = nan;
y(stim.dist <= stim.innerDist) = nan;

% Cut out an outer annulus
stim.outerDist = 10;
x(stim.dist >= stim.outerDist) = nan;
y(stim.dist >= stim.outerDist) = nan;

% Select only the finite values
stim.x = x(isfinite(x));
stim.y = y(isfinite(y));

% Center the annulus coordinates in the center of the screen
stim.xPos = stim.x .* stim.gaborDimPix + scr.center(1);
stim.yPos = stim.y .* stim.gaborDimPix + scr.center(2);

% Count the number of gabors
stim.nGabors = numel(stim.xPos);

% Make the destination rectangles for all Gabors in the array
stim.baseRect = [0 0  stim.gaborDimPix stim.gaborDimPix];
stim.allRects = nan(4, stim.nGabors);

for i = 1:stim.nGabors
    stim.allRects(:,i) = CenterRectOnPointd(stim.baseRect, stim.xPos(i), stim.yPos(i));
end

% Drift speed for 2D global motion
stim.degPerSec = 360 * 4;
stim.degPerFrame = stim.degPerSec * scr.measuredScreenFrameRate;

% Randomise the Gabor orientations and determine the drift speeds of each gabor.
% This is given by multiplying the global motion speed by the cosine
% difference between the global motion direction and the global motion.
% Here the global motion direction is 0. So it is just the cosine of the
% angle we use. We re-orientate the array when drawing
stim.gaborAngles = rand(1, stim.nGabors) .* 180 - 90;
stim.degPerFrameGabors = cosd(stim.gaborAngles) .* stim.degPerFrame;

% Randomise the phase of the Gabors and make a properties matrix. We could
% if we want have each Gabor with different properties in all dimensions.
% Not just orientation and drift rate as we are doing here.
% This is the power of using procedural textures
stim.phaseLine = rand(1, stim.nGabors) .* 360;
stim.propertiesMat = repmat([NaN, stim.freq, stim.sigma, stim.contrast, stim.aspectRatio, 0, 0, 0],...
    stim.nGabors, 1);
stim.propertiesMat(:, 1) = stim.phaseLine';


