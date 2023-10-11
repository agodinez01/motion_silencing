function setKeys

global keys

%--------------------------------------------------------------------------
%                           Set Keyboard
%--------------------------------------------------------------------------

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

% % Record keypresses from device
% KbQueueCreate;
% StartTime = GetSecs;
% KbQueueStart;