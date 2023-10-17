function setKeys

global keys

%--------------------------------------------------------------------------
%                           Set Keyboard
%--------------------------------------------------------------------------

KbName('UnifyKeyNames');
% keys.leftKey    = KbName('LeftArrow');
% keys.rightKey   = KbName('RightArrow');
keys.downKey    = KbName('DownArrow');
keys.upKey      = KbName('UpArrow');
keys.quitKey    = KbName('q');
keys.space      = KbName('space');
keys.escape     = KbName('ESCAPE');
keys.enter      = KbName('return');

keys.keysOfInterest = zeros(1,256);
% keys.keysOfInterest(KbName('LeftArrow'))   = 1;
% keys.keysOfInterest(KbName('RightArrow'))  = 1;
keys.keysOfInterest(KbName('DownArrow')) = 1;
keys.keysOfInterest(KbName('UpArrow')) = 1;
keys.keysOfInterest(KbName('q'))           = 1;
keys.keysOfInterest(KbName('space'))       = 1;
keys.keysOfInterest(KbName('ESCAPE'))      = 1;
keys.keysOfInterest(KbName('return'))      = 1;

keys.disable = find(~keys.keysOfInterest);

% KbEventFlush();
FlushEvents('keyDown');

% % Record keypresses from device
% KbQueueCreate;
% StartTime = GetSecs;
% KbQueueStart;