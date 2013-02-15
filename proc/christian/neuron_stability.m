function [vaf, varargout] = neuron_stability(traindata,testdata,numlags)

neuronIDs = getCommonUnits(traindata,testdata);

numneur = size(neuronIDs,1);

disp(sprintf('Calculating decoders for %d neurons',numneur));

Hn = trainNeuralLinDecoders(traindata,neuronIDs,numlags);



    
    