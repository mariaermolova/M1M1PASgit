% Path to data
dataFolder = 'W:\\Experimental Data\\2019-04 M1M1PAS (processed)\\EEG_RS\\';

% Get a list of all .set files in the folder
fileList = dir(fullfile(dataFolder, '*.set'));

% Initialize the STUDY structure and index counter
STUDY = []; % Initialize empty STUDY structure
index = 1;

% Initialize a map to keep track of subject numbering
subjectMap = containers.Map(); % Map original subject number to new subject number
subjectCounter = 1; % Start with subject number 1

% Define mapping of conditions to sessions
conditionSessionMap = containers.Map(...
    {'negneg', 'negpos', 'posneg', 'random'}, ...
    {1, 2, 3, 4} ...
);

% Loop through each file in the folder
for i = 1:length(fileList)
    % Get the full file name
    fileName = fileList(i).name;
    
    % Use regular expressions to extract subject number, condition, and run
    pattern = 'M1M1PAS_(\d+)-([a-zA-Z]+)-eeg_eo-(\d+)\.set';
    tokens = regexp(fileName, pattern, 'tokens');
    
    if ~isempty(tokens)
        % Extract the relevant parts of the file name
        originalSubjectNumber = tokens{1}{1}; % Original subject number from the file name
        condition = tokens{1}{2};             % Condition
        run = str2double(tokens{1}{3});       % Run
        
        % Check if this subject already has a new assigned number
        if isKey(subjectMap, originalSubjectNumber)
            newSubjectNumber = subjectMap(originalSubjectNumber);
        else
            % Assign a new subject number
            newSubjectNumber = subjectCounter;
            subjectMap(originalSubjectNumber) = newSubjectNumber;
            subjectCounter = subjectCounter + 1; % Increment the subject counter for the next new subject
        end
        
        % Map condition to session
        if isKey(conditionSessionMap, condition)
            session = conditionSessionMap(condition);
        else
            error('Unknown condition: %s', condition);
        end
        
        % Build the STUDY entry for this file
        STUDY.datasetinfo(index).index = index;
        STUDY.datasetinfo(index).filepath = fullfile(dataFolder, fileName);
        STUDY.datasetinfo(index).subject = ['sub-' num2str(newSubjectNumber)]; % Use the new mapped subject number
        STUDY.datasetinfo(index).session = session;
        STUDY.datasetinfo(index).run = run;
        STUDY.datasetinfo(index).condition = condition;
        STUDY.datasetinfo(index).task = condition;
        
        % Increment the index counter
        index = index + 1;
    else
        warning('File name format not recognized: %s', fileName);
    end
end


