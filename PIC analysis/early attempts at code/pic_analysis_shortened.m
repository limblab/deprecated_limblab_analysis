%this code should create vectors containing the average values of
%predicted position data for 0.8 seconds before each reward. It then
%compares the vector for the preD_preF predictions with the vector for the
%preD_postF predictions

%holdtime is length of time before rewards that I include in average
holdtime=0.8;


wt=0;
for i = 1:size(pre_caff_bdf.words,1)

    %averaging each timeframe before a reward (when word=32) AND 
    if pre_caff_bdf.words(i,2) == 32 & 
        %when there is still data to analyze (mfx timeframe is shorter??)
        pre_caff_bdf.words(i,1)< preD_preF.timeframe(end) 

    wt=wt+1;
    
    %each value is the average absolute value of position values...
    within_avgx(wt)=mean(abs(preD_preF.preddatabin(
        %from o.8 seconds before the time of the reward word...
        find(preD_preF.timeframe>pre_caff_bdf.words(i,1)-holdtime,1):
        %to the time of the reward word
        find(preD_preF.timeframe> pre_caff_bdf.words(i,1),1),
    1)));
    
    %this is for pre_caff values predicted by the post_caff filter
    across_avgx(wt)=mean(abs(preD_postF.preddatabin(
        find(preD_postF.timeframe>pre_caff_bdf.words(i,1)-holdtime,1):
        find(preD_postF.timeframe> pre_caff_bdf.words(i,1),1),
    1)));

    end
end

%paired tTest to determine if the difference btwn the averages is random
[tTest_x,pT_x]=ttest(within_avgx,across_avgx);
[pW_x,h_x] = signrank(within_avgx,across_avgx);


