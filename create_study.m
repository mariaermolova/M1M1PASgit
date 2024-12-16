%% Create an EEGLAB STUDY structure (to use automatic batch processing)
%existing STUDY structure was created with create_study.m

% % To do this manually
%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%[STUDY ALLEEG] = std_editset( STUDY, [], 'commands',{...
%     {'index',1,'load','W:\\Experimental Data\\2019-04 M1M1PAS (processed)\\EEG_RS\\M1M1PAS_001-negneg-eeg_eo-1.set',...
%     'subject','sub-001','session',1,'run',1,'condition','negneg','task','negneg'},...
%     {'index',2,'load','W:\\Experimental Data\\2019-04 M1M1PAS (processed)\\EEG_RS\\M1M1PAS_001-negneg-eeg_eo-2.set',...
%     'subject','sub-001','session',1,'run',2,'condition','negneg','task','negneg'}});

% one dataset loaded at a time
pop_editoptions( 'option_storedisk', 1);

commands = {};

% Loop through all of the subjects in the study
for loopnum = 1:length(STUDY.datasetinfo) 

    %get info from the existing STUDY structure
    dataFile = STUDY.datasetinfo(loopnum);

    %store info in the commands parameter
    commands = {commands{:} ...
    {'index' dataFile.index 'load' dataFile.filepath 'subject' dataFile.subject 'condition' dataFile.condition...
    'session' dataFile.session 'run' dataFile.run 'task' dataFile.task}};
end

%create new STUDY structure with the commands parameters
[STUDY, ALLEEG] = std_editset(STUDY, ALLEEG, 'name','M1M1PAS','commands',commands,'updatedat','on');

CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
[STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
eeglab redraw