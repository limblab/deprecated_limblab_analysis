

close all;

holdtime=.5;


j=0;
for i = 1:size(pre.words,1)
    %look for instances of reward (word = 32)
    if pre.words(i,2) == 32
    j=j+1;

    early_time_pre(j) = find(pre.timeframe>pre.words(i,1)-holdtime, 1);
    reward_time_pre(j)= find(pre.timeframe>pre.words(i,1), 1);
    pre_frate_avg(j)=mean(pre.spikeratedata(early_time_pre(j):reward_time_pre(j),neuron));
    pre_force_avg(j)=mean(pre.forcedatabin (early_time_pre(j):reward_time_pre(j),1));
    end
end


k=0;
for i = 1:size(post.words,1)
    %look for instances of reward (word = 32)
    if post.words(i,2) == 32
    k=k+1;

    early_time_post(k) = find(post.timeframe>post.words(i,1)-holdtime, 1);
    reward_time_post(k)= find(post.timeframe>post.words(i,1), 1);
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


