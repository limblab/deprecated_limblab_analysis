% pathname='E:\Mini\Brain control\LFPs\';
% pathnameout='E:\Mini\Brain control\LFPs\Figs\';
% pathname='C:\Users\Marc\Documents\MATLAB\Chewie\Brain control\';
% pathnameout='C:\Users\Marc\Documents\MATLAB\Chewie\Brain control\';
% 
% close all;
% root='Chewie_Spike_LFP_09012011003_pdsallchans'
% load([pathname,root,'.mat']);%load allfiles PDS
% LFPband={'0-4';'70-115';'130-199'};%'200-300'};
% LFPband={'70-115'};
%1-2-12 updated to plot the true magnitude of the PD

for m=1: size(LFPfilesPDs{1,1},2)
    series1=[];
    series1=LFPfilesPDs{1,1}{1,m}(:,1:3);
    series1(:,4)=LFPfilesPDs{1,1}{1,m}(:,4);
    sa=ceil(sqrt(length(series1)));
%     series1(:,2) are the mean PDs; series1(:,1) and (:,3) are the
%     confidence bounds
    figure('name',char(LFPband(m)));
    
    for cellID=1: length(series1)
        if abs( series1(cellID,3)-series1(cellID,2))>0
            subplot(sa,sa,cellID)
            compass(0,0);
            hold on;
            
            %wedgeplot(series1(cellID,2), series1(cellID,3)-series1(cellID,2),'k',1)
            wedgeplot(series1(cellID,2), series1(cellID,3)-series1(cellID,2),[0 0 0],1);
            
            [Xglm,Yglm] = pol2cart(series1(cellID,2),series1(cellID,4));
            compass(Xglm,Yglm,'r');
            
            %    [Xglm1,Yglm1] = pol2cart(series1(cellID,7),1 );
            % compass(Xglm1,Yglm1,'g');
            
            
    %  title([int2str(series1(cellID,4))]);
               set(findall(gcf, 'String', '150', '-or','String','60','-or','String','30','-or','String','110','-or','String','120','-or','String','0.5','-or','String','210','-or','String','240','-or','String','300','-or','String','330','-or','String','90','-or','String','270','-or','String','0','-or','String','180'),'String', ' ');    


            hold off;
        end
        
    end
%     reply = input('Save? Y/N [Y]: ', 's');
% if isempty(reply)
%     reply = 'Y';
% end
% if reply=='Y'||reply=='y' 
     saveas(gcf,([pathnameout,root,char(LFPband(m)),'LFP_PDs.fig']))
%     saveas(gcf,([pathnameout,root,char(LFPband(m)),'_300LFP_PDs.tif']))
%       saveas(gcf,([pathnameout,char(LFPband(m)),'_300LFP_PDs.jpg']))
%   print(gcf, '-dpdf', '-r300', [pathnameout,root,char(LFPband(m)),'_300LFP_PDs.pdf'])

end

