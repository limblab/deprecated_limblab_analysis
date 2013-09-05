clc;close all;
clear within_avgx within_avgy across_avgx within_avgy  tTest_x p_x tTest_y p_y

num_trials = 96;

holdtime=0.8;

wt=0;
for i = 1:size(data.words,1)

if data.words(i,2) == 32 & data.words(i,1)< within.timeframe(end) 

wt=wt+1;
within_avgx(wt)=mean(within.preddatabin(find(within.timeframe>data.words(i,1)-holdtime,1):find(within.timeframe> data.words(i,1),1),1));
across_avgx(wt)=mean(across.preddatabin(find(across.timeframe>data.words(i,1)-holdtime,1):find(across.timeframe> data.words(i,1),1),1));

%times_x(wt)=within.timeframe(find(within.timeframe>data.words(i,1),1));
%times_y(wt)=across.timeframe(find(across.timeframe>data.words(i,1),1));

within_avgy(wt)=mean(within.preddatabin(find(within.timeframe>data.words(i,1)-holdtime,1):find(within.timeframe> data.words(i,1),1),2));
across_avgy(wt)=mean(across.preddatabin(find(across.timeframe>data.words(i,1)-holdtime,1):find(across.timeframe> data.words(i,1),1),2));



    end
end

 [tTest_x,pT_x]=ttest(within_avgx,across_avgx);
 [pW_x,h_x] = signrank(within_avgx,across_avgx);
 
 [tTest_y,pT_y]=ttest(within_avgy,across_avgy);
 [pW_y,h_y] = signrank(within_avgy,across_avgy);


%   figure
%   hold on
%   plot(data_binned.timeframe, data_binned.cursorposbin(:,1),'k');
%   plot(within.timeframe, within.preddatabin(:,1),'r');
%   plot(across.timeframe, across.preddatabin(:,1),'b');
%   title('xpos');
%   legend('actual','within','across');
%   hold off;
% 
% 
% figure
% hold on
% plot(pre_caff_bdf_binned.timeframe, pre_caff_bdf_binned.cursorposbin(:,2),'k');
% plot(preD_preF.timeframe, preD_preF.preddatabin(:,2),'r');
% plot(preD_postF.timeframe, preD_postF.preddatabin(:,2),'b');
% title('ypos');
% legend('actual','within','across');
% hold off;
% 
% figure
% hold on;
% diffex = within_avgx - across_avgx;
% diffey = within_avgy - across_avgy;
% bar([mean(diffex) mean(diffey)]);
% set(gca,'XTick',[1 2])
% set(gca, 'xticklabel',{'diffx','diffy'});
% errorbar([1 2],[mean(diffex) mean(diffey)],[std(diffex) std(diffey)],'+');
% title('avg difference btwn within and across filters');
% xlabel({['tTest_x =',num2str(tTest_x),' p value=', num2str(pT_x)];['tTest_y =',num2str(tTest_y),' p value=', num2str(pT_y)]});
% hold off;