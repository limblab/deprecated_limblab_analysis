function showPAsig(PA,chToUse,xlims,freqs,x,y,H)

% syntax showPAsig(PA,chToUse,xlims,freqs,x,y,H)
%
% The purpose of the function is the create a good-looking figure that
% shows a segment of the normalized log power, and below it a trace of 
% the behavioral data, with predicted signal overlaid on real signal
%
% suggested usage for ECoG force paper (example for UCI6):
%       >> load('E:\ECoG_Data\analyzed\force_paramSearch\no Zscore\11foldv2\force_S_UCI4_6_lambda.mat','force_S_UCI4_6index')
%       >> [val,ind]=max(cellfun(@mean,{force_S_UCI4_6index(4,:).vaf}));
% get the paramStructIn from force_S_UCI4_6index(4,ind), if that is the
% recording of interest.
%       >> paramStructIn=struct('PolynomialOrder',3,'folds',11,'numlags',10,'wsz',256,'nfeat',313, ...
%           'smoothfeats',0,'binsize',0.1,'fpSingle',0,'zscore',0,'lambda',6,'bands','1 2 3 4 5 6','random',0);
%       >> batchAnalyzeECoGv6(infoStruct(67),'force','S',paramStructIn);
% 
% 
% 
% 
% originally written for the ECoG-force paper, 02-18-2014
%

% time vector, and the part of that to use
t=(1:size(x,1))*0.025;
if xlims(2)==0, xlims(2)=t(end); end
timeIndsToUse=find(t>=xlims(1) & t<=xlims(2));

% figure out empirically which H to use, then re-find the correct P for
% this segment of data
vaf=[];
for n=1:length(H)
    [y_pred,~,ytnew]=predMIMO3(x(timeIndsToUse,:),H{n},1,1,y(timeIndsToUse,:));
    for z=1:size(y_pred,2)
        P(z,:)=WienerNonlinearity(y_pred(:,z),ytnew(:,z),3);
        y_pred(:,z)=polyval(P(z,:),y_pred(:,z));
    end
    vaf=[vaf; RcoeffDet(y_pred,ytnew)];
end

% pick the H according to which vaf was highest for this data segment, and
% recalculate the P one more time.
[~,ind]=max(mean(vaf,2));
[y_pred,~,ytnew]=predMIMO3(x(timeIndsToUse,:),H{ind},1,1,y(timeIndsToUse,:));
for z=1:size(y_pred,2)
    P(z,:)=WienerNonlinearity(y_pred(:,z),ytnew(:,z),3);
    y_pred(:,z)=polyval(P(z,:),y_pred(:,z));
end
vaf=RcoeffDet(y_pred,ytnew);
% have to cut down timeIndsToUse because of predMIMO3 cutting out the 1st
% few points
timeIndsToUse(1:(length(timeIndsToUse)-length(ytnew)))=[];

% now, we can make the figure. 
showPAfig=figure; 
set(showPAfig,'Position',[16 449 1180 530],'Tag','showPAfig', ...
    'Color','w')
showPAax=axes('Position',[0.05 0.3 0.9 0.65]);
% limit to 0-300 Hz.
PA(freqs>301,:,:)=[]; freqs(freqs>303)=[];
imagesc(t(timeIndsToUse),fliplr(freqs), ...
    filter2(1/9*ones(3),flipud(squeeze(PA(:,chToUse,timeIndsToUse)))))
% caxis([-16 7.5])
caxis([-10 5])
set(showPAax,'box','off','TickLength',[0 0],'YDir','normal','XTick',[], ...
    'XColor','w','FontName','Arial','FontSize',14,'YTick',0:100:500,'Tag','showPAax')
cbar_ax=colorbar('Location','manual','Tag','cbar_ax');
set(cbar_ax,'Position',[0.955 0.3 0.02 0.65],'TickLength',[0 0], ...
    'box','off','FontName','Arial','FontSize',14)
sigAx=axes('Position',[0.05 0.04 0.9 0.24],'NextPlot','add');
for z=1:size(y_pred,2)
    % if amplitude scales are arbitrary, then we can equalize them
    % for the plot.  Save the scaling factor that is used, 
    % because we'll want to be able to display the force in N.
    % what are units of position?  Angle of the joint for the MIP.
    plot(t(timeIndsToUse),-1*ytnew(:,z),'LineWidth',1.5)
    plot(t(timeIndsToUse),-1*y_pred(:,z),'g','LineWidth',1.5)
end
set(sigAx,'Ylim',[min(-1*[ytnew(:); y_pred(:)]) max(-1*[ytnew(:); y_pred(:)])], ...
    'Xlim',t(timeIndsToUse([1 end])),'box','off', ...
    'TickLength',[0 0],'FontName','Arial','FontSize',14, ...
    'LineWidth',2,'Tag','sigAx')


disp('done')

return

%% to set Xlim of lower plot equal to current Xlim of upper plot
set(findobj(gcf,'Tag','sigAx'),'Xlim',get(findobj(gcf,'Tag','showPAax'),'Xlim'))                %#ok<UNRCH>

%% 1st step in converting to N.  Also works for EMG correction
fig=gcf;
actualH=findobj(fig,'Type','line','Color','b');
predH=findobj(fig,'Type','line','Color','g');
actualY=get(actualH,'ydata')'; 
predY=get(predH,'ydata')';

%% 2nd step in converting to N (if UCI patient!)
actualY_N=(actualY+0.004)/0.056*0.453592*9.81;
predY_N=(predY+0.004)/0.056*0.453592*9.81;

%% 2nd step in converting to N (if TDT patient!)
actualY_N=(actualY_N-22)/590*0.453592*9.81;
predY_N=(predY_N-22)/590*0.453592*9.81;

%% 3rd step in converting to N
set(actualH,'ydata',actualY_N-min([actualY_N; predY_N])-5)
set(predH,'ydata',predY_N-min([actualY_N; predY_N])-5)

%%
set(findobj(fig,'Tag','sigAx'),'Ylim',[-5 60])

%% 2nd step for EMG correction.
set(actualH,'ydata',actualY*(-1))
set(predH,'ydata',predY*(-1))
set(findobj(fig,'Tag','sigAx'),'Ylim', ...
    sort(-1*get(findobj(fig,'Tag','sigAx'),'Ylim'),'ascend'))

