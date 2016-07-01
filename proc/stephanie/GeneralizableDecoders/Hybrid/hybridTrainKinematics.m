


%HybridTrain
function [H timerun] = hybridTrainKinematics(binnedData, numlags, emgInd)


Y = binnedData.cursorposbin;
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

flag = binnedData.taskflag(1:length(Yvector),1);


tic
options = optimset('GradObj','on');
w_best = (TotalX'*TotalX)\TotalX'*Yvector;
%w_best = .001*ones(numlags*cX,1);
[H] = fminunc(@(h) hybrid_cost(h,flag,scale,Yvector,TotalX),w_best,options);
timerun = toc;
timerun = timerun/60;
