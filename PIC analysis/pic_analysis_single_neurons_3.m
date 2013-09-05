

close all;

holdtime=.5;



%PRE DRUG DATA

%find indices in pre.timestamps of time of successful holdtime onsets and rewards 
pre_starthold_indx  = find(pre.timeframe>pre.words(pre.words(:,2)==32,1)-holdtime, 1);
pre_rewardtime_indx = find(pre.timeframe>pre.words(pre.words(:,2)==32,1), 1);

%find which target (1-8)
for i = 1:length(pre_rewardtime_indx)
    index = pre_rewardtime_indx(i);
    target(i) = pre.words(find(pre.words(1:index,2) > 63 & pre.words(1:index,2) < 73,1,'last'),2)-63;
end

%average firing rate and force for each successful trial
%STILL NEED TO FIGURE OUT THIS PART (TARGET(:))
pre_frate_avg(:,target(:))=mean(pre.spikeratedata(pre_starthold_indx:pre_rewardtime_indx(:),neuron));
pre_force_avg(:)=mean(pre.forcedatabin (pre_starthold_indx:pre_rewardtime_indx(:));


%POST DRUG DATA
k=0;
for i = 1:size(post.words,1)
    %look for instances of reward (word = 32)
    if post.words(i,2) == 32
    k=k+1;

    early_time_post(k) = find(post.timeframe>post.words(i,1)-holdtime, 1);
    reward_time_post(k)= find(post.timeframe>post.words(i,1), 1); %time of reward (in index from post.timestamp)
    post_frate_avg(k)=mean(post.spikeratedata(early_time_post(k):reward_time_post(k),neuron));
    post_force_avg(k)=mean(post.forcedatabin (early_time_post(k):reward_time_post(k),1));
    end
end  

clear i j k

%% graphs and figures

figure
 hold on
 plot(pre_force_avg, pre_frate_avg, 'b.');
 plot(post_force_avg, post_frate_avg, 'r.');
 legend('pre caff', 'post caff')
 hold off


