function params = DCO_plot_emg(data_struct,params)
DCO = data_struct.DCO;
bdf = data_struct.bdf;

%% EMG
for iEMG = 1:length(bdf.emg.emgnames)
    params.fig_handles(end+1) = figure;
    hold on
    y_max = 0.01;
    for iTargetDir = 1:length(DCO.target_locations)
        hDir(iTargetDir) = subplot(4,2,iTargetDir);
        hold on
        emg_hold = DCO.emg_hold(DCO.target_locations_idx{iTargetDir},:,iEMG);
        emg_mov = DCO.emg_mov(DCO.target_locations_idx{iTargetDir},:,iEMG);
        plot(DCO.t_hold,mean(emg_hold,1),'-r')
        errorarea(DCO.t_hold,mean(emg_hold,1),std(emg_hold,[],1),[1 .7 .7]);
        plot(DCO.t_mov,mean(emg_mov),'-b')
        errorarea(DCO.t_mov,mean(emg_mov,1),std(emg_mov,[],1),[.7 .7 1]);
        y_max = max(y_max,max(mean(emg_mov,1)+std(emg_mov,[],1)));
        y_max = max(y_max,max(mean(emg_hold,1)+std(emg_hold,[],1)));
        emg_hold_mean(iTargetDir) = mean(emg_hold(:));
        emg_hold_std(iTargetDir) = std(emg_hold(:));
        emg_mov_mean(iTargetDir) = mean(emg_mov(:));
        emg_mov_std(iTargetDir) = std(emg_mov(:));
        %         emg_hold_mean(iTargetDir) = mean(mean(DCO.emg_hold(intersect(DCO.target_forces_idx{end},...
        %             DCO.target_locations_idx{iTargetDir}),:,iEMG)));
        %         emg_mov_mean(iTargetDir) = mean(mean(DCO.emg_mov(intersect(DCO.target_forces_idx{end},...
        %             DCO.target_locations_idx{iTargetDir}),:,iEMG)));
        xlabel('t (s)')
        ylabel('EMG (norm)')
        legend('Hold','Movement')
        title(['Target direction ' num2str(DCO.target_locations(iTargetDir)*180/pi) ' deg'],'Interpreter','none')
        set(params.fig_handles(end),'Name',[bdf.emg.emgnames{iEMG}])
    end
    set(hDir,'YLim',[0 1.1*y_max])
    
    params.fig_handles(end+1) = figure;
    hold on
    errorarea(180*DCO.target_locations/pi,emg_hold_mean,emg_hold_std,[1 .8 .8]);
    errorarea(180*DCO.target_locations/pi,emg_mov_mean,emg_mov_std,[.8 .8 1]);
    plot(180*DCO.target_locations/pi,...
        emg_hold_mean,'-r')
    plot(180*DCO.target_locations/pi,...
        emg_mov_mean,'-b')
    %     plot(DCO.pos_mov_x(:,:)',...
    %         DCO.pos_mov_y(:,:)','-k')
    %     ylim([0 1])
    xlabel('Target direction (deg)')
    ylabel('EMG (norm)')
    legend('Hold','Movement')
    title(['Mean ' bdf.emg.emgnames{iEMG}],'Interpreter','none')
    set(params.fig_handles(end),'Name',['Mean ' bdf.emg.emgnames{iEMG}])
    %     axis equal
end

%%
params.fig_handles(end+1) = figure;
hold on
y_max = 0.01;
for iTargetDir = 1:length(DCO.target_locations)
    emg_hold_1 = mean(DCO.emg_hold(DCO.target_locations_idx{iTargetDir},1:end,~cellfun(@isempty,strfind(bdf.emg.emgnames,'BRD'))),2);
    emg_hold_2 = mean(DCO.emg_hold(DCO.target_locations_idx{iTargetDir},1:end,~cellfun(@isempty,strfind(bdf.emg.emgnames,'TRI'))),2);
    plot(emg_hold_1,emg_hold_2,'.','Color',min([1 1 1],.4+DCO.target_colors(iTargetDir,:)))
%     plot([mean(emg_hold_1)-std(emg_hold_1) mean(emg_hold_1)+std(emg_hold_1)],...
%         [mean(emg_hold_2) mean(emg_hold_2)],'-',...
%         'Color','k','LineWidth',4)
    plot([mean(emg_hold_1)-std(emg_hold_1) mean(emg_hold_1)+std(emg_hold_1)],...
        [mean(emg_hold_2) mean(emg_hold_2)],'-',...
        'Color',DCO.target_colors(iTargetDir,:),'LineWidth',2)
%     plot([mean(emg_hold_1) mean(emg_hold_1)],...
%         [mean(emg_hold_2)-std(emg_hold_2) mean(emg_hold_2)+std(emg_hold_2)],'-',...
%         'Color','k','LineWidth',4)   
    plot([mean(emg_hold_1) mean(emg_hold_1)],...
        [mean(emg_hold_2)-std(emg_hold_2) mean(emg_hold_2)+std(emg_hold_2)],'-',...
        'Color',DCO.target_colors(iTargetDir,:),'LineWidth',2)   
    xlabel('Brd (norm)')
    ylabel('Tri (norm)')
    title(['Average EMG for different targets'],'Interpreter','none')
    axis square    
end
emg_1 = [];
emg_2 = [];
for iTrial = 1:size(DCO.trial_table,1)
    emg_1(end+1) = mean(DCO.emg(~cellfun(@isempty,strfind(bdf.emg.emgnames,'BRD')),[DCO.start_idx(iTrial):DCO.start_idx(iTrial)+100]));
    emg_2(end+1) = mean(DCO.emg(~cellfun(@isempty,strfind(bdf.emg.emgnames,'TRI')),[DCO.start_idx(iTrial):DCO.start_idx(iTrial)+100]));
end
emg_1 = emg_1/max(DCO.emg(~cellfun(@isempty,strfind(bdf.emg.emgnames,'BRD')),[DCO.hold_idx_table DCO.mov_idx_table],:));
emg_2 = emg_2/max(DCO.emg(~cellfun(@isempty,strfind(bdf.emg.emgnames,'TRI')),[DCO.hold_idx_table DCO.mov_idx_table],:));
plot(emg_1,emg_2,'.','Color',[.7 .7 .7])
plot([mean(emg_1) mean(emg_1)],...
    [mean(emg_2)-std(emg_2) mean(emg_2)+std(emg_2)],'-',...
    'Color',[.2 .2 .2],'LineWidth',2)
plot([mean(emg_1)-std(emg_1) mean(emg_1)+std(emg_1)],...
    [mean(emg_2) mean(emg_2)],'-',...
    'Color',[.2 .2 .2],'LineWidth',2)
set(gca,'XLim',[0 max([get(gca,'XLim') get(gca,'YLim')])])
set(gca,'YLim',[0 max([get(gca,'XLim') get(gca,'YLim')])])


end

function h = errorarea(x,ymean,yerror,c)
x = reshape(x,1,[]);
ymean = reshape(ymean,size(x,1),size(x,2));
yerror = reshape(yerror,size(x,1),size(x,2));
%     h = area(x([1:end end:-1:1]),[ymean(1:end)+yerror(1:end) ymean(end:-1:1)-yerror(end:-1:1)],...
%         'FaceColor',c,'LineStyle','none');
plot(x([1:end end:-1:1]),[ymean(1:end)+yerror(1:end) ymean(end:-1:1)-yerror(end:-1:1)],...
    'Color',c,'LineStyle','--');
hChildren = get(gca,'children');
hType = get(hChildren,'Type');
set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))
end