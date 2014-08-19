function [fileVAFs, fileR2] = doEpochDecoding(root_dirs,use_array,doFiles,epoch,useData,decoder)
% predFlags: (bool} [predpos, predvel, predtarg]
% useData: [start end] ie [0 0.33]

fileVAFs = cell(size(doFiles,1),1);
fileR2 = cell(size(doFiles,1),1);

% Now, make predictions for AD and calculate VAF
for iFile = 1:size(doFiles,1)
    root_dir = root_dirs{strcmpi(root_dirs(:,1),doFiles{iFile,1}),2};
    
    y = doFiles{iFile,2}(1:4);
    m = doFiles{iFile,2}(6:7);
    d = doFiles{iFile,2}(9:10);
    
    disp('Predicting, please wait...');
    
    filt_file = fullfile(root_dir,use_array,'Decoders',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_BL_' m d y '_Decoder_' decoder '.mat']);
    
    bin_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epoch '_' m d y '_trim.mat']);
    load(bin_file);
    
    duration = binnedData.timeframe(end);
    testDataStart = useData(1).*duration;
    testDataEnd = useData(2).*duration;
    [~,testData] = splitBinnedData_Matt(binnedData,testDataStart,testDataEnd);
    
    [OLPredData, ~] = predictSignals(filt_file,testData);
    [r2,vaf,mse] = ActualvsOLPred_Matt(testData,OLPredData,0,0);
    
    fileVAFs{iFile,1} = vaf;
    fileR2{iFile,1} = r2;
    
    disp('Done.');
    clear filt_struct ActualData PredData field_names Use_State;
    
end
disp('Done.');