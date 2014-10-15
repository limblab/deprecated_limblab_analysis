function [fileVAFs, fileR2,fileFR] = doEpochDecoding(root_dirs,use_array,doFiles,epoch,useData,decoder)
% predFlags: (bool} [predpos, predvel, predtarg]
% useData: [start end] ie [0 0.33]

fileVAFs = cell(size(doFiles,1),1);
fileR2 = cell(size(doFiles,1),1);
fileFR = cell(size(doFiles,1),1);

switch lower(decoder)
    case 'position'
        numVars = 2;
    case 'velocity'
        numVars = 3;
    case 'target'
        numVars = 2;
end

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
    
    if length(useData)==1 % cycle along blocks of length of useData
        duration = binnedData.timeframe(end);
        
        blocks = 0:useData:duration;
        
        allVAF = zeros(length(blocks)-1,numVars);
        allR2 = zeros(length(blocks)-1,numVars);
        for iBlock = 1:length(blocks)-1
            testDataStart = blocks(iBlock);
            testDataEnd = blocks(iBlock+1);
            [~,testData] = splitBinnedData_Matt(binnedData,testDataStart,testDataEnd);
            [OLPredData, ~] = predictSignals_Matt(filt_file,testData);
            [r2,vaf,mse] = ActualvsOLPred_Matt(testData,OLPredData,0,0);
            
            allVAF(iBlock,:)=vaf;
            allR2(iBlock,:)=r2;
        end
        
        fileVAFs{iFile,1} = allVAF;
        fileR2{iFile,1} = allR2;
        
    else % do the normal "between these two intervals" thing
        duration = binnedData.timeframe(end);
        testDataStart = useData(1).*duration;
        testDataEnd = useData(2).*duration;
        [~,testData] = splitBinnedData_Matt(binnedData,testDataStart,testDataEnd);
        
        [OLPredData, ~] = predictSignals_Matt(filt_file,testData);
        [r2,vaf,mse] = ActualvsOLPred_Matt(testData,OLPredData,0,0);
        
        fileVAFs{iFile,1} = vaf;
        fileR2{iFile,1} = r2;
        
        fileFR{iFile,1} = {binnedData.spikeguide,rms(testData.spikeratedata,1)};
    end
    
    disp('Done.');
    clear filt_struct ActualData PredData field_names Use_State;
    
end
disp('Done.');