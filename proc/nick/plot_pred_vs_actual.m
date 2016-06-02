state_col = 1;
monkey = 'M';
date = '4/9/2012';

figure
if size(binnedData.velocbin) == size(OLPredData.preddatabin)
    plot(binnedData.velocbin(binnedData.states(:,state_col)==1,1),OLPredData.preddatabin(binnedData.states(:,state_col)==1,1),'.')
    hold on
    plot(binnedData.velocbin(binnedData.states(:,state_col)==0,1),OLPredData.preddatabin(binnedData.states(:,state_col)==0,1),'.g')
else
    plot(binnedData.velocbin(10:end,1),OLPredData.preddatabin(:,1),'.')
    hold on
end
plot([-60 60],[-60,60],'r')
axis([-60 60 -60 60])
title(['X Velocity for Monkey ' monkey ' on ' date])
xlabel('Actual Velocity (cm/s)')
ylabel('Predicted Velocity (cm/s)')

figure
if size(binnedData.velocbin) == size(OLPredData.preddatabin)
    plot(binnedData.velocbin(binnedData.states(:,state_col)==1,2),OLPredData.preddatabin(binnedData.states(:,state_col)==1,2),'.')
    hold on
    plot(binnedData.velocbin(binnedData.states(:,state_col)==0,2),OLPredData.preddatabin(binnedData.states(:,state_col)==0,2),'.g')
else
    plot(binnedData.velocbin(10:end,2),OLPredData.preddatabin(:,2),'.')
    hold on
end
plot([-60 60],[-60,60],'r')
axis([-60 60 -60 60])
title(['Y Velocity for Monkey ' monkey ' on ' date])
xlabel('Actual Velocity (cm/s)')
ylabel('Predicted Velocity (cm/s)')    