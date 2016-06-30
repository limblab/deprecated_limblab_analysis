function thetaMove = getMoveAngles(force, ints, angSize, thetaTarg, trialTable)

thetaMove = zeros(size(ints,1),1);
for iTrial = 1:size(ints,1)
    relInds = [find(force(:,1) > ints(iTrial,1),1,'first')  find(force(:,1) <= ints(iTrial,2),1,'last')];
    
    relForce = force(relInds(1):relInds(2),2:3);
    %                 ttt = relForce;
    %                 clear relForce
    %                 % Maybe I can heavily low pass filter relForce?
    %                 windowSize = 50;
    %                 relForce(:,1) = conv(ttt(:,1),ones(windowSize,1)/windowSize,'valid');
    %                 relForce(:,2) = conv(ttt(:,2),ones(windowSize,1)/windowSize,'valid');
    
    %         temp = polyfit(relForce(:,1),relForce(:,2),1);
    %         x1 = temp(1)+temp(2).*relForce(1,1);
    %         x2 = temp(1)+temp(2).*relForce(end,1);
    %         y1 = temp(1)+temp(2).*relForce(1,2);
    %         y2 = temp(1)+temp(2).*relForce(end,2);
    %         thetaMove(iTrial) = atan2(y2-y1,x2-x1);
    thetaMove(iTrial) = atan2(relForce(end,2)-relForce(1,2),relForce(end,1)-relForce(1,1));

    %         % I need to do some sanity checks...
    if 0 && nargin > 3
        figure;
        hold all;
        %         plot(ttt(:,1),ttt(:,2),'k')
        plot(relForce(:,1),relForce(:,2),'b');
        d = sqrt((relForce(end,1)-relForce(1,1)).^2 + (relForce(end,2)-relForce(1,2)).^2);
        plot([relForce(1,1), relForce(1,1)+d*cos(thetaMove(iTrial))],[relForce(1,2), relForce(1,2)+d*sin(thetaMove(iTrial))],'r')
        plot([relForce(1,1), relForce(1,1)+d*cos(thetaTarg(iTrial))],[relForce(1,2), relForce(1,2)+d*sin(thetaTarg(iTrial))],'k')
        plot(relForce(1,1),relForce(1,2),'rd','LineWidth',3);
        title(['npoints = ' num2str(size(relForce,1))]);
        pause;
        close all
    end
end

% Put into bins
thetaMove = round(thetaMove./angSize).*angSize;
thetaMove = wrapAngle(thetaMove,0); % make sure it goes from [-pi,pi)