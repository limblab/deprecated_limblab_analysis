

Y = binnedData.emgdatabin;
X = binnedData.spikeratedata;

Y = HybridFinal.emgdatabin;
X = HybridFinal.spikeratedata;

numlags = 10;
flag= HybridFinal.taskflag; %rows
scale= HybridFinal.scale(12);


%-------------------------
[rX,cX]= size(X); [rY,cY]= size(Y);


x0 = .001*ones(numlags*cX,1);
H = [];
TotalX = [];
for outputInd = 11%:cY
    for inputInd = 1:cX
        rStart = numlags;
        for timeInd = 1:rX-numlags+1
            rInd = rStart-numlags+1:1:rStart;
            Xcur = X(rInd, inputInd);
            Xmatrix(timeInd,:) = Xcur;
            
            
%             flagcur = flag(rInd,1);
%             finalflag = max(flagcur);
            
            
            rStart = rStart+1;
            
            
        end
        Yvector = Y(numlags:end,outputInd);
        TotalX = cat(2,TotalX,Xmatrix);
        

    end
end

        % fun = @(x)(transpose(Yvector-TotalX*x)*(Yvector-TotalX*x));
%         fun = @(x)(flag+(1-flag)*scale)^2.*((Yvector-TotalX*x)'*(Yvector-TotalX*x));
%         H = fminunc(fun,x0);
     

%Test hybrid decoder
FinalPred = [];
Xmatrix = [];
for outputInd = 11%:cY
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


