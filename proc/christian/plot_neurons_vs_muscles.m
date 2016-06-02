function [reg1,reg2] = plot_neurons_vs_muscles(binnedData1,binnedData2,lag)

AveFR1 = mean(binnedData1.spikeratedata,2);
AveFR2 = mean(binnedData2.spikeratedata,2);

[numPts1,numEMGs]  = size(binnedData1.emgdatabin);
numPts2 = size(binnedData2.emgdatabin,1);

% B1     = zeros(numEMGs+1,1);
% BINT1  = zeros(numEMGs+1,2);
% R1     = zeros(numPts1,numEMGs);
% RINT1  = zeros(numPts1,numEMGs,2);
% STATS1 = zeros(numEMGs,4);
% 
% B2     = B1;
% BINT2  = BINT1;
% R2     = zeros(numPts2,numEMGs);
% RINT2  = zeros(numPts2,numEMGs,2);
% STATS2 = STATS1;

% [B1,BINT1,R1,RINT1,STATS1] = regress(binnedData1.emgdatabin(lag+1:end,:), [AveFR1(1:end-lag) ones(numPts1-lag,1)]);
% [B2,BINT2,R2,RINT2,STATS2] = regress(binnedData2.emgdatabin(lag+1:end,:), [AveFR2(1:end-lag) ones(numPts2-lag,1)]);

% bin data:
AveFR1_b = (1:100)';
AveFR2_b = (1:100)';

EMG1_b = zeros(100,numEMGs);
EMG2_b = zeros(100,numEMGs);

for i = 1:100
    idx1 = [zeros(lag,1); AveFR1 >= i-1 & AveFR1 < i];
    idx1 = logical(idx1(1:end-lag));
    idx2 = [zeros(lag,1); AveFR2 >= i-1 & AveFR2 < i];
    idx2 = logical(idx2(1:end-lag));

    EMG1_b(i,:) = mean(binnedData1.emgdatabin(idx1,:));
    EMG2_b(i,:) = mean(binnedData2.emgdatabin(idx2,:));
end

for i = 1:numEMGs
    figure;
    plot(AveFR1_b,EMG1_b(:,i),'b.');
    hold on;
    plot(AveFR2_b,EMG2_b(:,i),'g.');
    [B1,BINT1,R1,RINT1,STATS1] = regress(EMG1_b(:,i), [AveFR1_b ones(100,1)]);
    [B2,BINT2,R2,RINT2,STATS2] = regress(EMG2_b(:,i), [AveFR2_b ones(100,1)]);

    plot(AveFR1(1:end-lag),B1(1)*AveFR1(1:end-lag)+B1(2),'b-');
    plot(AveFR2(1:end-lag),B2(1)*AveFR2(1:end-lag)+B2(2),'g-');
end

% 
% for i = 1:numEMGs
%     figure;
%     plot(AveFR1(1:end-lag),binnedData1.emgdatabin(lag+1:end,i),'b.');
%     hold on;
%     plot(AveFR2(1:end-lag),binnedData2.emgdatabin(lag+1:end,i),'g.');
%     [B1,BINT1,R1,RINT1,STATS1] = regress(binnedData1.emgdatabin(lag+1:end,i), [AveFR1(1:end-lag) ones(numPts1-lag,1)]);
%     [B2,BINT2,R2,RINT2,STATS2] = regress(binnedData2.emgdatabin(lag+1:end,i), [AveFR2(1:end-lag) ones(numPts2-lag,1)]);
% 
%     plot(AveFR1(1:end-lag),B1(1)*AveFR1(1:end-lag),'b-');
%     plot(AveFR2(1:end-lag),B2(1)*AveFR2(1:end-lag),'g-');
% end

reg1 = struct('B',B1,'BINT',BINT1,'R',R1,'RINT',RINT1,'STATS',STATS1);
reg2 = struct('B',B2,'BINT',BINT2,'R',R2,'RINT',RINT2,'STATS',STATS2);