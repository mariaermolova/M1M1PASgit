%%
addpath('W:\Experimental Data\2019-04 M1M1PAS (processed)\toolboxes\eeglab2024.2')
eeglab
addpath('W:\Projects\2019-04 M1M1PAS Project\toolboxes\fieldtrip-20240731')
ft_defaults
addpath('W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\Source ristretta\Matti functions')  
addpath('W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\Source ristretta\NeoMNE')
%%
clear
close all

% subIds = [4:9,11:17];
subIds = [17];
sesIds = [1:4];

load('W:\Experimental Data\2019-04 M1M1PAS (processed)\Summary files\alldata_extended')

%loop over subjects
for subIdx = subIds
    subId = num2str(subIdx);

    %load the headmodel of the subject
    load(['W:\Experimental Data\2019-04 M1M1PAS (processed)\headmodels\M1M1PAS' alldata{subIdx,'subject'}{:} '.mat'])

    %get bmeshes
    bmeshes={headmodel.bmeshes(1) headmodel.bmeshes(2) headmodel.bmeshes(3)};

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

        %load eeg labels from the actual recording
        EEG = pop_loadset( 'filename', ['sub-' subId '_ses-' sesId '_task-' taskId '_run-1_eeg.set'],...
            'filepath', ['W:\Experimental Data\2019-04 M1M1PAS (processed)\BIDS_EXPORT\derivatives\eeglab\derivatives\preprocessed'],...
            'loadmode', 'info');
        eegLabels = {EEG.chanlocs.labels};

        %load realigned electrode locations
        load(['W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\elec_realigned\sub-' subId '_task-' taskId '_elec_realigned.mat']) ;

        %make sure realigned electrodes follow the order of eeg channels
        cfg=[];
        cfg.channel=eegLabels; 
        cfg.layout = 'ordered';
        elec_realigned2 = ft_prepare_layout(cfg, elec_realigned);
        elec_realigned2.elecpos=elec_realigned.elecpos(ismember(elec_realigned.label,elec_realigned2.label),:);
        elecs.porig=elec_realigned2.elecpos;
        elecs.name=elec_realigned2.label';

        %project electrode locations to scalp
        elecs=hbf_ProjectElectrodesToScalp(elecs.porig,bmeshes);

        %calculate leadfield
        ci=[1 1/80 1]*.33;
        co=[1/80 1 0]*.33;
        D=hbf_BEMOperatorsPhi_LC(bmeshes);
        Tphi_full=hbf_TM_Phi_LC_ISA2(D,ci,co,1);
        Tphi_elecs=hbf_InterpolateTfullToElectrodes(Tphi_full,bmeshes,elecs);
        smesh.nn=CalcNodeNormals(headmodel.smesh);
        LFMphi_dir=hbf_LFM_LC(bmeshes,Tphi_elecs,headmodel.smesh.p,headmodel.smesh.nn);
        [~, indx]=ismember(eegLabels, elec_realigned2.label); % Its very important to make sure that the order of electrodes remain consistent
        LF.leadfield=LFMphi_dir(indx,:);
        LF.label=eegLabels;
        L_reordered = LF.leadfield;
        headmodel.leadfield=L_reordered;
        [LnrN]=prepareLFM(headmodel, 1, []); 

        % sanity check!!!
        % IF all of the previous is right, there should be a red spot atop the left motor cortex
        sensitivity_profile=zeros(size(L_reordered,1),1);
        sensitivity_profile(ismember(LF.label, 'C3'))=1;
        figure
        PlotDataOnMesh(headmodel.smesh,sensitivity_profile'*LnrN,'colormap', jet ,'colorbar', 0, 'view', [-90 50]);

        save(['LF/sub-' subId '_task-' taskId '_LF'], 'LnrN')
    end
end