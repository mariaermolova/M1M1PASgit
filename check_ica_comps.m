%% Remove artifactial ICA components
% Look through the ICA components, manually adjust selection for removal,
% remove them from data

% Load STUDY and ALLEEG
% [STUDY, ALLEEG] = pop_loadstudy('filename', 'study_name.study');

%% Loop through each dataset and select components
for i = 1:length(ALLEEG)

    sprintf('Processing dataset %d',i)

    % Select one dataset
    EEG = ALLEEG(i);

    % Plot ICA components for visual inspection
    pop_selectcomps(EEG, 1:30);  % Displays first 30 components
    uiwait(gcf); 

    % Store the updated EEG dataset back into ALLEEG
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, i);
end
%% Loop through each dataset and remove bad components

for i = 1:length(ALLEEG)

    EEG = ALLEEG(i);

    % Remove bad components based on flags
    EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0);

    % Save the modified dataset back to ALLEEG
    ALLEEG(i) = EEG;
end

% Update the STUDY structure
STUDY = std_checkset(STUDY, ALLEEG);
%% Save the modified datasets

for i = 1:length(ALLEEG)

    pop_saveset(ALLEEG(i), 'filename', ALLEEG(i).filename);
end

% Save the updated STUDY structure
pop_savestudy(STUDY, ALLEEG, 'filename', 'eeglab.study');


