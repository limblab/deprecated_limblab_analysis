function [Hback Hfilter] = backslash(binnedData,numlags,emgInd)

Y = binnedData.emgdatabin;
X = binnedData.spikeratedata;

scale = binnedData.scale(emgInd);

[rX,cX]= size(X); [rY,cY]= size(Y);
%x0 = .001*ones(numlags*cX,1);
H = [];
TotalX = [];
for outputInd = emgInd%:cY
    for inputInd = 1:cX
        rStart = numlags;
        for timeInd = 1:rX-numlags+1
            rInd = rStart-numlags+1:1:rStart;
            Xcur = X(rInd, inputInd);
            Xmatrix(timeInd,:) = Xcur;
            
            rStart = rStart+1;
                     
        end
        Yvector = Y(numlags:end,outputInd);
        TotalX = cat(2,TotalX,Xmatrix);
        

    end
end

TotalX = scale*TotalX;
Yvector = scale.*Yvector;
flag = binnedData.taskflag(1:length(Yvector),1);

Hback = TotalX\Yvector;
Hfilter = filMIMO4(TotalX,Yvector,numlags,1,1);



end