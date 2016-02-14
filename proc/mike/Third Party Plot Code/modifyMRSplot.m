%% add a subplot to one of Mike's figures
close
uiopen('C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Chewie Processed Data\Single Unit Decoders\Hand Ccontrol files\HC_Single Feature Y Vel Day 0 Dec Perf_AllfileTest.fig',1)
set(gcf,'Position',[-1919        -138        1920        1007])
colorAx=gca;
colorbar
set(gca,'Position',[0.0234    0.3477    0.9148    0.6264], ...
    'XTick',1:size(Chewie_LFP1_FirstFileNames,1), ...
    'XTickLabel',cellfun(@num2str,Chewie_LFP1_FirstFileNames(:,2),'UniformOutput',0), ...
    'TickDir','out','TickLength',[0.002 0.025])
offlinePerfAx=axes('Position',[0.0234    0.0350    0.9148    0.27]);
temp=cellfun(@mean,{VAFstruct.r2},'UniformOutput',0);
temp=cat(1,temp{:});
offPerf=temp(:,2);
offPerfDays=cat(2,VAFstruct.decoder_age)';
MikeDays=cellfun(@str2num,get(colorAx,'XTickLabel'));

offPerfKeep=offPerf(ismember(offPerfDays,MikeDays));
offPerfKeepDayInds=find(ismember(MikeDays,offPerfDays));
% pad offPerfKeep, offPerfKeepDayInds so that this info can be displayed
% under the colorAx.
% imagesc([zeros(offPerfKeepDayInds(1)-1,1); offPerfKeep; ...
%     zeros(length(MikeDays)-offPerfKeepDayInds(end),1)]')

imagesc(offPerfKeep')

% imagesc([offPerfKeep(2:end); 0]')

% plot(offPerfKeepDayInds,offPerfKeep,'ko', ...
%     'LineWidth',1.5)
set(offlinePerfAx,'Xlim',get(colorAx,'Xlim'), ...
    'XTick',get(colorAx,'XTick'),'XTickLabel',get(colorAx,'XTickLabel'), ...
    'TickDir','out','TickLength',get(colorAx,'TickLength'))

