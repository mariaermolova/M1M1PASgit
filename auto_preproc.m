%%Automatic pre-processing of resting state EEG data
% check folder
addpath 'W:\Experimental Data\2019-04 M1M1PAS (processed)\toolboxes\eeglab2024.2'
eeglab;

% import data
pop_editoptions( 'option_storedisk', 1); % only one dataset in memory at a time

[STUDY, ALLEEG] = pop_importbids('W:\Experimental Data\2019-04 M1M1PAS (processed)\BIDS_EXPORT_TEST', 'bidsevent','off','bidschanloc','off','outputdir','W:\\Experimental Data\\2019-04 M1M1PAS (processed)\\BIDS_EXPORT\\derivatives\\eeglab');
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

% downsample from 5k to 1k
ALLEEG = pop_resample(ALLEEG, 1000);

% compute average reference
ALLEEG = pop_reref( ALLEEG,[]);

% clean data using the clean_rawdata plugin
ALLEEG = pop_clean_rawdata( ALLEEG,'FlatlineCriterion',10,'ChannelCriterion',0.7, ...
    'LineNoiseCriterion',5,'Highpass',[0.75 1.25] ,'BurstCriterion',30, ...
    'WindowCriterion','off','BurstRejection','on','Distance','Euclidian', ...
    'fusechanrej',1);

% recompute average reference interpolating missing channels (and removing
% them again after average reference - STUDY functions handle them automatically)
ALLEEG = pop_reref( ALLEEG,[],'interpchan',[]);

% run ICA reducing the dimension by 1 to account for average reference 
% plugin_askinstall('picard', 'picard', 1); % install Picard plugin

ALLEEG = pop_runica(ALLEEG, 'icatype','picard','concatcond','on','options',{'pca',-1});

% run ICLabel and flag artifactual components
ALLEEG = pop_iclabel(ALLEEG, 'default');
ALLEEG = pop_icflag( ALLEEG,[NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
% pop_selectcomps(EEG, [1:30] );

% revert default option
pop_editoptions( 'option_storedisk', 0);

