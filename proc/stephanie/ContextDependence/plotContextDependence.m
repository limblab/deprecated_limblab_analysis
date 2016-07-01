% 
% [MeanTrialForce2 MeanTrialSpikeRate2 MeanCenterForce2 MeanCenterSpikeRate2 SortedUnitIndices2] = ContextDependenceWithBDF3(out_struct_2s);
% [MeanTrialForce3 MeanTrialSpikeRate3 MeanCenterForce3 MeanCenterSpikeRate3 SortedUnitIndices3] = ContextDependenceWithBDF3(out_struct_3s);
% [MeanTrialForce2again MeanTrialSpikeRate2again MeanCenterForce2again MeanCenterSpikeRate2again SortedUnitIndices2again] = ContextDependenceWithBDF3(out_struct_2s_again);
% [MeanTrialForce3again MeanTrialSpikeRate3again MeanCenterForce3again MeanCenterSpikeRate3again SortedUnitIndices3again] = ContextDependenceWithBDF3(out_struct_3s_again);

%-------------------------------------------------------------------

% for c = 1%:100
%     slopeandint(c,:) = polyfit(MeanTrialForce(:,1),MeanTrialSpikeRate(:,c),1); 
% end

% Plot average force (x) versus average firing rate (y)
for cell  = 1:length(MeanCenterSpikeRate2(1,:))
    
    % Get the max yvalue for plotting purposes
    ymax(1) = max(max(MeanCenterSpikeRate2(:,cell)),max(MeanTrialSpikeRate2(:,cell)));
    ymax(2) = max(max(MeanCenterSpikeRate3(:,cell)),max(MeanTrialSpikeRate3(:,cell)));
    ymax(3) = max(max(MeanCenterSpikeRate2again(:,cell)),max(MeanTrialSpikeRate2again(:,cell)));
    ymaxAll = max(ymax); 
    
    
    figure
    h1 = subplot(1,3,1);
    plot(MeanTrialForce2(:,1),MeanTrialSpikeRate2(:,cell),'b*');
    hold on
    xlabel('Force')
    ylabel('Firing rate (spikes/second)')
    plot(MeanCenterForce2(:,1),MeanCenterSpikeRate2(:,cell),'c*');
    
    % Fit a line to the plot - 2 levels
    modelVars = polyfit(MeanTrialForce2(:,1),MeanTrialSpikeRate2(:,cell),1); % least squares fitting to a line
    yint = modelVars(2); % y-intercept of the fitted line
    slope = modelVars(1); % slope of fitted lines
    fit = yint+slope*MeanTrialForce2(:,1);
    plot(MeanTrialForce2(:,1),fit,'k')
    text(5, ymaxAll, ['Slope =  ',num2str(slope)],'FontSize', 10)
    

% Plot average force (x) versus average firing rate (y)

    h2 = subplot(1,3,2);
    plot(MeanTrialForce3(:,1),MeanTrialSpikeRate3(:,cell),'b*');
    hold on
    %plot(MeanTrialForce3(1:18,1),MeanTrialSpikeRate3(1:18,cell),'g*');
    %plot(MeanTrialForce3(200:218,1),MeanTrialSpikeRate3(215:233,cell),'r*');
    xlabel('Force')
    ylabel('Firing rate (spikes/second)')
    plot(MeanCenterForce3(:,1),MeanCenterSpikeRate3(:,cell),'c*');
    title(['Cell' num2str(cell)])
  
    % Isolate the TwoLevel data from the entire set
ThreeLevelIndices = find(MeanTrialForce3(:,2) == 3);
TwoLevelMeanTrialForce = MeanTrialForce3; TwoLevelMeanTrialSpikeRate = MeanTrialSpikeRate3;
TwoLevelMeanTrialForce(ThreeLevelIndices,:) = [];
TwoLevelMeanTrialSpikeRate(ThreeLevelIndices,:) = [];

% Fit a line to the plot - 3 levels
modelVars = polyfit(TwoLevelMeanTrialForce(:,1),TwoLevelMeanTrialSpikeRate(:,cell),1); % least squares fitting to a line
yint = modelVars(2); % y-intercept of the fitted line
slope = modelVars(1); % slope of fitted lines
fit = yint+slope*TwoLevelMeanTrialForce(:,1);
plot(TwoLevelMeanTrialForce(:,1),fit,'k')
text(5, ymaxAll, ['Slope =  ',num2str(slope)],'FontSize', 10)

    
% Plot average force (x) versus average firing rate (y)

    h3 = subplot(1,3,3);
    plot(MeanTrialForce2again(:,1),MeanTrialSpikeRate2again(:,cell),'b*');
    hold on
    %plot(MeanTrialForce2again(1:18,1),MeanTrialSpikeRate2again(1:18,cell),'g*');
    %plot(MeanTrialForce2again(200:218,1),MeanTrialSpikeRate2again(200:218,cell),'r*');
    xlabel('Force')
    ylabel('Firing rate (spikes/second)')
    plot(MeanCenterForce2again(:,1),MeanCenterSpikeRate2again(:,cell),'c*')
    
    % Fit a line to the plot - 2 levels
    modelVars = polyfit(MeanTrialForce2again(:,1),MeanTrialSpikeRate2again(:,cell),1); % least squares fitting to a line
    yint = modelVars(2); % y-intercept of the fitted line
    slope = modelVars(1); % slope of fitted lines
    fit = yint+slope*MeanTrialForce2again(:,1);
    plot(MeanTrialForce2again(:,1),fit,'k')
    text(5, ymaxAll, ['Slope =  ',num2str(slope)],'FontSize', 10)
    
    
    
    % Plot all subplots on the same axis 
    linkaxes([h2 h1 h3],'xy')
    set([h1 h2 h3],'YLim',([0 ymaxAll+5]));
    
    
 %pause
end



% 
% 
% 

% 
% % Fit a line to the plot - First two levels
% % modelVars = polyfit(TwoLevelMeanTrialForce(:,1),TwoLevelMeanTrialSpikeRate(:,cell),1); % least squares fitting to a line
% % yint = modelVars(2) % y-intercept of the fitted line
% % slope = modelVars(1) % slope of fitted lines
% % fit = yint+slope*TwoLevelMeanTrialForce(:,1);
% % plot(TwoLevelMeanTrialForce(:,1),fit,'c')
% % text(400, 20, ['Slope =  ',num2str(slope)],'FontSize', 10)
% % xlim([150 550])
% % ylim([0 25])