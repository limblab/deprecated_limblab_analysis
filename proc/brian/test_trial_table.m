function test_trial_table(bdf)
% TEST_TRIAL_TABLE
%
% TEST_TRIAL_TABLE(BDF) displays a graph with the speed profile for the 
% movement of  every successful trial in a center out file.  This is used
% to validate the movement detection code.

close all;
tic;
tt = co_trial_table(bdf);
toc;


holdtrials = tt( tt(:,3) == double('H'), : );
delaytrials = tt( tt(:,3) == double('D') & tt(:,10) == double('R'), : );
nobumptrials = tt( tt(:,3) == -1 & tt(:,10) == double('R'), : );

% goodtrials = tt( tt(:,3) == double('H') | tt(:,10) == double('R'), :);
% for tid = 1:size(goodtrials,1)
%      sidx = find(bdf.vel(:,1) > nobumptrials(tid,1),1,'first'):find(bdf.vel(:,1) > nobumptrials(tid,9)+1,1,'first');
%      
%      initial_pos = bdf.pos(sidx(1000),[2 3]);
%      
%      t = bdf.vel(sidx,1);
%      s = sqrt(bdf.vel(sidx,2).^2 + bdf.vel(sidx,3).^2);
%      p = sqrt((bdf.pos(sidx,2)-initial_pos(1)).^2 + (bdf.pos(sidx,3)-initial_pos(2)).^2);
% 
%      
%     figure; hold on;
%     plot(t,s,'k-');
%     plot(t,p,'b-');
%     plot(delaytrials(tid,4), -1, 'g^', 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [0 1 0]);
%     plot(delaytrials(tid,9), -1, 'r^', 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]);   
%     plot(delaytrials(tid,8), -1, 'b^', 'MarkerFaceColor', 'none',  'MarkerEdgeColor', [0 0 1]);    
% end

%
% Hold Period Bumps 
%
for tid = 1:size(holdtrials,1)
    sidx = find(bdf.vel(:,1) > holdtrials(tid,1),1,'first'):find(bdf.vel(:,1) > holdtrials(tid,9)+1,1,'first');
    
    initial_pos = bdf.pos(sidx(1000),[2 3]);
    
    t = bdf.vel(sidx,1);
    s = sqrt(bdf.vel(sidx,2).^2 + bdf.vel(sidx,3).^2);
    p = sqrt((bdf.pos(sidx,2)-initial_pos(1)).^2 + (bdf.pos(sidx,3)-initial_pos(2)).^2);
        
    figure; hold on;
    plot(t,s,'k-');
    plot(t,p,'b-');
    plot(holdtrials(tid,4), -1, 'g^', 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [0 1 0]);
    plot(holdtrials(tid,9), -1, 'r^', 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]);    
    plot(holdtrials(tid,8), -1, 'b^', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0 0 1]);  
    
    axis([t(1) t(end) -2 30]);
    title(sprintf('%d: %s-%s', tid, 'H', 'N'));
end

%
% Delay Period Bumps 
%
for tid = 1:size(holdtrials,1)
    sidx = find(bdf.vel(:,1) > delaytrials(tid,1),1,'first'):find(bdf.vel(:,1) > delaytrials(tid,9)+1,1,'first');
    
    initial_pos = bdf.pos(sidx(1000),[2 3]);
    
    t = bdf.vel(sidx,1);
    s = sqrt(bdf.vel(sidx,2).^2 + bdf.vel(sidx,3).^2);
    p = sqrt((bdf.pos(sidx,2)-initial_pos(1)).^2 + (bdf.pos(sidx,3)-initial_pos(2)).^2);
        

    figure; hold on;
    plot(t,s,'k-');
    plot(t,p,'b-');
    plot(delaytrials(tid,4), -1, 'g^', 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [0 1 0]);
    plot(delaytrials(tid,9), -1, 'r^', 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]);   
    plot(delaytrials(tid,8), -1, 'b^', 'MarkerFaceColor', 'none',  'MarkerEdgeColor', [0 0 1]);    
    
    axis([t(1) t(end) -2 30]);
    title(sprintf( '%d: %s-%s', tid, 'D', char(delaytrials(tid,10)) ));
end

%
% Un-bumped Reaches 
%
for tid = 1:size(holdtrials,1)
    sidx = find(bdf.vel(:,1) > nobumptrials(tid,1),1,'first'):find(bdf.vel(:,1) > nobumptrials(tid,9)+1,1,'first');
    
    initial_pos = bdf.pos(sidx(1000),[2 3]);
    
    t = bdf.vel(sidx,1);
    s = sqrt(bdf.vel(sidx,2).^2 + bdf.vel(sidx,3).^2);
    p = sqrt((bdf.pos(sidx,2)-initial_pos(1)).^2 + (bdf.pos(sidx,3)-initial_pos(2)).^2);
    
    %d = [0; diff(smooth(s,100))*25];
    %dd = [diff(smooth(d,100)); 0];
    %peaks = dd(1:end-1)>0 & dd(2:end)<0;
    %mvt_peak = find(peaks & t(2:end) > nobumptrials(tid,7) & d(2:end) > 1, 1, 'first');
    %thresh = d(mvt_peak)/2;
    %onset = t(find(d<thresh & t<t(mvt_peak),1,'last'));
    
    figure; hold on;
    plot(t,s,'k-');
    plot(t,p,'b-');
    %plot(t,d+15,'r-');
    plot(nobumptrials(tid,7), -1, 'g^', 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [0 1 0]);
    plot(nobumptrials(tid,9), -1, 'r^', 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]);    
    plot(nobumptrials(tid,8), -1, 'b^', 'MarkerFaceColor', 'none',  'MarkerEdgeColor', [0 0 1]);    
    
    %line([t(1) t(end)], [thresh+15 thresh+15], 'Color', [0 0 0]);
    %line([onset onset], [0 30], 'Color', [0 0 0]);    
    %line([t(mvt_peak) t(mvt_peak)], [0 30], 'Color', [0 0 0]);    
    
    axis([t(1) t(end) -2 30]);
    title(sprintf( '%d: %s-%s', tid, 'N', char(nobumptrials(tid,10)) ));
end




