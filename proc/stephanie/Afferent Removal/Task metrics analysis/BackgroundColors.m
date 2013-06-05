IsoTaskMetrics = IsoTaskMetrics1_blocked_0828;
NumOfTargets = length(IsoTaskMetrics.Time2Target.Time2TargetSummary)-1;


theData = [];
theGroup = [];
for N =1:NumOfTargets
    theData = [theData; IsoTaskMetrics.Time2Target.(['Target' num2str(N)])];
    theGroup = [theGroup; N*ones(length(IsoTaskMetrics.Time2Target.(['Target' num2str(N)])),1)];
end

GroupSize = max(theGroup);

figure; boxplot(theData,theGroup); title('Time to Target')


%Pink rectangle
rectangle('Position',[0,0,5,5],'FaceColor', [1 0.8 .85]);



img = zeros(10,10,3);
img(:,1:GroupSize,2) = 1;
img(:,GroupSize+8:10,3) = 1;
img(:,6:7,3) = 1;
img(:,8:10,2) = 1;
imagesc(img)


% Plot files in a row

for N =1:length(who)
%Time2TargetStruct.Time2TargetSummary(N,1) = mean(Time2TargetStruct.(['Target' num2str(N)])); 
IsoTaskMetrics.Time2Target.Time2TargetSummary(N,1) = mean(IsoTaskMetrics.Time2Target.(['Target' num2str(N)])); 
end

h = subplot(1,4,1);
boxplot(theData,theGroup)
p0 = get(h, 'pos')

h1 = subplot(1,4,2);
boxplot(theData,theGroup2)
p1 = get(h1, 'pos')
%p(1) = 0.45;
%set(h1, 'pos', p);
set(gca, 'YTick', [])

h2 = subplot(1,4,3);
boxplot(theData,theGroup)
p2 = get(h2, 'pos')
set(gca, 'YTick', [])

subplot('Position',[left bottom width height]) 


subplot('Position',[.13 .13 .2 .7]) 
boxplot(theData,theGroup)
set(gca, 'Color', [1 0.81 0.9])
title('Blocked')
subplot('Position',[.33 .13 .2 .7])
boxplot(theData,theGroup)
set(gca, 'YTick', [])
title('Unblocked')
subplot('Position',[.53 .13 .2 .7])
boxplot(theData,theGroup)
set(gca, 'YTick', [])
set(gca, 'Color', [1 0.81 0.9])
title('Blocked')


title('Horizontal Targets - Same Day')
subplot('Position',[.13 .13 .2 .7]) 
boxplot(theData,theGroup)
set(gca, 'Color', [1 0.81 0.9])
title('1')
subplot('Position',[.33 .13 .2 .7])
boxplot(theData,theGroup)
set(gca, 'YTick', [])
title('2')
subplot('Position',[.53 .13 .2 .7])
boxplot(theData,theGroup)
set(gca, 'YTick', [])
set(gca, 'Color', [1 0.81 0.9])
title('3')



