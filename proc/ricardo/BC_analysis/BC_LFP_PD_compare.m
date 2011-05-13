
% function h=comparePDs(series1,series2,color1,color1Arrow,color2,color2Arrow,tra1,tra2)
% clear; close all;clc


pathnamePDs='D:\Ricardo\Miller Lab\Results\Tiki\LFP PDs\';

allroots={'Tiki_2011-05-02_BC_001','Tiki_2011-05-04_BC_001'};

    %'Pedro_2011-04-29_RW_001';'Pedro_2011-04-30_RW_001';'Pedro_2011-05-01_RW_001';'Pedro_2011-05-02_RW_001';'Pedro_2011-05-04_RW_001';'Pedro_2011-05-05_RW_001'};
for j=1: length(allroots)
 file{j}=load([pathnamePDs,char(allroots(j)),'.mat']);
end


fbandst=[130,200,300];
fbanden=[190,290,390];

for bands=1:length(fbandst)
    series=[];
    for j=1: length(allroots)

series{1,j}=file{j}.LFPfilesPDs{1,1}{1,bands}(:,1:3);

    end
    figure
color={'r','y','b','m','c','g','r','y'};
tra=[0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
colorArrow={'k','k','k','k','k','k'};


PDlength=1;

 


  b = waitbar(0,['Please wait... ']);



for cellID=1: size(series{1,1},1)
  

   sa=ceil(sqrt(size(series{1,1},1)));

 waitbar(cellID/size(series{1,1},1));
subplot(sa,sa,cellID)     
  compass(0,0); 
    hold on;
 for k=1: size(series,2)
   wedgeplot(series{1,k}(cellID,2), series{1,k}(cellID,3)-series{1,k}(cellID,2),char(color(k)),tra(k)) ;

    
 [X2,Y2] = pol2cart(series{1,k}(cellID,2),PDlength);  
compass(X2,Y2,char(colorArrow(k))); 

 end
 
 set(0,'showhiddenhandles','on')
ax = get(gcf,'Parent');
set(findobj(ax,'Type','Text'),'String','');
set(0,'showhiddenhandles','off');
 %set(findall(gcf, 'String', '150', '-or','String','60','-or','String','30','-or','String','110','-or','String','120','-or','String','0.5','-or','String','210','-or','String','240','-or','String','300','-or','String','330','-or','String','90','-or','String','270','-or','String','0','-or','String','180'),'String', ' ');

  hold off;
  %title(['chan ',int2str(GLMPDs(cellID,1)),' u-',int2str(GLMPDs(cellID,2))]);
  h=gcf;
 
end

for cellID=1:10
    subplot(sa,sa,cellID)  
    title(int2str(cellID),'FontSize',7)
end
    close(b)
print(gcf, '-dpdf', '-r300', [pathnamePDs,'Compare_LFPs_Band_',int2str(fbandst(bands)),'_',int2str(fbanden(bands)),'.pdf'])
end

