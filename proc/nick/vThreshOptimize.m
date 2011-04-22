% load binned data file prior to running...

dataPath = '';
fillen = 0.5;
UseAllInputsOption = 1;
PolynomialOrder = 1;
PredEMG = 0;
PredForce = 0;
PredCursPos = 0;
PredVeloc = 1;
Use_SD = 1;

foldlength = 60;
dataEnd = length(binnedData.timeframe);
binsize = binnedData.timeframe(2)-binnedData.timeframe(1);

leave_center_words = binnedData.words(:,2) == 49; % create a logical array with indices of all words that represent leaving center target
reward_words = binnedData.words(:,2) == 32; % create a logical array with indices of all words that represent rewards (successful trials)
rel_times = [binnedData.words(leave_center_words,1); binnedData.words(reward_words,1)];

binnedData.targetHold = false(length(binnedData.timeframe),1);
for x = 1:length(rel_times)
    for y = 1:length(binnedData.timeframe)
        if binnedData.timeframe(y) > rel_times(x)
            break
        elseif rel_times(x) - binnedData.timeframe(y) < 0.5
            binnedData.targetHold(y,1) = true;
        end
    end
end

for thresh = 1:5 % treshold values in cm/sec
    
    binnedData.states = binnedData.velocbin(:,3) > thresh;
    
    testData = binnedData;
    modelData = binnedData;

    nfold = 1; % number of folds to test

    for i = 0:nfold-1

        fprintf('processing xval %d of %d for threshold %d\n',i+1,nfold,thresh);

        testDataStart = round(1 + i*foldlength/binsize);      %move the test block from beginning of file up to the end,round because of floating point error
        testDataEnd = round(testDataStart + foldlength/binsize - 1);    

        %copy timeframe and spikeratedata segments into testData
        testData.timeframe = binnedData.timeframe(testDataStart:testDataEnd);
        testData.spikeratedata = binnedData.spikeratedata(testDataStart:testDataEnd,:);
        testData.states = binnedData.states(testDataStart:testDataEnd,:);
        testData.targetHold = binnedData.targetHold(testDataStart:testDataEnd,:);

        %copy timeframe and spikeratedata segments into modelData
        if testDataStart == 1
            modelData.timeframe = binnedData.timeframe(testDataEnd+1:dataEnd);    
            modelData.spikeratedata = binnedData.spikeratedata(testDataEnd+1:dataEnd,:);
            modelData.states = binnedData.states(testDataEnd+1:dataEnd,:);
            modelData.targetHold = binnedData.targetHold(testDataEnd+1:dataEnd,:);
        elseif testDataEnd == dataEnd
            modelData.timeframe = binnedData.timeframe(1:testDataStart-1);
            modelData.spikeratedata = binnedData.spikeratedata(1:testDataStart-1,:);
            modelData.states = binnedData.states(1:testDataStart-1,:);
            modelData.targetHold = binnedData.targetHold(1:testDataStart-1,:);
        else
            modelData.timeframe = [ binnedData.timeframe(1:testDataStart-1); binnedData.timeframe(testDataEnd+1:dataEnd)];
            modelData.spikeratedata = [ binnedData.spikeratedata(1:testDataStart-1,:); binnedData.spikeratedata(testDataEnd+1:dataEnd,:)];        
            modelData.states = [ binnedData.states(1:testDataStart-1,:); binnedData.states(testDataEnd+1:dataEnd,:)];
            modelData.targetHold = [ binnedData.targetHold(1:testDataStart-1,:); binnedData.targetHold(testDataEnd+1:dataEnd,:)];
        end

        % copy emgdatabin segment into modelData only if PredEMG
        if PredEMG
            testData.emgdatabin = binnedData.emgdatabin(testDataStart:testDataEnd,:);    
            if testDataStart == 1
                modelData.emgdatabin = binnedData.emgdatabin(testDataEnd+1:dataEnd,:);    
            elseif testDataEnd == dataEnd
                modelData.emgdatabin = binnedData.emgdatabin(1:testDataStart-1,:);
            else
                modelData.emgdatabin = [ binnedData.emgdatabin(1:testDataStart-1,:); binnedData.emgdatabin(testDataEnd+1:dataEnd,:)];
            end
        end

        % copy forcedatabin segment into modelData only if PredForce
        if PredForce
            testData.forcedatabin = binnedData.forcedatabin(testDataStart:testDataEnd,:);    
            if testDataStart == 1
                modelData.forcedatabin = binnedData.forcedatabin(testDataEnd+1:dataEnd,:);    
            elseif testDataEnd == dataEnd
                modelData.forcedatabin = binnedData.forcedatabin(1:testDataStart-1,:);
            else
                modelData.forcedatabin = [ binnedData.forcedatabin(1:testDataStart-1,:); binnedData.forcedatabin(testDataEnd+1:dataEnd,:)];
            end
        end

        % copy cursorposbin segment into modelData only if PredCursPos
        if PredCursPos
            testData.cursorposbin = binnedData.cursorposbin(testDataStart:testDataEnd,:);    
            if testDataStart == 1
                modelData.cursorposbin = binnedData.cursorposbin(testDataEnd+1:dataEnd,:);    
            elseif testDataEnd == dataEnd
                modelData.cursorposbin = binnedData.cursorposbin(1:testDataStart-1,:);
            else
                modelData.cursorposbin = [ binnedData.cursorposbin(1:testDataStart-1,:); binnedData.cursorposbin(testDataEnd+1:dataEnd,:)];
            end
        end

        % copy velocbin segement into modelData only if PredVeloc
         if PredVeloc
            testData.velocbin = binnedData.velocbin(testDataStart:testDataEnd,:);    
            if testDataStart == 1
                modelData.velocbin = binnedData.velocbin(testDataEnd+1:dataEnd,:);    
            elseif testDataEnd == dataEnd
                modelData.velocbin = binnedData.velocbin(1:testDataStart-1,:);
            else
                modelData.velocbin = [ binnedData.velocbin(1:testDataStart-1,:); binnedData.velocbin(testDataEnd+1:dataEnd,:)];
            end
         end

    %     testData.states = evalin('base',sprintf('test_states{1,%d}',i+1));
    %     modelData.states= evalin('base',sprintf('model_states{1,%d}',i+1));

        % 2 different models, one for each state:
        fprintf('Model Building...\n');
        tic;
        filter = BuildSDModel(modelData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_SD);
        toc;

        model.posture_decoder = filter{2};
        model.movement_decoder = filter{3};

        PredData = predictSDSignals(model, testData, Use_SD);
    %     PredData = predictSDSignals(filter, testData, Use_SD);
        TestSigs = concatSigs(testData, PredEMG, PredForce, PredCursPos, PredVeloc); 

        R2(i+1,:,thresh) = CalculateR2(TestSigs,PredData.preddatabin)';
        vaf(i+1,:,thresh) = 1 - sum( (PredData.preddatabin-TestSigs).^2 ) ./ sum( (TestSigs - repmat(mean(TestSigs),size(TestSigs,1),1)).^2 );
        mse(i+1,:,thresh) = mean((PredData.preddatabin-TestSigs).^2);
        SDpost(i+1,:,thresh) = std(PredData.preddatabin(testData.targetHold));

    end %for i = 0:nfold-1

end % for thresh = 1:16
