function [el, error]=initEyelink(vpcode)
%
% Initializes eyeLink-connection, creates edf-file
% and writes experimental parameters to edf-file
% 
% 2008 by Martin Rolfs

global setting visual scr

%---------------------%
% define edf-filename %
%---------------------%
edffilename = strcat(vpcode,'.edf');

% set eyelink defaults
el=EyelinkInitDefaults(scr.window);

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(setting.TEST~=0) % const.DOTRACK<1
    fprintf('Eyelink Init aborted.\n');
    Eyelink('Shutdown');
    return;
end


% create edf-file
i = Eyelink( 'openfile', edffilename);
if i~=0
	fprintf(1,'Cannot create EDF file ''%s'' ', edffilename);
	Eyelink( 'Shutdown');
	return;
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
Eyelink('message', 'Subject code: %s', vpcode);
Eyelink('message', 'END OF DESCRIPTIONS');

%--------------------------------------%
% modify a few of the default settings %
%--------------------------------------%
el.backgroundcolour = scr.gray;		% background color when calibrating
el.foregroundcolour = scr.black;        % foreground color when calibrating
el.calibrationfailedsound = 0;				% no sounds indicating success of calibration
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

error=el.ABORT_EXPT;


