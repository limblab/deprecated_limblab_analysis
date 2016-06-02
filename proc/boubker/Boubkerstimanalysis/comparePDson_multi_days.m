
% function h=comparePDs(series1,series2,color1,color1Arrow,color2,color2Arrow,tra1,tra2)
clear; close all;clc
numbperday=7;
pathnamePDs='\\165.124.111.234\limblab\user_folders\Boubker\PDs\';
pathnamePDsout='C:\Users\Boubker\Documents\Desktop\s1_analysis\proc\boubker\Boubkerstimanalysis\';
allroots={'Pedro_2011-04-28_RW_001';'Pedro_2011-04-29_RW_001';'Pedro_2011-04-30_RW_001';'Pedro_2011-05-01_RW_001';'Pedro_2011-05-02_RW_001';'Pedro_2011-05-04_RW_001';'Pedro_2011-05-05_RW_001';'Pedro_2011-05-06_RW_001';'Pedro_2011-05-07_RW_001';'Pedro_2011-05-08_RW_001';'Pedro_2011-05-09_RW_001';'Pedro_2011-05-10_RW_001';...
    'Pedro_2011-05-11_RW_001';'Pedro_2011-05-13_RW_001';'Pedro_2011-05-14_RW_001';'Pedro_2011-05-15_RW_001';'Pedro_2011-05-16_RW_001';'Pedro_2011-05-18_RW_001'};
for j=1: length(allroots)
 file{j}=load([pathnamePDs,char(allroots(j)),'_multi.mat']);
 series{1,j}=file{j}.allfilesPDs{1,1}(:,3:5);
end

color={'r','y','b','m','c','g','r','y','r','y','b','m','c','g','r','y','r','y','b','m','c','g','r','y','r','y','b','m','c','g','r','y'};
tra=[0.5 0.5 0.5 0.5 0.5 0.5 0.5,0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
colorArrow={'k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k'};


PDlength=1;

 


  b = waitbar(0,['Please wait... ']);



for cellID=1: size(series{1,1},1)
  

   sa=ceil(sqrt(size(series{1,1},1)));

 waitbar(cellID/size(series{1,1},1))
subplot(sa,sa,cellID)     
  compass(0,0); 
    hold on;
 for k=1: size(series,2)
   wedgeplot(series{1,k}(cellID,2), series{1,k}(cellID,3)-series{1,k}(cellID,2),char(color(k)),tra(k)) 

    
 [X2,Y2] = pol2cart(series{1,k}(cellID,2),PDlength);  
compass(X2,Y2,char(colorArrow(k))); 

CI{cellID}(k,1)=series{1,k}(cellID,2);%in rad

CI{cellID}(k,2)=abs(diff(unwrap([series{1,k}(cellID,3) series{1,k}(cellID,2) ])))/pi*180;
 end
 MaxCI(cellID,1)=max(CI{cellID}(:,2));
  MaxCI(cellID,2)=mean(CI{cellID}(:,2));
  MaxCI(cellID,3)=std(CI{cellID}(:,2));
  
   MaxPD(cellID,1)=max(CI{cellID}(:,1));
  MaxPD(cellID,2)=mean(CI{cellID}(:,1));
  MaxPD(cellID,3)=std(CI{cellID}(:,1));
% Find all childrens of the current axes
h=findall(gca);
% Select those which have linestyle = ':' i.e. grid
gh=h(strcmp(get(h,'linestyle'),':'));
% Hide them
set(gh,'visible','off')
 set(0,'showhiddenhandles','on')
ax = get(gcf,'Parent');
set(findobj(ax,'Type','Text'),'String','');
set(0,'showhiddenhandles','off');
  hold off;
  %title(['chan ',int2str(GLMPDs(cellID,1)),' u-',int2str(GLMPDs(cellID,2))]);
  h=gcf;
 
end
 close(b)

%  for cellID=1:10
%     subplot(sa,sa,cellID)  
%     title(int2str(cellID),'FontSize',7)
%  end
 
 for EC=1:size(CI,2)
     d=0;  PDdiff=[];
     for DC=1:size(CI{1,EC},1) 
       
         for j=DC:size(CI{1,EC},1)
            d=d+1;
             PDdiff(d)=abs(diff(unwrap([CI{1,EC}(DC,1) CI{1,EC}(j,1)])))/pi*180;
          
         end
       
     end
    maxchangePD(1,EC)=mean( PDdiff);
       maxchangePD(2,EC)=std( PDdiff);
%                CI{1,EC}(1,4)=min( PDdiff); 
 end;
  bb=0;
 for k=1: size(series,2)% each day
   
     for m=1:numbperday
          d=0;
         gg=(randperm(96));elect=gg(1:size(series,2));
         for p=1:length(elect)% one of 13 electrodes
            
             for j=p:length(elect)
                 d=d+1;
                 PDdiffdays(d)=abs(diff(unwrap([ series{1,k}(elect(p),2)  series{1,k}(elect(j),2)])))/pi*180;
                 
             end
             
         end 
         bb=bb+1;
          maxchangePDdays(1,bb)=mean( PDdiffdays);
       maxchangePDdays(2,bb)=std( PDdiffdays);
         
     end
 end
 
 
%  for dd=1:   size(CI,2)
%      maxchangePD(dd)=max(CI{1,dd}(:,3));
%  end
 

     saveas(gcf,([pathnamePDsout,char(allroots(1)),'_to_',char(allroots(end)),'.fig']))
    saveas(gcf,([pathnamePDsout,char(allroots(1)),'_to_',char(allroots(end)),'.tif']))
      saveas(gcf,([pathnamePDsout,char(allroots(1)),'_to_',char(allroots(end)),'.jpg']))
print(gcf, '-dpdf', '-r300', [pathnamePDsout,char(allroots(1)),'_to_',char(allroots(end)),'.pdf'])



figure;
subplot(3,1,1);
hist(maxchangePD(1,:),10);
xlim([0 100]);title('mean change in PDs accross days');
ylabel('electrodes');xlabel('mean difference in PD');
subplot(3,1,2);hist(maxchangePDdays(1,:),10);xlim([0 100]);
title('mean change in PDs accross electrodes');ylabel('count');xlabel('mean difference in PD')
subplot(3,1,3);
hist(maxchangePD(2,:),10);
 

     saveas(gcf,([pathnamePDsout,char(allroots(1)),' Change in PDs.fig']))
    saveas(gcf,([pathnamePDsout,char(allroots(1)),' Change in PDs.tif']))
      saveas(gcf,([pathnamePDsout,char(allroots(1)),' Change in PDs.jpg']))
print(gcf, '-dpdf', '-r300', [pathnamePDsout,char(allroots(1)),' Change in PDs.pdf'])


