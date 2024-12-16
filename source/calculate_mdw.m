%% Calculate Mdw for MNE

addpath('W:\Projects\2019-04 M1M1PAS Project\analysis\source_Paolo\Source ristretta\NeoMNE')
%%
clear

%get filenames of headmodels
headmodelNames = dir('W:\Experimental Data\2019-04 M1M1PAS (processed)\headmodels');
headmodelNames = headmodelNames(3:end);

for subIdx = 1:length(headmodelNames)

    %Load the subject's headmodel
    load(['W:\Experimental Data\2019-04 M1M1PAS (processed)\headmodels\' headmodelNames(subIdx).name])

    % Calculate the Mdw matrix
    distanceTH=6;
    attenuation_length=10;
    [Mdw,indsp]=createSourceCovM(headmodel, distanceTH, attenuation_length);

    %Save result
    save(['Mdw/' headmodelNames(subIdx).name], 'Mdw','indsp')

end