if (exist('BMI_analysis','dir') ~= 7)
    load_paths;
end

monkey{1} = 'Chewie'; monkey{2} = 'Mini';
datasets(1) = 9; datasets(2) = 10; % 9 files for Chewie and 10 for Mini

stdvaf   = cell(1,length(monkey));
polyvaf  = cell(1,length(monkey));
hybvaf   = cell(1,length(monkey));
stdmse   = cell(1,length(monkey));
polymse  = cell(1,length(monkey));
hybmse   = cell(1,length(monkey));
stdmvaf  = cell(1,length(monkey));
polymvaf = cell(1,length(monkey));
hybmvaf  = cell(1,length(monkey));
hybclass = cell(1,length(monkey));
stdPredData   = cell(1,length(monkey));
polyPredData  = cell(1,length(monkey));
hybPredData   = cell(1,length(monkey));
stdPredTime   = cell(1,length(monkey));
polyPredTime  = cell(1,length(monkey));
hybPredTime   = cell(1,length(monkey));
stdOrigData   = cell(1,length(monkey));
polyOrigData  = cell(1,length(monkey));
hybOrigData   = cell(1,length(monkey));
stdOrigTime   = cell(1,length(monkey));
polyOrigTime  = cell(1,length(monkey));
hybOrigTime   = cell(1,length(monkey));

for m = 1:length(monkey)
    
    for dataset = 1:datasets(m)

        % load binnedData and decoder files
        load(['C:\Users\Nicholas Sachs\Desktop\SD_Datasets\' monkey{m} '_binned_' num2str(dataset) '.mat']);
        
        fprintf('Monkey %d, Dataset %d, Linear\n',m,dataset);
        [R2, vaf, mse, mvaf, classrate, AllPredData, AllbinnedData] = mfxvalSD_NS(binnedData,'',60,0.5,1,1,0,0,0,1,0);
%         [R2, vaf, mse] = mfxval(binnedData,'',60,0.5,1,1,0,0,0,1);
        stdvaf{m} = [stdvaf{m}; vaf];
        stdmse{m} = [stdmse{m}; mse];
        stdmvaf{m} = [stdmvaf{m}; mvaf];
        stdPredData{m} = [stdPredData{m}; AllPredData.preddatabin];
        stdPredTime{m} = [stdPredTime{m}; AllPredData.timeframe];
        stdOrigData{m} = [stdOrigData{m}; AllbinnedData.velocbin];
        stdOrigTime{m} = [stdOrigTime{m}; AllbinnedData.timeframe];

        fprintf('Monkey %d, Dataset %d, 3rd Order\n',m,dataset);
        [R2, vaf, mse, mvaf, classrate, AllPredData, AllbinnedData] = mfxvalSD_NS(binnedData,'',60,0.5,1,3,0,0,0,1,0);
%         [R2, vaf, mse] = mfxval(binnedData,'',60,0.5,1,3,0,0,0,1);
        polyvaf{m} = [polyvaf{m}; vaf];
        polymse{m} = [polymse{m}; mse];
        polymvaf{m} = [polymvaf{m}; mvaf];
        polyPredData{m} = [polyPredData{m}; AllPredData.preddatabin];
        polyPredTime{m} = [polyPredTime{m}; AllPredData.timeframe];
        polyOrigData{m} = [polyOrigData{m}; AllbinnedData.velocbin];
        polyOrigTime{m} = [polyOrigTime{m}; AllbinnedData.timeframe];

        fprintf('Monkey %d, Dataset %d, Hybrid\n',m,dataset);
        [binnedData.states, binnedData.statemethods,classifiers] = findStates(binnedData,1,4);
        [R2, vaf, mse, mvaf, classrate, AllPredData, AllbinnedData] = mfxvalSD_NS(binnedData,'',60,0.5,1,1,0,0,0,1,4,7);
%         [R2, vaf, mse] = mfxvalSD_NS(binnedData,'',60,0.5,1,1,0,0,0,1,4);        
        hybmse{m} = [hybmse{m}; mse];
        hybvaf{m} = [hybvaf{m}; vaf];
        hybmvaf{m} = [hybmvaf{m}; mvaf];
        hybclass{m} = [hybclass{m}; classrate];
        hybPredData{m} = [hybPredData{m}; AllPredData.preddatabin];
        hybPredTime{m} = [hybPredTime{m}; AllPredData.timeframe];
        hybOrigData{m} = [hybOrigData{m}; AllbinnedData.velocbin];
        hybOrigTime{m} = [hybOrigTime{m}; AllbinnedData.timeframe];

    end
end