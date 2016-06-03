
% function h=comparePDs(series1,series2,color1,color1Arrow,color2,color2Arrow,tra1,tra2)
clear; close all;clc
numbperday=7;
pathnamePDs='D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\Multiunit PD analysis\';
pathnamePDsout='D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\Multiunit PD analysis\';
allroots={'Tiki_2011-05-17_RW_001-s_thres2','Tiki_2011-05-19_RW_001-s_thres',...
    'Tiki_2011-05-23_RW_001-s_thres','Tiki_2011-05-24_RW_001-s_thres',...
    'Tiki_2011-05-25_RW_001-s_thres','Tiki_2011-05-26_RW_001',...
    'Tiki_2011-05-27_RW_001-s_thres','Tiki_2011-06-02_RW_001-xcr-5-5'};

for j=1:length(allroots)
    file{j}=load([pathnamePDs,char(allroots(j)),'_multi.mat']);
    series{1,j}=file{j}.allfilesPDs{1,1}(:,3:5);
end

num_files = length(allroots);

color={'r','y','b','m','c','g','r','y','r','y','b','m','c','g','r','y','r','y','b','m','c','g','r','y','r','y','b','m','c','g','r','y'};
tra=[0.5 0.5 0.5 0.5 0.5 0.5 0.5,0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
colorArrow={'k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k','k'};

PDlength=1;

for iFile = 1:num_files  
    for cellID=1:size(series{iFile},1)      
        channel = file{iFile}.allfilesPDs{1}(cellID,1);
        subplot(10,10,channel)     
        hold on;
        wedgeplot(series{iFile}(cellID,2), series{iFile}(cellID,3)-series{iFile}(cellID,2),char(color(iFile)),tra(iFile)) 

        [X2,Y2] = pol2cart(series{iFile}(cellID,2),PDlength);  
        compass(X2,Y2,char(colorArrow(iFile))); 

        CI{channel}(iFile,1)=series{iFile}(cellID,2);%in rad

        CI{channel}(iFile,2)=abs(diff(unwrap([series{iFile}(cellID,3) series{iFile}(cellID,2) ])))/pi*180;
        MaxCI(cellID,1)=max(CI{channel}(:,2));
        MaxCI(cellID,2)=mean(CI{channel}(:,2));
        MaxCI(cellID,3)=std(CI{channel}(:,2));

        MaxPD(cellID,1)=max(CI{channel}(:,1));
        MaxPD(cellID,2)=mean(CI{channel}(:,1));
        MaxPD(cellID,3)=std(CI{channel}(:,1));
        % Find all childrens of the current axes
        h=findall(gca);
        % Select those which have linestyle = ':' i.e. grid
        gh=h(strcmp(get(h,'linestyle'),':'));
        % Hide them
        set(gh,'visible','off')
        set(0,'showhiddenhandles','on')
        ax = get(gcf,'Parent');
        set(findobj(gca,'Type','Text'),'String','');
        set(0,'showhiddenhandles','off');
        hold off;
        title(['chan ',int2str(channel)]);
        h=gcf;
    end
end


%  for cellID=1:10
%     subplot(sa,sa,cellID)  
%     title(int2str(cellID),'FontSize',7)
%  end
 
for EC=1:size(CI,2)
    d=0;  
    PDdiff=[];
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
 for k=1:size(series,2)% each day   
     for m=1:numbperday
        d=0;
        gg=randperm(length(series{k}));
        elect=gg(1:size(series,2));
        for p=1:length(elect)
            for j=p:length(elect)
                 d=d+1;
                 PDdiffdays(d)=abs(diff(unwrap([series{1,k}(elect(p),2)  series{1,k}(elect(j),2)])))/pi*180;
            end
        end 
        bb=bb+1;
        maxchangePDdays(1,bb)=mean(PDdiffdays);
        maxchangePDdays(2,bb)=std(PDdiffdays);         
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
xlim([0 100]);
title('mean change in PDs accross days');
ylabel('electrodes');
xlabel('mean difference in PD');

subplot(3,1,2);
hist(maxchangePDdays(1,:),10);
xlim([0 100]);
title('mean change in PDs accross electrodes');
ylabel('count');
xlabel('mean difference in PD')

subplot(3,1,3);
hist(maxchangePD(2,:),10);

saveas(gcf,([pathnamePDsout,char(allroots(1)),' Change in PDs.fig']))
saveas(gcf,([pathnamePDsout,char(allroots(1)),' Change in PDs.tif']))
saveas(gcf,([pathnamePDsout,char(allroots(1)),' Change in PDs.jpg']))
print(gcf, '-dpdf', '-r300', [pathnamePDsout,char(allroots(1)),' Change in PDs.pdf'])


