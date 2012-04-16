% SCtrain   = spike count neuron 1 -> training data
% SCtest    = spike count neuron 1 -> test data
% NXSCtrain = spike count neurons 2:49 ->training data
% NXSCtest  = spike count neurons 2:49 ->test data

numNeur = size(testData.spikeratedata,2);
% sliding window of correlation coefficient every 5 min
corrWindow = 6000; %5min = 6000 bins
numpts     = length(testData.timeframe);
numSteps   = floor(numpts/corrWindow);

B = zeros(numNeur);
Results   = NaN(numSteps,numNeur);
CheckTimes = zeros(numSteps,1);

for n = 1:numNeur
    if n > 1
        toc;
    end
    disp(sprintf('Channel %d of %d',n,numNeur));
    tic;
    
    N1SCtrain = trainData.spikeratedata(:,n)/20;
    N1SCtest  = testData.spikeratedata(:,n)/20;

    if n==1
        otherNs = 2:numNeur;
    elseif n==numNeur
        otherNs = 1:numNeur-1;
    else
        otherNs = [1:n-1 n+1:numNeur];
    end
    
    NXSCtrain = trainData.spikeratedata(:,otherNs)/20;
    NXSCtest = testData.spikeratedata(:,otherNs)/20;

    B(:,n) = glmfit(NXSCtrain, N1SCtrain,'poisson');
    [YHat] = glmval(B(:,n),NXSCtest,'log');
    
%     [B,Dev,Stats] = glmfit(NXSCtrain, N1SCtrain,'poisson');
%     [YHat,YLo,YHi] = glmval(B,NXSCtest,'log',Stats);

    %Calculate correlation between pred and actual spike count for this neuron
    for i= 1:numSteps
        stop  = i*corrWindow;
        start = stop - corrWindow +1;
        CheckTimes(i,1) = stop;
        Results(i,n) = CalculateR2(YHat(start:stop,:),N1SCtest(start:stop,:));
%         AllVafs(i,n)= 1 - sum( (YHat(start:stop,:) - N1SCtest(start:stop,:)).^2) ./ sum( (N1SCtest(start:stop,:) - repmat(mean(N1SCtest(start:stop,:)),corrWindow,1)).^2);
    end
% 
%     figure;
%     x1 = (1:numpts)*0.05;
%     y1 = [N1SCtest YHat];
%     x2 = VafsTimes(:,1)*0.05;
%     y2 = AllVafs(:,n);
% 
%     [ax,hL,hR]=plotyy(x1,y1,x2,y2);
% 
%     set(hL(1),'Color','k','LineWidth',1.5);
%     set(hL(2),'Color','r','LineWidth',1.5);
%     set(hR,'Color','b','LineWidth',2);
%     set(ax(2),'YColor','b');
% 
%     legend('Actual Spike Count','GLM prediction');
% 
%     axes(ax(1)); xlabel('Time(s)');ylabel('Spikes/Bin'); ylim([-1 15]);
%     axes(ax(2)); ylabel('vaf over last 2 min'); ylim([-1 1]);
%     title(sprintf('Neuron %d', n));
%     pause(1);

end
toc;