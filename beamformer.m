%%
addpath('W:\Experimental Data\2019-04 M1M1PAS (processed)\toolboxes\eeglab2024.2')
eeglab
addpath('W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\Source ristretta\Matti functions')  
addpath('W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\Source ristretta\NeoMNE')

%% Beamformer
clear
subIds = [1:9,11:17];
sesIds = [1:4];
runIds = [1:5];

%load dipole indices for ROI
load('C_LR.mat')

%loop over subjects
for subIdx = subIds
    subId = num2str(subIdx);

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

            clear Sestim EEG Xst

            %skip a missing recording
            if strcmp(subId,'11') & strcmp(taskId,'random') & strcmp(runId,'3')
                continue
            end

            %load the cleaned EEG data
            EEG = pop_loadset( 'filename', ['sub-' subId '_ses-' sesId '_task-' taskId...
                '_run-' runId '_eeg.set'], 'filepath', ...
                ['W:\Experimental Data\2019-04 M1M1PAS (processed)\BIDS_EXPORT\derivatives\eeglab\derivatives\preprocessed']);

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
            LnrN = LnrN - mean(LnrN,1);
            Xst = Xst - mean(Xst,1);

            %getting the LAMBDA and the COV matrix
            lambda_factor=10;

            %computing the covariance matrix
            chN=size(LnrN,1); 
            Cov=Xst*Xst'/size(Xst,2); % this is considered the over all data covariance of EEG
            
            lambda=lambda_factor*max(eig(Cov));
            invCy = pinv(Cov + lambda * eye(size(Cov)));
            
            %getting dipole indices for ROIs
            [indices,~] = find(C);
            [indicesL] = indices(1:166);
            [indicesR] = indices(167:end);
            
            %M1Left
            lf1 = LnrN(:,indicesL);
            filt = pinv(lf1' * invCy * lf1) * lf1' * invCy;  
            source_L=filt * Xst;
            % leftSM = mean(source_L,1);
            pcaL = pca(source_L);
            leftSM = pcaL(:,1)';
            
            %M1Right
            lf1 = LnrN(:,indicesR);
            filt = pinv(lf1' * invCy * lf1) * lf1' * invCy;  
            source_R=filt * Xst;
            % rightSM = mean(source_R,1);
            pcaR = pca(source_R);
            rightSM = pcaR(:,1)';


            save(['W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\BeamformeroldLFPC\sub-' subId '_task-' taskId '_run-' runId '_Beam'],'leftSM','rightSM')
        end
    end
