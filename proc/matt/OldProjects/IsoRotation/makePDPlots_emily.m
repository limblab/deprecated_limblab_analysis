%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis code
clear
clc

load('testResults_mid.mat');
pdTargMid = pdTarg;
pdMoveMid = pdMove;
pdFullMid = pdFull;
pdHoldMid = pdHold;
goodCellsTargMid = goodCellsTarg;
goodCellsMoveMid = goodCellsMove;
sgMid = sg;

load('testResults_pron.mat');
pdTargPron = pdTarg;
pdMovePron = pdMove;
goodCellsTargPron = goodCellsTarg;
goodCellsMovePron = goodCellsMove;
sgPron = sg;

% find commonalities in spike guide
sg = intersect(sgMid,sgPron,'rows');

[~,~,im] = intersect(sg,sgMid,'rows');

[~,~,ip] = intersect(sg,sgPron,'rows');

indsMid = zeros(size(goodCellsTargMid));
indsMid(im) = 1;
indsMid = logical(indsMid);

indsPron = zeros(size(goodCellsTargPron));
indsPron(ip) = 1;
indsPron = logical(indsPron);

pdTargMid = pdTargMid(indsMid,:);
pdMoveMid = pdMoveMid(indsMid,:);
pdFullMid = pdFullMid(indsMid,:);
pdHoldMid = pdHoldMid(indsMid,:);
goodCellsTargMid = goodCellsTargMid(indsMid,:);
goodCellsMoveMid = goodCellsMoveMid(indsMid,:);
sgMid = sgMid(indsMid,:);

pdTargPron = pdTargPron(indsPron,:);
pdMovePron = pdMovePron(indsPron,:);
goodCellsTargPron = goodCellsTargPron(indsPron,:);
goodCellsMovePron = goodCellsMovePron(indsPron,:);
sgPron = sgPron(indsPron,:);


goodCellsTarg = goodCellsTargMid & goodCellsTargPron;
goodCellsMove = goodCellsMoveMid & goodCellsMovePron;

% Find significantly tuned cells
pdTargMid = wrapAngle(pdTargMid(goodCellsTarg,:),0);
pdMoveMid = wrapAngle(pdMoveMid(goodCellsMove,:),0);

pdTargPron = wrapAngle(pdTargPron(goodCellsTarg,:),0);
pdMovePron = wrapAngle(pdMovePron(goodCellsMove,:),0);

% Make plot showing mean of PDs relative to hold period and full movement
for i = 1:length(uTimes)
    temp1(:,i) = pdTargMid(:,i) - pdTargPron(:,i);
    temp1(temp1(:,i)>pi,i) = -2*pi+temp1(temp1(:,i)>pi,i);
    temp1(temp1(:,i)<-pi,i) = 2*pi-temp1(temp1(:,i)<-pi,i);
    
    temp2(:,i) = pdMoveMid(:,i) - pdMovePron(:,i);
    temp2(temp2(:,i)>pi,i) = 2*pi-temp2(temp2(:,i)>pi,i);
    temp2(temp2(:,i)<-pi,i) = 2*pi-temp2(temp2(:,i)<-pi,i);
end

for i = 1:length(uTimes)
    dpdTarg(i) = mean(temp1(:,i));
    dpdTargS(i) = std(temp1(:,i));
    
    dpdMove(i) = mean(temp2(:,i));
    dpdMoveS(i) = std(temp2(:,i));
end

figure;
hold all;
plot(uTimes,dpdTarg.*180./pi,'rd','LineWidth',2);
plot(uTimes,dpdMove.*180./pi,'bd','LineWidth',2);
plot(uTimes,dpdTarg.*180./pi,'r','LineWidth',1);
plot(uTimes,dpdMove.*180./pi,'b','LineWidth',1);
plot(uTimes,(dpdTarg+dpdTargS).*180./pi,'r--','LineWidth',1);
plot(uTimes,(dpdMove+dpdMoveS).*180./pi,'b--','LineWidth',1);
plot(uTimes,(dpdTarg-dpdTargS).*180./pi,'r--','LineWidth',1);
plot(uTimes,(dpdMove-dpdMoveS).*180./pi,'b--','LineWidth',1);

title(['Target: ' num2str(sum(goodCellsTarg)) '; Move: ' num2str(sum(goodCellsMove))]);
legend({'Target', 'Movement'});
ylabel('Mean PD');
xlabel('Time After go cue');
title('pds relative to full movement periods');


