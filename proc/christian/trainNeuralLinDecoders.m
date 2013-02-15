function Hn = trainNeuralLinDecoders(binnedData,neuronIDs,numlags)

    numneur = size(neuronIDs,1);

    Hn = nan(numneur*numlags,numneur-1,numneur);

    for i=1:numneur
        x = (1:numneur==i);
        y = (1:numneur~=i);

        [Hn(:,:,i),~,~] = filMIMO3(binnedData.spikeratedata(:,x),binnedData.spikeratedata(:,y),numlags,1,1);
    end

end