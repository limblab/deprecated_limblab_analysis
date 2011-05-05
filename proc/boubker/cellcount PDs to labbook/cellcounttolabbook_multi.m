% clear
% clc
% pathname='\\165.124.111.234\limblab\user_folders\Boubker\PDs\';
% pathnameout='\\165.124.111.234\limblab\user_folders\Boubker\Labbooks\';
% root='Pedro_2011_04_08_RW_001';
% figout='4_8_2011_PDs';
% load([pathname,root,'.mat']);
% stimulated=[36,96];
% totalcurrent=[80,80];

pathname='\\165.124.111.234\limblab\user_folders\Boubker\PDs\';
pathnameout='C:\Users\Boubker\Documents\Desktop\s1_analysis\proc\boubker\Boubkerstimanalysis\';

load([pathname,root,'.mat'])
stimulated=[41,57];
totalcurrent=[80,80];

for f=1:size(allfilesPDs,2);
    allich{1,f}(:,1)=[1:1:96];
    allich{1,f}(:,2)=0;
     allich{1,f}(:,4)=0;
    for fr=1:96;
        if length(find( allfilesPDs{1,f}(:,1)==fr))>0
            allich{1,f}(fr,2)=length(find( allfilesPDs{1,f}(:,1)==fr));
           allich{1,f}(fr,3)=   allfilesPDs{1,f}(find( allfilesPDs{1,f}(:,1)==fr,1),4)/pi*180;
           
           if ismember(fr,stimulated)
               allich{1,f}(fr,4)=  totalcurrent(find(stimulated==fr));
           end
        end
    end
end;

allichv=allich{1,f}';

series1=allfilesPDs{1,1}(:,1:6);
series1(:,7)=allfilesPDs{1,1}(:,13);
 sa=ceil(sqrt(length(series1)));
 
figure

for cellID=1: length(series1)
    if abs( series1(cellID,5)-series1(cellID,4))>0
subplot(sa,sa,cellID)   
  compass(0,0); 
    hold on;
 
%wedgeplot(series1(cellID,4), series1(cellID,5)-series1(cellID,4),[(series1(cellID,6)/max(series1(:,6)))-min(series1(:,6)) (series1(cellID,6)/max(series1(:,6)))-min(series1(:,6)) (series1(cellID,6)/max(series1(:,6)))-min(series1(:,6)) ],1) 
wedgeplot(series1(cellID,4), series1(cellID,5)-series1(cellID,4),[0 0 0],1) 
  
[Xglm,Yglm] = pol2cart(series1(cellID,4),1);
compass(Xglm,Yglm,'r'); 

   [Xglm1,Yglm1] = pol2cart(series1(cellID,7),1 );
compass(Xglm1,Yglm1,'g'); 


title(['chan ',int2str(series1(cellID,1)),' u-',int2str(series1(cellID,2))]);
hold off;
    end
 
end
   xlswrite( [pathnameout,char(allfilesPDs{2,1}) '.xls'],allichv);
  saveas(gcf,([pathnameout,char(figout),'.tif']))
saveas(gcf,([pathnameout,char(figout),'.jpg']))
%save allichv.txt -ascii allichv

