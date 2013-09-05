%This code creates arrays containing the average values of predicted cursor 
%position data for 'holdtime' seconds before each reward. Predicted data 
%includes the WITHIN predictions, where the data and filter are from the 
%same session, and ACROSS predictions, where the data and filter are from
%two different sessions, one before and one after the monkey has ingested a
%serotonin-affecting drug. (created by Becca 3-26-2012)

close all;
clear within_avg across_avg tTest_x p_x tTest_y p_y

holdtime=.5;

j=0;
for i = 1:size(data.words,1)

    %look for instances of reward (word = 32), and make sure we're still
    %in timeframe of predicted data
    if data.words(i,2) == 32 && data.words(i,1)< within.timeframe(end) 

    j=j+1;

    %find indices of predictions at reward time and holdtime before reward
    early_time_within = find(within.timeframe>data.words(i,1)-holdtime,1);
    reward_time_within= find(within.timeframe>data.words(i,1),1);
    early_time_across = find(across.timeframe>data.words(i,1)-holdtime,1);
    reward_time_across= find(across.timeframe>data.words(i,1),1);
    early_time_actual = find(data_binned.timeframe>data.words(i,1)-holdtime,1);
    reward_time_actual= find(data_binned.timeframe>data.words(i,1),1);
    
    %calculate avg cursor pos before reward for within & across predictions
    within_avg(j,1)=mean(within.preddatabin(early_time_within:reward_time_within,1));
    within_avg(j,2)=mean(within.preddatabin(early_time_within:reward_time_within,2));    
    across_avg(j,1)=mean(across.preddatabin(early_time_across:reward_time_across,1));
    across_avg(j,2)=mean(across.preddatabin(early_time_across:reward_time_across,2));
    actual_avg(j,1)=mean(data_binned.cursorposbin(early_time_actual:reward_time_actual,1));
    actual_avg(j,2)=mean(data_binned.cursorposbin(early_time_actual:reward_time_actual,2));

    end
end

clear early_time_within reward_time_within early_time_across reward_time_across i j holdtime

%perform paired t-test to see if differences btwn within and across
%predictions are random
 [tTest_x,pT_x]=ttest(within_avg(:,1),across_avg(:,1));
 [tTest_y,pT_y]=ttest(within_avg(:,2),across_avg(:,2));

%% graphs and figures

%plot x data and predictions
 figure
 hold on
 plot(data_binned.timeframe, data_binned.cursorposbin(:,1),'k');
 plot(within.timeframe, within.preddatabin(:,1),'r');
 plot(across.timeframe, across.preddatabin(:,1),'b');
 title('xpos');
 legend('actual','within','across');
 hold off;
 
%plot y data and predictions 
 figure
 hold on
 plot(data_binned.timeframe, data_binned.cursorposbin(:,2),'k');
 plot(within.timeframe, within.preddatabin(:,2),'r');
 plot(across.timeframe, across.preddatabin(:,2),'b');
 title('ypos');
 legend('actual','within','across');
 hold off;
 
 %plot within and accross predictions vs actual data
 figure
   hold on
   
   subplot(1,2,1)
     hold on
     plot(actual_avg(:,1),within_avg(:,1),'r.');
     plot(actual_avg(:,1),across_avg(:,1),'b.');
     
     legend('within','across');
     
     p_within=polyfit(actual_avg(:,1),within_avg(:,1),1);
     plot([-5 5], polyval(p_within,[-5 5]),'r');
     p_across=polyfit(actual_avg(:,1),across_avg(:,1),1);
     plot([-5 5], polyval(p_across,[-5 5]),'b');
     
     plot([-5:5],[-5:5],'k');
     axis([-6 6 -6 6])
     xlabel('actual avg x');
     ylabel('pred avg x');

     
     
     subplot(1,2,2)
     hold on
     plot(actual_avg(:,2),within_avg(:,2),'r.');
     plot(actual_avg(:,2),across_avg(:,2),'b.');
     
     legend('within','across');
     
     p_within=polyfit(actual_avg(:,2),within_avg(:,2),1);
     plot([-5 5], polyval(p_within,[-5 5]),'r');
     p_across=polyfit(actual_avg(:,2),across_avg(:,2),1);
     plot([-5 5], polyval(p_across,[-5 5]),'b');
     
     plot([-5:5],[-5:5],'k');
     axis([-6 6 -6 6])
     xlabel('actual avg y');
     ylabel('pred avg y');