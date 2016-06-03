function [] = plotMovements(bdf, tt, stimCycle)
% plotMovements -
%
%
% INPUT:
%
% OUTPUT:
%
% Created by John W. Miller
% 2014-08-27
%
%%

% Event times from trial table
goCues  = tt(:,4); % Time stamps (sec) of go_cues 4 = GoCue
cueMask = separateStimBlocks_2(goCues,stimCycle);

% Position data from 'bdf'
movementTime  = bdf.pos(:,1);
movementMask  = separateStimBlocks_2(movementTime,stimCycle); % Split into stim blocks
n_blocks = size(movementMask,2);


%% Position
% Plot positions, colored according to stim. blocks
if 0
yOffset = -32.5;
positions = bdf.pos; % [time ; xPos ; yPos]
positions(:,3) = positions(:,3) - yOffset;
figure; hold on;
colors = [1 0 0; 0 1 0; 0 0 1];
for iBlock = 1:n_blocks
    iMask = movementMask(:,iBlock);
    iTime = positions(iMask,1);
    iXpos = positions(iMask,2);
    iYpos = positions(iMask,3);
    sqrPos = sqrt(power(iXpos,2)+power(iYpos,2));
%     plot(iTime,sqrPos,'Color',colors(:,iBlock))
    plot(iXpos,iYpos,'Color',colors(:,iBlock))
%     plot(iTime,iYpos,'Color',colors(:,iBlock))
end
end
%% Speed
if 0
velocity = bdf.vel;
speed = sqrt(power(velocity(:,2),2) + power(velocity(:,3),2)); % Convert x & y velocity to speed

% Time,frequency,etc.
sampleInterval = 0.001; % sec
pre = 2; post = 2; % seconds
window = -pre:sampleInterval:(post);
rate = 1/sampleInterval;
avgSpeed = zeros((pre+post)*rate + 1,n_blocks);

figure; hold on;
colors = [0 0 1; 0 1 0; 1 0 0];
for iBlock = 1:n_blocks
    cuesInBlock   = goCues(cueMask(:,iBlock));
    timesInBlock  = movementTime(movementMask(:,iBlock));
    speedsInBlock = speed(movementMask(:,iBlock));
    clear('curSpeed','maxSpeed');
    color = colors(:,iBlock);
    
    n_cues = 0;
    for ii = 1:length(cuesInBlock)-2
        iCue = cuesInBlock(ii);
        if isfinite(iCue)
            timeIdx   = find(timesInBlock>iCue,1,'first');
            speedIdxs = (timeIdx-pre*rate):(timeIdx+post*rate);
            [~,idx]  = max(speedsInBlock(speedIdxs));
            
            if idx > rate*pre && idx < (rate*post+80)
                n_cues = n_cues+1;
                curSpeed(:,n_cues)  = speedsInBlock(speedIdxs);
                peakWindow = (idx-20):(idx+20);
                maxSpeed(:,n_cues)  = mean(curSpeed(peakWindow,n_cues));
            else
                n_cues = n_cues - 1;if n_cues<0;n_cues=1;end;
            end
        end
    end
    avgSpeed(:,iBlock) = mean(curSpeed,2);
    stdDev(:,iBlock)   = std(maxSpeed);
    stdErr(1,iBlock)   = stdDev(1,iBlock)/sqrt(n_cues);
    errorBars(:,iBlock) = stdDev(:,iBlock);

        % Plot error
    as = avgSpeed(:,iBlock); eb = errorBars(:,iBlock);
    X = [window fliplr(window)];
    Y = [as'+eb', fliplr(as'-eb')];
    patch(X,Y,color','FaceAlpha',0.25,'EdgeAlpha',0);
    
end
plot(window,avgSpeed) % Plot average speed for each block
ymax = max(max(avgSpeed))*1.5; ymin = -4;% Mark the time of go_cue
line('XData',[0 0], 'YData',[ymin ymax],'LineStyle', '-','Color','k');ylim([ymin ymax]);

% Label the plot
fs = 20;
bdfname = inputname(1);bdfname=bdfname(4:end);
xlabel('Time (sec)','FontSize',fs)
ylabel('Speed ','FontSize',fs)
plot_title = sprintf('Handle speed at time of Go Cue \nDay: %s  ',bdfname);
title(plot_title,'FontSize',fs+2)
end

%% Hold times
if 1
holdTimes = tt(:,3)-1;
holdMask  = separateStimBlocks_2(holdTimes,stimCycle);
n_blocks  = size(holdMask,2);


movementTime  = bdf.pos(:,1);
yOffset = -32.5;
xPos = bdf.pos(:,2);
yPos = bdf.pos(:,3) - yOffset;

velocity = bdf.vel;
speed = sqrt(power(velocity(:,2),2) + power(velocity(:,3),2)); % Convert x & y velocity to speed

% Time,frequency,etc.
sampleInterval = 0.001; % sec
pre = 0; post = .5; % seconds
window = -pre:sampleInterval:(post);
rate = 1/sampleInterval;
avgSpeed = zeros((pre+post)*rate + 1,n_blocks);

figure; hold on;
colors = [0 0 1; 0 1 0; 1 0 0];
for iBlock = 1:n_blocks
    cuesInBlock   = holdTimes(holdMask(:,iBlock));
    color = colors(:,iBlock);

    for n_cue = 1:length(cuesInBlock)
        if isfinite(cuesInBlock(n_cue))
           cueTime = cuesInBlock(n_cue);
           cueIdx  = floor(cueTime*rate);
           window  = (cueIdx-pre*rate):(cueIdx+post*rate);
           
           X = movementTime(window) - cueTime;
           Y = speed(window);
           
           plot(X,Y,'Color',color)
% %            xlim([-pre post])

%             plot(xPos(window(1)),yPos(window(1)),'ko')
%             plot(xPos(window),yPos(window),'Color',color)


           
        end 
    end
%     line('XData',[0 0], 'YData',[0 35],'LineStyle', '-','Color','k');ylim([0 35]);

end









%%
end