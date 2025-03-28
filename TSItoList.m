%% Reorder the TS MEP data from a cell array into a list (i.e. table)
% "MEP" cell array is (nSubjects, nConditions, nTimes, nChannels)
% Transform it to a list to be used in R
clear
load(fullfile('W:\Projects\2019-04 M1M1PAS Project\analysis',...
    'SIHI_data_conditioning_fixed_16subj_with_Rearranged.mat'),'TSI2')
MEP = TSI2;

%Initiate variables
Subject = [];
Intervention = [];
Time = [];
Channel = [];
Response = [];

%Set levels of variables
Times = ["Pre","0","30","60"];
Interventions = ["negneg","posneg","negpos","random"];
Channels = ["APBr","FDIr","APBl","FDIl"]; %check it

%loop through subjects
for iSubject = 1:size(MEP, 1)
    %loop through interventions
    for iIntervention = 1:size(MEP,2)
        %loop through runs
        for iTime = 1:size(MEP, 3)
            %loop through channels
            for iChannel = 1:size(MEP,4)
                %get the number of subselected data samples
                nSamples = length(MEP{iSubject, iIntervention, iTime, iChannel});
                %SIHI values
                Response = [Response; MEP{iSubject, iIntervention, iTime, iChannel}];
                
                %repeat subject id
                Subject = [Subject; repmat(sprintf("sub-%03.f", iSubject), nSamples, 1)];
                %repeat run id
                Time = [Time; repmat(Times(iTime), nSamples, 1)];
                %repeat intervention id
                Intervention = [Intervention;repmat(Interventions(iIntervention), nSamples, 1)];
                %repeat EMG channel id
                Channel = [Channel;repmat(Channels(iChannel), nSamples, 1)];
            end
        end
    end
end

%store everything in a table
MEPdata = table(Subject, Intervention, Time, Channel, Response);
writetable(MEPdata,'TSIdata.csv');