

BD_Words;

matchingInputs = FindMatchingNeurons(binnedData.spikeguide, filter.neuronIDs);

Averages = AveSigs_Words([binnedData.timeframe binnedData.spikeratedata(:,matchingInputs)],out_struct.words,Start,Go_Cue,Reward);

means = mean(Averages);
stds  = std(Averages);
N = size(Averages,1);

concatMSN = [means' stds' N*ones(size(Averages,2),1)];

%concatMSN = zeros(1,3*size(Averages,2));
% for i=0:size(Averages,2)-1
%     concatMSN(i*3+1)=means(i+1);
%     concatMSN(i*3+2)=stds(i+1);
%     concatMSN(i*3+3)=N;
% end

FileName = [out_struct.meta.filename(end-20:end-4) '_G-R_FR_means.mat'];
FilePath = 'C:\Monkey\Theo\Analysis\FRvsFatigue\';

[FileName,FilePath] = uiputfile( fullfile(FilePath,FileName), 'Save file');
fullfilename = fullfile(FilePath, FileName);

if isequal(FileName,0)
    disp('The structure was not saved!')
    FileName = 0; FilePath = 0;
else
    save(fullfilename, 'Averages','means', 'stds', 'N', 'concatMSN');
    disp(['File: ', fullfilename,' saved successfully']);
end

clear binnedData out_struct;
% 
% means022 = means;
% N022 = N;
% concatMSN022 = concatMSN;
% stds022 = stds;
% Averages022 = Averages;
% clear means N concatMSN stds Averages;