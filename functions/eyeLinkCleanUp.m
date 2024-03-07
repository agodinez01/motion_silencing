function eyeLinkCleanUp

global setting

if setting.TEST == 0
    % stop recording
    Eyelink('StopRecording');
    WaitSecs(1.0);
    % retrieve EDF file
    status = Eyelink('ReceiveFile');
    if status == 0
        fprintf(1,'\n\nFile transfer was cancelled\n\n');
    elseif status < 0
        fprintf(1,'\n\nError occurred during file transfer\n\n');
    else
        fprintf(1,'\n\nFile has been transferred (%i Bytes)\n\n', status)
    end
   
    % close file
    Eyelink('CloseFile');
    WaitSecs(2.0);
    % shutdown Eyelink
    Eyelink('shutdown');
    WaitSecs(0.5);
    % rename file:
    status = movefile(strcat(setting.subjectCode, '.edf'), ['../el/', strcat(setting.csvname, '.edf')]);
    disp(['Renaming of file status: ', num2str(status)]);
    
end