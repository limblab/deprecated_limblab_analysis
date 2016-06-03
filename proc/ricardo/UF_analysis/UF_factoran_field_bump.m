function UF_factoran_field_bump(UF_struct,interesting_idx,factor_offset,show_dots,save_figs)
% show_dots = 0;
num_factors = 3;

if isempty(interesting_idx)
    interesting_idx = 1:size(UF_struct.firingrates,1);
end

firingrates = UF_struct.firingrates(interesting_idx,:,:);
baseline = repmat(mean(mean(firingrates(:,1:find(UF_struct.t_axis<0,1,'last'),:),1),2),[size(firingrates,1) size(firingrates,2) 1]);
% baseline = 0;
firingrates = firingrates - baseline;

lambda_mean = zeros(30,size(firingrates,3),num_factors);
delete_idx = [];
for i = 1:30
    try
        lambda = factoran(squeeze(firingrates(:,find(UF_struct.t_axis>(factor_offset+i*.001),1,'first'),:)),num_factors);
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
figure; 
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
xlabel([UF_struct.emgnames{1} ' (a.u.)'])
ylabel([UF_struct.emgnames{2} ' (a.u.)'])
hold on

num_bumps = length(UF_struct.bump_indexes);
num_fields = length(UF_struct.field_indexes);

for iBump = 1:length(UF_struct.bump_indexes)
    for iField = 1:length(UF_struct.field_indexes)
        temp = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
        [kin_idx,idx,~] = intersect(interesting_idx,temp);        
        
        f1_mean = mean(f1(idx,1));
        f1_sem = 1.96*std(f1(idx,1))/sqrt(length(idx));
        f2_mean = mean(f2(idx,1));
        f2_sem = 1.96*std(f2(idx,1))/sqrt(length(idx));
        f3_mean = mean(f3(idx,1));
        f3_sem = 1.96*std(f3(idx,1))/sqrt(length(idx));

        x_pos_mean = mean(UF_struct.x_pos(kin_idx,1));
        x_pos_sem = 1.96*std(UF_struct.x_pos(kin_idx,1))/sqrt(length(kin_idx));    
        y_pos_mean = mean(UF_struct.y_pos(kin_idx,1));
        y_pos_sem = 1.96*std(UF_struct.y_pos(kin_idx,1))/sqrt(length(kin_idx));

        x_force_mean = mean(UF_struct.x_force(kin_idx,1));
        x_force_sem = 1.96*std(UF_struct.x_force(kin_idx,1))/sqrt(length(kin_idx));
        y_force_mean = mean(UF_struct.y_force(kin_idx,1));
        y_force_sem = 1.96*std(UF_struct.y_force(kin_idx,1))/sqrt(length(kin_idx));

        emg_1_mean = mean(UF_struct.emg_all(1,kin_idx,1));
        emg_1_sem = 1.96*std(UF_struct.emg_all(1,kin_idx,1))/sqrt(length(kin_idx));    
        emg_2_mean = mean(UF_struct.emg_all(2,kin_idx,1));
        emg_2_sem = 1.96*std(UF_struct.emg_all(2,kin_idx,1))/sqrt(length(kin_idx));

        if ~isempty(idx)        
            hLinesNeurons((iField-1)*num_bumps + iBump) = plot3(f1_mean,f2_mean,f3_mean,...
                '-','Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubNeurons);
            hDotsNeurons((iField-1)*num_bumps + iBump) = plot3(f1(idx,1),...
                f2(idx,1),...
                f3(idx,1),'.','Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubNeurons);
            hMeanNeuronsX((iField-1)*num_bumps + iBump) = plot3([f1_mean-f1_sem f1_mean+f1_sem],...
                [f2_mean f2_mean],[f3_mean f3_mean],...
                '-','LineWidth',4,'Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubNeurons);
            hMeanNeuronsY((iField-1)*num_bumps + iBump) = plot3([f1_mean f1_mean],...
                [f2_mean-f2_sem f2_mean+f2_sem],[f3_mean f3_mean],...
                '-','LineWidth',4,'Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubNeurons);
            hMeanNeuronsZ((iField-1)*num_bumps + iBump) = plot3([f1_mean f1_mean],...
                [f2_mean f2_mean],[f3_mean-f3_sem f3_mean+f3_sem],...
                '-','LineWidth',4,'Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubNeurons);

            hLinesPos((iField-1)*num_bumps + iBump) = plot(UF_struct.x_pos(kin_idx,1),UF_struct.y_pos(kin_idx,1),...
                '-','Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubPos);
            hDotsPos((iField-1)*num_bumps + iBump) = plot(UF_struct.x_pos(kin_idx,1),UF_struct.y_pos(kin_idx,1),...
                '.','Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubPos);
            hMeanPosX((iField-1)*num_bumps + iBump) = plot([x_pos_mean-x_pos_sem x_pos_mean+x_pos_sem],[y_pos_mean y_pos_mean],...
                '-','LineWidth',4,'Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubPos);
            hMeanPosY((iField-1)*num_bumps + iBump) = plot([x_pos_mean x_pos_mean],[y_pos_mean-y_pos_sem y_pos_mean+y_pos_sem],...
                '-','LineWidth',4,'Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubPos);       

            hLinesForce((iField-1)*num_bumps + iBump) = plot(UF_struct.x_force(kin_idx,1),UF_struct.y_force(kin_idx,1),...
                '-','Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubForce);
            hDotsForce((iField-1)*num_bumps + iBump) = plot(UF_struct.x_force(kin_idx,1),UF_struct.y_force(kin_idx,1),...
                '.','Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubForce); 
            hMeanForceX((iField-1)*num_bumps + iBump) = plot([x_force_mean-x_force_sem x_force_mean+x_force_sem],[y_force_mean y_force_mean],...
                '-','LineWidth',4,'Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubForce);     
            hMeanForceY((iField-1)*num_bumps + iBump) = plot([x_force_mean x_force_mean],[y_force_mean-y_force_sem y_force_mean+y_force_sem],...
                '-','LineWidth',4,'Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubForce); 

            hLinesEMG((iField-1)*num_bumps + iBump) = plot(UF_struct.emg_all(1,kin_idx,1),UF_struct.emg_all(2,kin_idx,1),...
                '-','Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubEMG);
            hDotsEMG((iField-1)*num_bumps + iBump) = plot(UF_struct.emg_all(1,kin_idx,1),UF_struct.emg_all(2,kin_idx,1),...
                '.','Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubEMG); 
            hMeanEMGX((iField-1)*num_bumps + iBump) = plot([emg_1_mean-emg_1_sem emg_1_mean+emg_1_sem],[emg_2_mean emg_2_mean],...
                '-','LineWidth',4,'Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubEMG);     
            hMeanEMGY((iField-1)*num_bumps + iBump) = plot([emg_1_mean emg_1_mean],[emg_2_mean-emg_2_sem emg_2_mean+emg_2_sem],...
                '-','LineWidth',4,'Color',UF_struct.colors_field_bump((iField-1)*num_bumps + iBump,:),'Parent',hSubEMG);

            drawnow
        end
    end
end

if ~show_dots
    set(hDotsNeurons,'Visible','off')
    set(hDotsPos,'Visible','off')
    set(hDotsForce,'Visible','off')
    set(hDotsEMG,'Visible','off')
end
for iT = 2:length(UF_struct.t_axis)
    for iBump = 1:length(UF_struct.bump_indexes)
        for iField = 1:length(UF_struct.field_indexes)
           temp = intersect(UF_struct.field_indexes{iField},UF_struct.bump_indexes{iBump});
           [kin_idx,idx,~] = intersect(interesting_idx,temp);      
            
            if ~isempty(idx)
                f1_mean = mean(f1(idx,:));
                f1_sem = 1.96*std(f1(idx,:))/sqrt(length(idx));
                f2_mean = mean(f2(idx,:));
                f2_sem = 1.96*std(f2(idx,:))/sqrt(length(idx));
                f3_mean = mean(f3(idx,:));
                f3_sem = 1.96*std(f3(idx,:))/sqrt(length(idx));

                x_pos_mean = mean(UF_struct.x_pos(kin_idx,:));
                x_pos_sem = 1.96*std(UF_struct.x_pos(kin_idx,:))/sqrt(length(kin_idx));    
                y_pos_mean = mean(UF_struct.y_pos(kin_idx,:));
                y_pos_sem = 1.96*std(UF_struct.y_pos(kin_idx,:))/sqrt(length(kin_idx));
                x_force_mean = mean(UF_struct.x_force(kin_idx,:));
                x_force_sem = 1.96*std(UF_struct.x_force(kin_idx,:))/sqrt(length(kin_idx));
                y_force_mean = mean(UF_struct.y_force(kin_idx,:));
                y_force_sem = 1.96*std(UF_struct.y_force(kin_idx,:))/sqrt(length(kin_idx));

                emg_1_mean = squeeze(smooth(mean(UF_struct.emg_all(1,kin_idx,:)),20));
                emg_1_sem = squeeze(smooth(std(UF_struct.emg_all(1,kin_idx,:)),20))/sqrt(length(kin_idx));
                emg_2_mean = squeeze(smooth(mean(UF_struct.emg_all(2,kin_idx,:)),20));
                emg_2_sem = squeeze(smooth(std(UF_struct.emg_all(2,kin_idx,:)),20))/sqrt(length(kin_idx));

                set(hLinesNeurons((iField-1)*num_bumps + iBump),'XData',mean(f1(idx,(1:iT))))
                set(hLinesNeurons((iField-1)*num_bumps + iBump),'YData',mean(f2(idx,(1:iT))))
                set(hLinesNeurons((iField-1)*num_bumps + iBump),'ZData',mean(f3(idx,(1:iT))))

                set(hDotsNeurons((iField-1)*num_bumps + iBump),'XData',f1(idx,iT))
                set(hDotsNeurons((iField-1)*num_bumps + iBump),'YData',f2(idx,iT))
                set(hDotsNeurons((iField-1)*num_bumps + iBump),'ZData',f3(idx,iT))    

                set(hMeanNeuronsX((iField-1)*num_bumps + iBump),'XData',[f1_mean(iT)-f1_sem(iT) f1_mean(iT)+f1_sem(iT)])
                set(hMeanNeuronsX((iField-1)*num_bumps + iBump),'YData',[f2_mean(iT) f2_mean(iT)])
                set(hMeanNeuronsX((iField-1)*num_bumps + iBump),'ZData',[f3_mean(iT) f3_mean(iT)])

                set(hMeanNeuronsY((iField-1)*num_bumps + iBump),'XData',[f1_mean(iT) f1_mean(iT)])
                set(hMeanNeuronsY((iField-1)*num_bumps + iBump),'YData',[f2_mean(iT)-f2_sem(iT) f2_mean(iT)+f2_sem(iT)])
                set(hMeanNeuronsY((iField-1)*num_bumps + iBump),'ZData',[f3_mean(iT) f3_mean(iT)])

                set(hMeanNeuronsZ((iField-1)*num_bumps + iBump),'XData',[f1_mean(iT) f1_mean(iT)])
                set(hMeanNeuronsZ((iField-1)*num_bumps + iBump),'YData',[f2_mean(iT) f2_mean(iT)])
                set(hMeanNeuronsZ((iField-1)*num_bumps + iBump),'ZData',[f3_mean(iT)-f3_sem(iT) f3_mean(iT)+f3_sem(iT)])

                set(hDotsPos((iField-1)*num_bumps + iBump),'XData',UF_struct.x_pos(kin_idx,iT));
                set(hDotsPos((iField-1)*num_bumps + iBump),'YData',UF_struct.y_pos(kin_idx,iT));

                set(hLinesPos((iField-1)*num_bumps + iBump),'XData',x_pos_mean(1:iT),'YData',y_pos_mean(1:iT));

                set(hMeanPosX((iField-1)*num_bumps + iBump),'XData',[x_pos_mean(iT)-x_pos_sem(iT) x_pos_mean(iT)+x_pos_sem(iT)])
                set(hMeanPosX((iField-1)*num_bumps + iBump),'YData',[y_pos_mean(iT) y_pos_mean(iT)])

                set(hMeanPosY((iField-1)*num_bumps + iBump),'XData',[x_pos_mean(iT) x_pos_mean(iT)])
                set(hMeanPosY((iField-1)*num_bumps + iBump),'YData',[y_pos_mean(iT)-y_pos_sem(iT) y_pos_mean(iT)+y_pos_sem(iT)])

                set(hDotsForce((iField-1)*num_bumps + iBump),'XData',UF_struct.x_force(kin_idx,iT));
                set(hDotsForce((iField-1)*num_bumps + iBump),'YData',UF_struct.y_force(kin_idx,iT));

                set(hLinesForce((iField-1)*num_bumps + iBump),'XData',x_force_mean(1:iT),'YData',y_force_mean(1:iT));

                set(hMeanForceX((iField-1)*num_bumps + iBump),'XData',[x_force_mean(iT)-x_force_sem(iT) x_force_mean(iT)+x_force_sem(iT)])
                set(hMeanForceX((iField-1)*num_bumps + iBump),'YData',[y_force_mean(iT) y_force_mean(iT)])

                set(hMeanForceY((iField-1)*num_bumps + iBump),'XData',[x_force_mean(iT) x_force_mean(iT)])
                set(hMeanForceY((iField-1)*num_bumps + iBump),'YData',[y_force_mean(iT)-y_force_sem(iT) y_force_mean(iT)+y_force_sem(iT)])

                % EMG
                set(hDotsEMG((iField-1)*num_bumps + iBump),'XData',UF_struct.emg_all(1,kin_idx,iT));
                set(hDotsEMG((iField-1)*num_bumps + iBump),'YData',UF_struct.emg_all(2,kin_idx,iT));

                set(hLinesEMG((iField-1)*num_bumps + iBump),'XData',emg_1_mean(1:iT),'YData',emg_2_mean(1:iT));

                set(hMeanEMGX((iField-1)*num_bumps + iBump),'XData',[emg_1_mean(iT)-emg_1_sem(iT) emg_1_mean(iT)+emg_1_sem(iT)])
                set(hMeanEMGX((iField-1)*num_bumps + iBump),'YData',[emg_2_mean(iT) emg_2_mean(iT)])

                set(hMeanEMGY((iField-1)*num_bumps + iBump),'XData',[emg_1_mean(iT) emg_1_mean(iT)])
                set(hMeanEMGY((iField-1)*num_bumps + iBump),'YData',[emg_2_mean(iT)-emg_2_sem(iT) emg_2_mean(iT)+emg_2_sem(iT)])
            end
        end
    end
    title(['t = ' num2str(UF_struct.t_axis(iT)) ' s'])
    drawnow
    pause(.05)    
end
