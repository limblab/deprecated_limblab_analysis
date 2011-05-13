
pathname='D:\Ricardo\Miller Lab\Results\Tiki\LFP PDs\';
pathnameout='D:\Ricardo\Miller Lab\Results\Tiki\LFP PDs\';

root={'Tiki_2011-05-02_BC_001'};


close all;

temp = strcat(pathname,root,'.mat');
load(temp{1});%load allfiles PDS
% LFPband={'10-50';'70-110';'130-190';'200-260'};
LFPband={'130-190'};

for m=1: size(LFPfilesPDs{1,1},2)
    series1=[];
    series1=LFPfilesPDs{1,1}{1,m}(:,1:3);
    series1(:,4)=LFPfilesPDs{1,1}{1,m}(:,5);
    sa=ceil(sqrt(length(series1)));
    
    figure('name',char(LFPband(m)));
    
    for cellID=1: length(series1)
        if abs( series1(cellID,3)-series1(cellID,2))>0
            subplot(sa,sa,cellID)
            compass(0,0);
            hold on;
            
            %wedgeplot(series1(cellID,2), series1(cellID,3)-series1(cellID,2),'k',1)
            wedgeplot(series1(cellID,2), series1(cellID,3)-series1(cellID,2),[0 0 0],1)
            
            [Xglm,Yglm] = pol2cart(series1(cellID,2),cellID);
            compass(Xglm,Yglm,'r');
            
            %    [Xglm1,Yglm1] = pol2cart(series1(cellID,7),1 );
            % compass(Xglm1,Yglm1,'g');
            
            
    %  title([int2str(series1(cellID,4))]);
               set(findall(gcf, 'String', '150', '-or','String','60','-or','String','30','-or','String','110','-or','String','120','-or','String','0.5','-or','String','210','-or','String','240','-or','String','300','-or','String','330','-or','String','90','-or','String','270','-or','String','0','-or','String','180'),'String', ' ');    


            hold off;
        end
        
    end
    reply = input('Save? Y/N [Y]: ', 's');
if isempty(reply)
    reply = 'Y';
end
if reply=='Y'||reply=='y' 
     saveas(gcf,([pathnameout,root,char(LFPband(m)),'_300LFP_PDs.fig']))
    saveas(gcf,([pathnameout,root,char(LFPband(m)),'_300LFP_PDs.tif']))
      saveas(gcf,([pathnameout,char(LFPband(m)),'_300LFP_PDs.jpg']))
  print(gcf, '-dpdf', '-r300', [pathnameout,root,char(LFPband(m)),'_300LFP_PDs.pdf'])

end
end
