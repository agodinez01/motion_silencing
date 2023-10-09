function [matName, csvName, contPrevious, continueData] = doesFileExists(filename, csvname)

% Checks whether file already exists
% AGodinez December 2022

global setting

saveDir = 'data/mat/';
cd(saveDir)
folderInfo = dir;

if length(folderInfo) <= 2 % If the folder is empty, give it the same name and get out
    matName = filename;
    csvName = csvname;
    contPrevious = 'n';
    continueData = '~';

else % If the folder is not empty, try to match each entry with the name to see if exists

    % Check if a file with those descriptors already exists
    for k = 1:length(folderInfo)
        previousFileName = folderInfo(k).name;
        
        if length(previousFileName) < 4 % If there are less than four characters, it is not a file
            fprintf('%s is not a file \n', previousFileName)
        else
   
            if previousFileName(end-9:end) == filename(end-9:end) % If the name matches
                previousFile = load(previousFileName); % Load the previous file
                setting.trialsRemaining = sum(isnan(previousFile.data.nrec(:,6))); % Figure out how many trials remain
        
                if setting.trialsRemaining == 0 % If none remain, write on the command window that it already exists
                    error(['File ending : ' filename(end-9:end) ' already exists and seems to be compete! Please check the subject, session and block number and try again.']);
                else
                    printMessage = 'The file ending in %s already exists but has %s trials left \n'; % But if the file exists and has ramining trials left, print that on the command window
                    fprintf(printMessage, filename(end-9:end), num2str(setting.trialsRemaining));
                    contPrevious = input('Would you like to continue the previous file?   [y/n]  :', 's'); % Ask if you want to continue where you left off
                    
                    if contPrevious == 'y' % If yes, then you will continue from the last entry -1
                        sprintf('Will continue with the previous data.')
                        continueData = previousFile.data;
                        matName = previousFileName;
                        csvName = previousFileName(1:end-4);
                    elseif contPrevious == 'n'
                        sprintf('Ok, creating a new file \n')
                        continueData = '~';
                        matName = filename;
                        csvName = csvname;
                        break
                    end
                    break
                end
                else
                    contPrevious = 'n';
                    continueData = '~';
                    matName = filename;
                    csvName = csvname;
            end
            
        end
    end
end
