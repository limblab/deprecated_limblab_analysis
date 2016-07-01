function [normpath,aveFR] = ave_trial_paths(binnedData)

%Code taken from CE

targets      = sort(unique(binnedData.trialtable(:,10)));
numtargets   = length(targets);
normpath     = nan(1001,2,8);
aveFR        = nan(1001,8);
successes    = find(binnedData.trialtable(:,9)==double('R'));
ave_duration =  mean(binnedData.trialtable(successes,8)-binnedData.trialtable(successes,7));

for tgt = 1:numtargets
    
    tgt_idx       = find(binnedData.trialtable(:,10)==targets(tgt));
    succ_idx      = intersect(tgt_idx,successes);
    num_succ      = length(succ_idx);
    tmp_paths     = nan(num_succ,1001,2);
    tmp_FR        = nan(num_succ,1001);
        
    for trial = 1:num_succ
%     for trial = 1:num_succ-1    
        
%         %path forth and back
%         binstart = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial  ),1),1,'last');
%         binstop  = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial+1),1),1,'last');

%         %path back, from reward to reward + 1sec
%         binstart = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial  ),8),1,'last');
%         binstop  = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial  ),8)+1,1,'last');
%         
        rawpath  = binnedData.cursorposbin(binstart:binstop,:);
        rawFR    = mean(binnedData.spikeratedata(binstart:binstop,:),2);
        
        numbins  = binstop-binstart;
        binpct   = 0:100/numbins:100;
        tmp_paths(trial,:,:) = interp1(binpct,rawpath,0:0.1:100);
        tmp_FR(trial,:)      = interp1(binpct,rawFR  ,0:0.1:100);
    end
    
    normpath(:,:,tgt) = mean(tmp_paths,1);
    aveFR(:,tgt)      = mean(tmp_FR   ,1);
    
end
end


function plot_avePath_aveFR(normpath,aveFR)
figure;
curs_handle = plot(0,0,'ko');
set(curs_handle,'MarkerSize',6,'MarkerFaceColor','k','MarkerEdgeColor','k');
xlim([-12 12]); ylim([-12 12]);
axis square; axis equal; axis manual; hold on;

figure;
fr_handle = plot(0,0,'b-');
xlim([0 201]); ylim([0 40]);
axis manual; hold on;
pause;

for tgt = 1:8
    for i = 1:201
        cursor_pos = normpath(i,:,tgt);
        set(curs_handle,'XData',cursor_pos(1),'YData',cursor_pos(2));
        set(fr_handle,'XData',1:i,'YData',aveFR(1:i,tgt));
        drawnow;
        pause(0.005)
    end
end
end

% 
% for tgt = 1:8
%     figure; hold on;
%     plot(1:100,normpath(1:100,:,tgt),1:100,aveFR(1:100,tgt));
%     legend('force x','force y','ave FR');
%     title(sprintf('target %d',tgt));
% end
 
% figure; hold on;
% mean_paths = nan(101,2,8);
% 
% for tgt = 1:8
%     tgt_paths  = all_stats{1,1}.normpath{tgt};
%     num_trials = size(tgt_paths,1);
%     num_points = size(tgt_paths{1},1);
%     
%     pathx = nan(num_trials,num_points);
%     pathy = nan(num_trials,num_points);
%     
%     for trial = 1:num_trials
%         pathx(trial,:) = tgt_paths{trial}(:,1);
%         pathy(trial,:) = tgt_paths{trial}(:,2);
%     end
%     
%     mean_paths(:,:,tgt) = [mean(pathx);mean(pathy)]';
%     
%     plot(mean(pathx),mean(pathy));
% end
%     