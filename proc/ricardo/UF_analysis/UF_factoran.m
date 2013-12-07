function UF_factoran(UF_struct,interesting_idx,factor_range,show_dots,save_figs)
    figHandles = [];    
    figTitles = cell(0);
    
    num_factors = 2;
    rand_indexes_temp = cell2mat(UF_struct.field_indexes');
    rand_order = randperm(length(rand_indexes_temp));
    rand_indexes_temp = rand_indexes_temp(rand_order);
    randomize = 0;

    for iField = 1:length(UF_struct.field_indexes)
        rand_indexes{iField} = rand_indexes_temp((iField-1)*floor(length(rand_indexes_temp)/length(UF_struct.field_indexes))+...
            [1:floor(length(rand_indexes_temp)/length(UF_struct.field_indexes))]);
    end

    if isempty(interesting_idx)
        interesting_idx = 1:size(UF_struct.firingrates,1);
    end

    firingrates = UF_struct.firingrates(interesting_idx,:,:);
    baseline = repmat(mean(mean(firingrates(:,1:find(UF_struct.t_axis<0,1,'last'),:),1),2),[size(firingrates,1) size(firingrates,2) 1]);
    % baseline = 0;
    firingrates = firingrates - baseline;

    lambda_mean = zeros(30,size(firingrates,3),num_factors);
    delete_idx = [];
    for i = 1:diff(factor_range)*1000
        try
            lambda = factoran(squeeze(firingrates(:,find(UF_struct.t_axis>(factor_range(1)+i*.001),1,'first'),:)),num_factors);
        catch
            delete_idx(end+1) = i;
            lambda = zeros(size(firingrates,3),num_factors);
        end
        lambda_mean(i,:,:) = lambda;
    end
    lambda_mean(delete_idx,:,:) = [];
    lambda = squeeze(mean(lambda_mean,1));
    if num_factors == 2
        lambda = [lambda zeros(size(lambda,1),1)];
    end
    % lambda = factoran(squeeze(firingrates(:,find(UF_struct.t_axis>(.05),1,'first'),:)),3);

    proj = zeros(size(firingrates,1),3);
    f1 = zeros(size(firingrates,1),size(firingrates,2));
    f2 = f1;
    f3 = f1;
    for iT = 1:length(UF_struct.t_axis)
         proj = squeeze(firingrates(:,iT,:)) * lambda(:,[1 2 3]);
         f1(:,iT) = proj(:,1);
         f2(:,iT) = proj(:,2);
         f3(:,iT) = proj(:,3);     
    end

    clear hLinesNeurons hDotsNeurons hMeanNeurons
    figHandles(end+1) = figure; 
    figTitles{end+1} = 'Factor analysis (field)';
    set(gcf,'name','Factor analysis','numbertitle','off')
    hSubPos = subplot(221);
    xlim([min(UF_struct.x_pos(:)) max(UF_struct.x_pos(:))])
    ylim([min(UF_struct.y_pos(:)) max(UF_struct.y_pos(:))])
    axis square
    xlabel('x pos (cm)')
    ylabel('y pos (cm)')
    hold on

    hSubForce = subplot(223);
    xlim([min(UF_struct.x_force(:)) max(UF_struct.x_force(:))])
    ylim([min(UF_struct.y_force(:)) max(UF_struct.y_force(:))])
    axis square
    xlabel('x force (N)')
    ylabel('y force (N)')
    hold on

    hSubNeurons = subplot(222);
    xlim([min(f1(:)) max(f1(:))])
    ylim([min(f2(:)) max(f2(:))])
    xlabel('factor 1')
    ylabel('factor 2')
    if num_factors>2
        zlim([min(f3(:)) max(f3(:))])
        zlabel('factor 3')
    end
    hold on

    hSubEMG = subplot(224);
    % xlim([min(reshape(UF_struct.emg_all(1,:,:),1,[])) max(reshape(UF_struct.emg_all(1,:,:),1,[]))])
    % ylim([min(reshape(UF_struct.emg_all(2,:,:),1,[])) max(reshape(UF_struct.emg_all(2,:,:),1,[]))])
    xlim([0 3*max(mean(UF_struct.emg_all(1,:,:),2))])
    ylim([0 3*max(mean(UF_struct.emg_all(2,:,:),2))])
    axis square
    xlabel([UF_struct.emgnames{1} ' (a.u.)'],'Interpreter','none')
    ylabel([UF_struct.emgnames{2} ' (a.u.)'],'Interpreter','none')
    hold on
    
    for iField = 1:length(UF_struct.field_indexes)
        if ~randomize
            [kin_idx{iField},idx{iField},~] = intersect(interesting_idx,UF_struct.field_indexes{iField});
        else
            [kin_idx{iField},idx{iField},~] = intersect(interesting_idx,rand_indexes{iField});
        end
        f1_mean(iField,:) = mean(f1(idx{iField},:));
        f1_sem(iField,:) = 1.96*std(f1(idx{iField},:))/sqrt(length(idx{iField}));
        f2_mean(iField,:) = mean(f2(idx{iField},:));
        f2_sem(iField,:) = 1.96*std(f2(idx{iField},:))/sqrt(length(idx{iField}));
        f3_mean(iField,:) = mean(f3(idx{iField},:));
        f3_sem(iField,:) = 1.96*std(f3(idx{iField},:))/sqrt(length(idx{iField}));

        x_pos_mean(iField,:) = mean(UF_struct.x_pos(kin_idx{iField},:));
        x_pos_sem(iField,:) = 1.96*std(UF_struct.x_pos(kin_idx{iField},:))/sqrt(length(kin_idx{iField}));    
        y_pos_mean(iField,:) = mean(UF_struct.y_pos(kin_idx{iField},:));
        y_pos_sem(iField,:) = 1.96*std(UF_struct.y_pos(kin_idx{iField},:))/sqrt(length(kin_idx{iField}));

        x_force_mean(iField,:) = mean(UF_struct.x_force(kin_idx{iField},:));
        x_force_sem(iField,:) = 1.96*std(UF_struct.x_force(kin_idx{iField},:))/sqrt(length(kin_idx{iField}));
        y_force_mean(iField,:) = mean(UF_struct.y_force(kin_idx{iField},:));
        y_force_sem(iField,:) = 1.96*std(UF_struct.y_force(kin_idx{iField},:))/sqrt(length(kin_idx{iField}));

      	emg_1_mean(iField,:) = squeeze(smooth(mean(UF_struct.emg_all(1,kin_idx{iField},:)),20));
        emg_1_sem(iField,:) = squeeze(smooth(std(UF_struct.emg_all(1,kin_idx{iField},:)),20))/sqrt(length(kin_idx{iField}));
        emg_2_mean(iField,:) = squeeze(smooth(mean(UF_struct.emg_all(2,kin_idx{iField},:)),20));
        emg_2_sem(iField,:) = squeeze(smooth(std(UF_struct.emg_all(2,kin_idx{iField},:)),20))/sqrt(length(kin_idx{iField}));
    end

    for iField = 1:length(UF_struct.field_indexes)   
        if ~isempty(idx)        
            hLinesNeurons(iField) = plot3(f1_mean(iField,1),f2_mean(iField,1),f3_mean(iField,1),...
                '-','Color',UF_struct.colors_field(iField,:),'Parent',hSubNeurons);
            hDotsNeurons(iField) = plot3(f1(idx{iField},1),...
                f2(idx{iField},1),...
                f3(idx{iField},1),'.','Color',UF_struct.colors_field(iField,:),'Parent',hSubNeurons);
            hMeanNeuronsX(iField) = plot3([f1_mean(iField,1)-f1_sem(iField,1) f1_mean(iField,1)+f1_sem(iField,1)],...
                [f2_mean(iField,1) f2_mean(iField,1)],[f3_mean(iField,1) f3_mean(iField,1)],...
                '-','LineWidth',4,'Color',UF_struct.colors_field(iField,:),'Parent',hSubNeurons);
            hMeanNeuronsY(iField) = plot3([f1_mean(iField,1) f1_mean(iField,1)],...
                [f2_mean(iField,1)-f2_sem(iField,1) f2_mean(iField,1)+f2_sem(iField,1)],[f3_mean(iField,1) f3_mean(iField,1)],...
                '-','LineWidth',4,'Color',UF_struct.colors_field(iField,:),'Parent',hSubNeurons);
            hMeanNeuronsZ(iField) = plot3([f1_mean(iField,1) f1_mean(iField,1)],...
                [f2_mean(iField,1) f2_mean(iField,1)],[f3_mean(iField,1)-f3_sem(iField,1) f3_mean(iField,1)+f3_sem(iField,1)],...
                '-','LineWidth',4,'Color',UF_struct.colors_field(iField,:),'Parent',hSubNeurons);

            hLinesPos(iField) = plot(UF_struct.x_pos(kin_idx{iField},1),UF_struct.y_pos(kin_idx{iField},1),...
                '-','Color',UF_struct.colors_field(iField,:),'Parent',hSubPos);
            hDotsPos(iField) = plot(UF_struct.x_pos(kin_idx{iField},1),UF_struct.y_pos(kin_idx{iField},1),...
                '.','Color',UF_struct.colors_field(iField,:),'Parent',hSubPos);
            hMeanPosX(iField) = plot([x_pos_mean(iField,1)-x_pos_sem(iField,1) x_pos_mean(iField,1)+x_pos_sem(iField,1)],...
                [y_pos_mean(iField,1) y_pos_mean(iField,1)],...
                '-','LineWidth',4,'Color',UF_struct.colors_field(iField,:),'Parent',hSubPos);
            hMeanPosY(iField) = plot([x_pos_mean(iField,1) x_pos_mean(iField,1)],...
                [y_pos_mean(iField,1)-y_pos_sem(iField,1) y_pos_mean(iField,1)+y_pos_sem(iField,1)],...
                '-','LineWidth',4,'Color',UF_struct.colors_field(iField,:),'Parent',hSubPos);       

            hLinesForce(iField) = plot(UF_struct.x_force(kin_idx{iField},1),UF_struct.y_force(kin_idx{iField},1),...
                '-','Color',UF_struct.colors_field(iField,:),'Parent',hSubForce);
            hDotsForce(iField) = plot(UF_struct.x_force(kin_idx{iField},1),UF_struct.y_force(kin_idx{iField},1),...
                '.','Color',UF_struct.colors_field(iField,:),'Parent',hSubForce); 
            hMeanForceX(iField) = plot([x_force_mean(iField,1)-x_force_sem(iField,1) x_force_mean(iField,1)+x_force_sem(iField,1)],...
                [y_force_mean(iField,1) y_force_mean(iField,1)],...
                '-','LineWidth',4,'Color',UF_struct.colors_field(iField,:),'Parent',hSubForce);     
            hMeanForceY(iField) = plot([x_force_mean(iField,1) x_force_mean(iField,1)],...
                [y_force_mean(iField,1)-y_force_sem(iField,1) y_force_mean(iField,1)+y_force_sem(iField,1)],...
                '-','LineWidth',4,'Color',UF_struct.colors_field(iField,:),'Parent',hSubForce); 

            hLinesEMG(iField) = plot(mean(UF_struct.emg_all(1,kin_idx{iField},1)),mean(UF_struct.emg_all(2,kin_idx{iField},1)),...
                '-','Color',UF_struct.colors_field(iField,:),'Parent',hSubEMG);
            hDotsEMG(iField) = plot(UF_struct.emg_all(1,kin_idx{iField},1),UF_struct.emg_all(2,kin_idx{iField},1),...
                '.','Color',UF_struct.colors_field(iField,:),'Parent',hSubEMG); 
            hMeanEMGX(iField) = plot([emg_1_mean(iField,1)-emg_1_sem(iField,1) emg_1_mean(iField,1)+emg_1_sem(iField,1)],...
                [emg_2_mean(iField,1) emg_2_mean(iField,1)],...
                '-','LineWidth',4,'Color',UF_struct.colors_field(iField,:),'Parent',hSubEMG);     
            hMeanEMGY(iField) = plot([emg_1_mean(iField,1) emg_1_mean(iField,1)],...
                [emg_2_mean(iField,1)-emg_2_sem(iField,1) emg_2_mean(iField,1)+emg_2_sem(iField,1)],...
                '-','LineWidth',4,'Color',UF_struct.colors_field(iField,:),'Parent',hSubEMG);

            drawnow
        end
    end

    if ~show_dots
        set(hDotsNeurons,'Visible','off')
        set(hDotsPos,'Visible','off')
        set(hDotsForce,'Visible','off')
        set(hDotsEMG,'Visible','off')
    end
    for iT = 2:length(UF_struct.t_axis)
        for iField = 1:length(UF_struct.field_indexes)           
            if ~isempty(idx)               
                set(hLinesNeurons(iField),'XData',mean(f1(idx{iField},(1:iT))))
                set(hLinesNeurons(iField),'YData',mean(f2(idx{iField},(1:iT))))
                set(hLinesNeurons(iField),'ZData',mean(f3(idx{iField},(1:iT))))

                set(hDotsNeurons(iField),'XData',f1(idx{iField},iT))
                set(hDotsNeurons(iField),'YData',f2(idx{iField},iT))
                set(hDotsNeurons(iField),'ZData',f3(idx{iField},iT))    

                set(hMeanNeuronsX(iField),'XData',[f1_mean(iField,iT)-f1_sem(iField,iT) f1_mean(iField,iT)+f1_sem(iField,iT)])
                set(hMeanNeuronsX(iField),'YData',[f2_mean(iField,iT) f2_mean(iField,iT)])
                set(hMeanNeuronsX(iField),'ZData',[f3_mean(iField,iT) f3_mean(iField,iT)])

                set(hMeanNeuronsY(iField),'XData',[f1_mean(iField,iT) f1_mean(iField,iT)])
                set(hMeanNeuronsY(iField),'YData',[f2_mean(iField,iT)-f2_sem(iField,iT) f2_mean(iField,iT)+f2_sem(iField,iT)])
                set(hMeanNeuronsY(iField),'ZData',[f3_mean(iField,iT) f3_mean(iField,iT)])

                set(hMeanNeuronsZ(iField),'XData',[f1_mean(iField,iT) f1_mean(iField,iT)])
                set(hMeanNeuronsZ(iField),'YData',[f2_mean(iField,iT) f2_mean(iField,iT)])
                set(hMeanNeuronsZ(iField),'ZData',[f3_mean(iField,iT)-f3_sem(iField,iT) f3_mean(iField,iT)+f3_sem(iField,iT)])

                set(hDotsPos(iField),'XData',UF_struct.x_pos(kin_idx{iField},iT));
                set(hDotsPos(iField),'YData',UF_struct.y_pos(kin_idx{iField},iT));

                set(hLinesPos(iField),'XData',x_pos_mean(iField,1:iT),'YData',y_pos_mean(iField,1:iT));

                set(hMeanPosX(iField),'XData',[x_pos_mean(iField,iT)-x_pos_sem(iField,iT) x_pos_mean(iField,iT)+x_pos_sem(iField,iT)])
                set(hMeanPosX(iField),'YData',[y_pos_mean(iField,iT) y_pos_mean(iField,iT)])

                set(hMeanPosY(iField),'XData',[x_pos_mean(iField,iT) x_pos_mean(iField,iT)])
                set(hMeanPosY(iField),'YData',[y_pos_mean(iField,iT)-y_pos_sem(iField,iT) y_pos_mean(iField,iT)+y_pos_sem(iField,iT)])

                set(hDotsForce(iField),'XData',UF_struct.x_force(kin_idx{iField},iT));
                set(hDotsForce(iField),'YData',UF_struct.y_force(kin_idx{iField},iT));

                set(hLinesForce(iField),'XData',x_force_mean(iField,1:iT),'YData',y_force_mean(iField,1:iT));

                set(hMeanForceX(iField),'XData',[x_force_mean(iField,iT)-x_force_sem(iField,iT) x_force_mean(iField,iT)+x_force_sem(iField,iT)])
                set(hMeanForceX(iField),'YData',[y_force_mean(iField,iT) y_force_mean(iField,iT)])

                set(hMeanForceY(iField),'XData',[x_force_mean(iField,iT) x_force_mean(iField,iT)])
                set(hMeanForceY(iField),'YData',[y_force_mean(iField,iT)-y_force_sem(iField,iT) y_force_mean(iField,iT)+y_force_sem(iField,iT)])

                % EMG
                set(hDotsEMG(iField),'XData',UF_struct.emg_all(1,kin_idx{iField},iT));
                set(hDotsEMG(iField),'YData',UF_struct.emg_all(2,kin_idx{iField},iT));

                set(hLinesEMG(iField),'XData',emg_1_mean(iField,1:iT),'YData',emg_2_mean(iField,1:iT));

                set(hMeanEMGX(iField),'XData',[emg_1_mean(iField,iT)-emg_1_sem(iField,iT) emg_1_mean(iField,iT)+emg_1_sem(iField,iT)])
                set(hMeanEMGX(iField),'YData',[emg_2_mean(iField,iT) emg_2_mean(iField,iT)])

                set(hMeanEMGY(iField),'XData',[emg_1_mean(iField,iT) emg_1_mean(iField,iT)])
                set(hMeanEMGY(iField),'YData',[emg_2_mean(iField,iT)-emg_2_sem(iField,iT) emg_2_mean(iField,iT)+emg_2_sem(iField,iT)])
            end
        end
        title(['t = ' num2str(UF_struct.t_axis(iT)) ' s'])
        drawnow
        pause(.01)    
    end

    figHandles(end+1) = figure; 
    figTitles{end+1} = 'Factor analysis (field) - Summary';
    set(gcf,'name','Factor analysis','numbertitle','off')
    for iField = 1:length(UF_struct.field_indexes)        
        subplot(221)
        hold on
        plot(UF_struct.t_axis,f1_mean(iField,:),'Color',UF_struct.colors_field(iField,:))
        errorarea(UF_struct.t_axis,f1_mean(iField,:),f1_sem(iField,:),min([1 1 1],.7+UF_struct.colors_field(iField,:)));
        ylabel('F1')
        subplot(223)
        hold on
        plot(UF_struct.t_axis,f2_mean(iField,:),'Color',UF_struct.colors_field(iField,:))
        errorarea(UF_struct.t_axis,f2_mean(iField,:),f2_sem(iField,:),min([1 1 1],.7+UF_struct.colors_field(iField,:)));
        xlabel('t (s)')
        ylabel('F2')        
    end
    subplot(222)
    hold on
    mean_diff = sqrt(diff(f1_mean).^2+diff(f2_mean).^2);
    plot(UF_struct.t_axis,mean_diff,'Color','k')
%     errorarea(UF_struct.t_axis,mean_diff,...,min([1 1 1],.7+UF_struct.colors_field(iField,:)));
    xlabel('t (s)')
    ylabel('||F||')
    
    subplot(224)
    hold on    
    plot(UF_struct.t_axis,diff(emg_1_mean),'Color','r')
    plot(UF_struct.t_axis,diff(emg_2_mean),'Color','b')
%     errorarea(UF_struct.t_axis,mean_diff,...,min([1 1 1],.7+UF_struct.colors_field(iField,:)));
    legend(UF_struct.emgnames,'Interpreter','none')
    xlabel('t (s)')
    ylabel('diff(EMG)')
    if save_figs
        save_figures(figHandles,UF_struct.UF_file_prefix,UF_struct.datapath,'',figTitles)
    end
end
        
function h = errorarea(x,ymean,yerror,c)
    x = reshape(x,1,[]);
    ymean = reshape(ymean,size(x,1),size(x,2));
    yerror = reshape(yerror,size(x,1),size(x,2));
    h = area(x([1:end end:-1:1]),[ymean(1:end)+yerror(1:end) ymean(end:-1:1)-yerror(end:-1:1)],...
        'FaceColor',c,'LineStyle','none');
    hChildren = get(gca,'children');
    hType = get(hChildren,'Type');
    set(gca,'children',hChildren([find(strcmp(hType,'line')); find(~strcmp(hType,'line'))]))
end

