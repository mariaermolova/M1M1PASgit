%% Reorder the MEP from a cell array into a list (i.e. table)
load(fullfile('W:\Experimental Data\2019-04 M1M1PAS (processed)\Summary files',...
    'SIHI_data_16subj_with_Rearranged.mat'),'MEP','INT')
% "MEP" is (nSubjects, nConditions, nTimes, nChannels)

Subject = [];
Intervention = [];
Time = [];
Channel = [];
Intensity = [];
Response = [];

Times = ["Pre","0","30","60"];
Interventions = ["negneg","posneg","negpos","random"];
Channels = ["APBr","FDIr","APBl","FDIl"]; %check it

for iSubject = 1:size(MEP, 1)
    for iIntervention = 1:size(MEP,2)
        for iTime = 1:size(MEP, 3)
            for iChannel = 1:size(MEP,4)
                nSamples = length(MEP{iSubject, iIntervention, iTime, iChannel});
                Response = [Response; MEP{iSubject, iIntervention, iTime, iChannel}];
                Intensity = [Intensity; INT{iSubject, iIntervention, iTime, iChannel}'];
                Subject = [Subject; repmat(sprintf("sub-%03.f", iSubject), nSamples, 1)];
                Time = [Time; repmat(Times(iTime), nSamples, 1)];
                Intervention = [Intervention;repmat(Interventions(iIntervention), nSamples, 1)];
                Channel = [Channel;repmat(Channels(iChannel), nSamples, 1)];
            end
        end
    end
end

MEPdata = table(Subject, Intervention, Time, Channel, Intensity, Response);
writetable(MEPdata,'MEPdata.csv');