function [FinalPred] = hybridTest(H, binnedData)

Y = binnedData.emgdatabin;
X = binnedData.spikeratedata;

%Test hybrid decoder
[rX,cX]= size(X); [rY,cY]= size(Y);
FinalPred = [];
Xmatrix = [];
for outputInd = 7%:cY
    for inputInd = 1:cX
        rStart = numlags;
        for timeInd = 1:rX-numlags+1
            rInd = rStart-numlags+1:1:rStart;
            Xcur = X(rInd, inputInd);
            Xmatrix(timeInd,:) = Xcur;
           
            
            rStart = rStart+1;
        end
        Hcur = H((inputInd*numlags)-numlags+1:1:((inputInd*numlags)-numlags+1)+numlags-1);
        Pred1Neuron = Xmatrix*Hcur;
        if inputInd == 1
            FinalPred = Pred1Neuron;
        else
            FinalPred = FinalPred+Pred1Neuron;
        end
    end
    
end
