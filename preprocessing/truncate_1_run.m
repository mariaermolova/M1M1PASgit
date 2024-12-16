%% The first run in the session is 10 minutes. Truncate it to 5 mins to match later runs.
% Loop through each dataset in ALLEEG
for i = 1:length(ALLEEG)

    % Get the current dataset
    EEG = ALLEEG(i);

    % Retain only the last 300 seconds of data
    EEG = pop_select(EEG, 'time', [EEG.xmax-299 EEG.xmax]);
    
    pop_saveset(EEG, 'filename', EEG.filename );
end



