%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis code

% plot difference between movement and target
% find common elements
cpdTarg = wrapAngle(pdTarg(goodCellsTarg & goodCellsMove,:),0);
cpdMove = wrapAngle(pdMove(goodCellsMove & goodCellsTarg,:),0);
dpd = abs(cpdTarg-cpdMove);

for i=1:length(uTimes)
    dpd(dpd(:,i)>pi,i) = -2*pi+dpd(dpd(:,i) > pi,i);
    dpd(dpd(:,i)<-pi,i) = 2*pi+dpd(dpd(:,i) < -pi,i);
end

for i = 1:length(uTimes)
    mdpd(i) = mean(abs(dpd(:,i)));
    sdpd(i) = std(abs(dpd(:,i)));
end

figure;
hold all;
plot(uTimes,mdpd.*180./pi,'rd','LineWidth',2);
plot(uTimes,mdpd.*180./pi,'r','LineWidth',1);
plot(uTimes,(mdpd+sdpd).*180./pi,'r--','LineWidth',1);
plot(uTimes,(mdpd-sdpd).*180./pi,'r--','LineWidth',1);

ylabel('diff');
xlabel('Time After go cue');
title('Difference (for common cells) between movement and target');


% Find significantly tuned cells
pdTarg = wrapAngle(pdTarg(goodCellsTarg,:),0);
pdMove = wrapAngle(pdMove(goodCellsMove,:),0);
pdFullT = wrapAngle(pdFull(goodCellsTarg),0);
pdFullM = wrapAngle(pdFull(goodCellsMove),0);
pdHoldT = wrapAngle(pdHold(goodCellsTarg),0);
pdHoldM = wrapAngle(pdHold(goodCellsMove),0);

% pdFull = wrapAngle(pdFull(goodCells),0);

% add on the hold period
% pdTarg = [pdTarg, pdHold(goodCellsTarg & goodCellsHold)];
% pdMove = [pdMove, pdHold(goodCellsMove & goodCellsHold)];
% uTimes = [uTimes, uTimes(end) + 0.3];

% Make plot showing number of significantly tuned cells over time
% figure;
% hold all;
% plot(uTimes,sum(pT,1),'r','LineWidth',2);
% plot(uTimes,sum(pM,1),'b','LineWidth',2);
% legend({'Target', 'Movement'});
% ylabel('Number of tuned cells');
% xlabel('Time After go cue');
% title('Number of significantly tuned cells over time');



% Make plot showing mean of PDs relative to hold period and full movement
for i = 1:length(uTimes)
    temp1(:,i) = pdTarg(:,i) - pdFullT;
    temp1(temp1(:,i)>pi,i) = -2*pi+temp1(temp1(:,i)>pi,i);
    temp1(temp1(:,i)<-pi,i) = 2*pi-temp1(temp1(:,i)<-pi,i);
    
    temp2(:,i) = pdMove(:,i) - pdFullM;
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


for i = 1:length(uTimes)
    temp1(:,i) = pdTarg(:,i) - pdHoldT;
    temp1(temp1(:,i)>pi,i) = -2*pi+temp1(temp1(:,i)>pi,i);
    temp1(temp1(:,i)<-pi,i) = 2*pi-temp1(temp1(:,i)<-pi,i);
    
    temp2(:,i) = pdMove(:,i) - pdHoldM;
    temp2(temp2(:,i)>pi,i) = 2*pi-temp2(temp2(:,i)>pi,i);
    temp2(temp2(:,i)<-pi,i) = 2*pi-temp2(temp2(:,i)<-pi,i);
end

for i = 1:length(uTimes)
    dpdTarg(i) = mean(temp1(:,i));
    dpdTargS(i) = std(temp1(:,i));
    
    dpdMove(i) = mean(temp2(:,i));
    dpdMoveS(i) = std(temp2(:,i));
end

% % figure;
% % hold all;
% % plot(uTimes,dpdTarg.*180./pi,'rd','LineWidth',2);
% % plot(uTimes,dpdMove.*180./pi,'bd','LineWidth',2);
% % plot(uTimes,dpdTarg.*180./pi,'r','LineWidth',1);
% % plot(uTimes,dpdMove.*180./pi,'b','LineWidth',1);
% % plot(uTimes,(dpdTarg+dpdTargS).*180./pi,'r--','LineWidth',1);
% % plot(uTimes,(dpdMove+dpdMoveS).*180./pi,'b--','LineWidth',1);
% % plot(uTimes,(dpdTarg-dpdTargS).*180./pi,'r--','LineWidth',1);
% % plot(uTimes,(dpdMove-dpdMoveS).*180./pi,'b--','LineWidth',1);
% % 
% % title(['Target: ' num2str(sum(goodCellsTarg)) '; Move: ' num2str(sum(goodCellsMove))]);
% % legend({'Target', 'Movement'});
% % ylabel('Mean PD');
% % xlabel('Time After go cue');
% % title('pds relative to hold periods');

% % % 
% % % % Make plot showing mean PDs over time
% % % figure;
% % % hold all;
% % % for i = 1:length(uTimes)
% % %     mpdTarg(i) = circ_mean(pdTarg(:,i));
% % %     mpdMove(i) = circ_mean(pdMove(:,i));
% % % end
% % % 
% % % plot(uTimes,mpdTarg.*180./pi,'rd','LineWidth',2);
% % % plot(uTimes,mpdMove.*180./pi,'bd','LineWidth',2);
% % % plot(uTimes,mpdTarg.*180./pi,'r','LineWidth',1);
% % % plot(uTimes,mpdMove.*180./pi,'b','LineWidth',1);
% % % 
% % % title(['Target: ' num2str(sum(goodCellsTarg)) '; Move: ' num2str(sum(goodCellsMove))]);
% % % legend({'Target', 'Movement'});
% % % ylabel('Distribution of PD');
% % % xlabel('Time After go cue');
% % % title('circular mean of pd distributions');
% % % 
% % %     
