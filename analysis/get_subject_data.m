
addpath('../analysis')
dataDir = 'C:\Users\angie\Git Root\motion_silencing\data\mat';

cd(strcat(dataDir));
all_files = dir; 

% Get list of all subjects, files and blocks
subjects = nan(1,length(all_files)); 
blocks = nan(1,length(all_files));
sessions = nan(1,length(all_files));
files = cell(1,length(all_files));

for file = 1:length(all_files) % Go through each file
    if length(all_files(file).name) < 4 % If the file is less than 4 charachters, it's probably not data
        sprintf('%s is not a file \n', all_files(file).name)
        files{file} = nan; % Make a nan entry
        subjects(file) = nan;
    else
        sprintf('Working on file %s \n', all_files(file,:).name)
        fname = sprintf(all_files(file).name);
        split = strfind(fname, '_'); % Find the delimiter and store it in a variable

        if str2num(fname(split(3)+1: split(4)-1)) == 0 % If the session is equal to 0, it's a practice session and shouldn't be included
            files{file} = nan;
            sprintf('%s is a practice file. Will ignore. \n', fname)
        else

            files{file} = fname;
            subjects(file) = str2num(fname(split(2)+1:split(3)-1));
            blocks(file)   = str2num(fname(split(4)+1:split(4)+1));
            sessions(file) = str2num(fname(split(3)+1:split(3)+1));
        end
    end
end

subjects(:,all(isnan(subjects),1)) = []; % Remove nans in array
subjectsUnique = unique(subjects); % Get subject ids

blocks(:,all(isnan(blocks), 1)) = [];
blocksUnique = sort(unique(blocks));

files(cellfun('isclass', files, 'double')) = []; % Remove nans in cell
blockFiles = {};

% Get the list of files for each block
for block = 1:length(blocksUnique)
    idx = find(blocks == blocks(block));
    for i=1:length(idx)
        blockFiles{block,i} = files{idx(i)};
    end
end






subOrder = nan(1,length(subjects));

%[row, col] = size(files{1}); % Get number of columns in a given file. Assuming you have the same number of columns across your files
allSubData = cell(length(subjects),1); % Allocate space for data



for i = 1:length(subjects)
    allSubData{i} = join_subject_files(files, subjects(i));
    subOrder(i) = subjects(i);
end


for i = 1:length(subjects)
    all_sub_data{i} = joinSubjectFiles(files, subjects(i));
    sub_order(i) = subjects(i);
end
