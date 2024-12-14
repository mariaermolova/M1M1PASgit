clear
addpath('W:\Experimental Data\2019-04 M1M1PAS (processed)\toolboxes\eeglab2024.2')
eeglab
addpath('W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\Source ristretta\Matti functions')  
addpath('W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\Source ristretta\NeoMNE')
%% MNE
clear
subIds = [1:9,11:17];
sesIds = [1:4];
runIds = [1:5];

%load original subject labels
load('W:\Experimental Data\2019-04 M1M1PAS (processed)\Summary files\alldata_extended')
%load dipole indices for ROI
load('C_LR.mat')

%loop over subjects
for subIdx = subIds
    subId = num2str(subIdx);

    clear Mdw

    load(['W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\Mdw\M1M1PAS' alldata{subIdx,'subject'}{:} '.mat']) ;

    %loop over sessions
    for sesId = sesIds
        sesId = num2str(sesId);

        clear LnrN

        % map sessions to conditions
        if strcmp(sesId,'1')
            taskId = 'negneg';
        elseif strcmp(sesId,'2')
            taskId = 'negpos';
        elseif strcmp(sesId,'3')
            taskId = 'posneg';
        elseif strcmp(sesId,'4')
            taskId = 'random';
        end
    
        %load the leadfield of the session
        load(['W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\LF\sub-' subId...
            '_task-' taskId '_LF.mat']) ;

        %loop over recordings
        for runId = runIds
            runId = num2str(runId);

            clear Sestim EEG Xst roiIdc roiLabels

            %skip a missing recording
            if strcmp(subId,'11') & strcmp(taskId,'random') & strcmp(runId,'3')
                continue
            end

            %load the cleaned EEG data
            EEG = pop_loadset( 'filename', ['sub-' subId '_ses-' sesId '_task-' taskId...
                '_run-' runId '_eeg.set'], 'filepath', ['W:\Experimental Data\2019-04 M1M1PAS (processed)\BIDS_EXPORT\derivatives\eeglab\derivatives\preprocessed']);

            Xst = EEG.data;
            chN=size(Xst,1); 
            Xst=reshape(Xst,chN,[]);

            % %Run with random data
            % randinds = [];
            % for ii = 1:size(Xst,1)
            %     randinds(ii,:) = randperm(size(Xst,2));
            % end
            % Xst = Xst(randinds);

            %Average reference
            Xst = Xst - mean(Xst,1);
            LnrN = LnrN - mean(LnrN,1);

            %set MNE parameters
            lambda = 0.01;
            timeAxis = [1:size(Xst,2)];
            timeInt = [1 size(Xst,2)];

            %calculate source time-ciurses
            [Sestim, ~, ~]=estimateCorrelatedSourceAmplitudesFast(LnrN, Mdw, Xst, lambda,...
                indsp, timeAxis, timeInt);

            %get dipole indices for ROIs
            [indices,~] = find(C);
            [indicesL] = indices(1:166);
            [indicesR] = indices(167:end);

            %select and average over dipoles of interest
            % leftSM = mean(Sestim(indicesL,:),1);
            % rightSM = mean(Sestim(indicesR,:),1);
            pcaL = pca(Sestim(indicesL,:));
            leftSM = pcaL(:,1)';
            pcaR = pca(Sestim(indicesR,:));
            rightSM = pcaR(:,1)';

            save(['W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\MNEoldLFPC\sub-' subId '_task-' taskId '_run-' runId '_MNE'],'leftSM','rightSM')
        end
    end
end
