function UF_factoran(UF_struct,interesting_idx,factor_offset,save_figs)
show_dots = 1;
num_factors = 2;

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
xlabel('EMG BI (a.u.)')
ylabel('EMG TRI (a.u.)')
hold on

for iBump = 1:length(UF_struct.bump_indexes)
    [kin_idx,idx,~] = intersect(interesting_idx,UF_struct.bump_indexes{iBump});
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
        hLinesNeurons(iBump) = plot3(f1_mean,f2_mean,f3_mean,...
            '-','Color',UF_struct.colors_bump(iBump,:),'Parent',hSubNeurons);
        hDotsNeurons(iBump) = plot3(f1(idx,1),...
            f2(idx,1),...
            f3(idx,1),'.','Color',UF_struct.colors_bump(iBump,:),'Parent',hSubNeurons);
        hMeanNeuronsX(iBump) = plot3([f1_mean-f1_sem f1_mean+f1_sem],...
            [f2_mean f2_mean],[f3_mean f3_mean],...
            '-','LineWidth',4,'Color',UF_struct.colors_bump(iBump,:),'Parent',hSubNeurons);
        hMeanNeuronsY(iBump) = plot3([f1_mean f1_mean],...
            [f2_mean-f2_sem f2_mean+f2_sem],[f3_mean f3_mean],...
            '-','LineWidth',4,'Color',UF_struct.colors_bump(iBump,:),'Parent',hSubNeurons);
        hMeanNeuronsZ(iBump) = plot3([f1_mean f1_mean],...
            [f2_mean f2_mean],[f3_mean-f3_sem f3_mean+f3_sem],...
            '-','LineWidth',4,'Color',UF_struct.colors_bump(iBump,:),'Parent',hSubNeurons);
        
        hLinesPos(iBump) = plot(UF_struct.x_pos(kin_idx,1),UF_struct.y_pos(kin_idx,1),...
            '-','Color',UF_struct.colors_bump(iBump,:),'Parent',hSubPos);
        hDotsPos(iBump) = plot(UF_struct.x_pos(kin_idx,1),UF_struct.y_pos(kin_idx,1),...
            '.','Color',UF_struct.colors_bump(iBump,:),'Parent',hSubPos);
        hMeanPosX(iBump) = plot([x_pos_mean-x_pos_sem x_pos_mean+x_pos_sem],[y_pos_mean y_pos_mean],...
            '-','LineWidth',4,'Color',UF_struct.colors_bump(iBump,:),'Parent',hSubPos);
        hMeanPosY(iBump) = plot([x_pos_mean x_pos_mean],[y_pos_mean-y_pos_sem y_pos_mean+y_pos_sem],...
            '-','LineWidth',4,'Color',UF_struct.colors_bump(iBump,:),'Parent',hSubPos);       
        
        hLinesForce(iBump) = plot(UF_struct.x_force(kin_idx,1),UF_struct.y_force(kin_idx,1),...
            '-','Color',UF_struct.colors_bump(iBump,:),'Parent',hSubForce);
        hDotsForce(iBump) = plot(UF_struct.x_force(kin_idx,1),UF_struct.y_force(kin_idx,1),...
            '.','Color',UF_struct.colors_bump(iBump,:),'Parent',hSubForce); 
        hMeanForceX(iBump) = plot([x_force_mean-x_force_sem x_force_mean+x_force_sem],[y_force_mean y_force_mean],...
            '-','LineWidth',4,'Color',UF_struct.colors_bump(iBump,:),'Parent',hSubForce);     
        hMeanForceY(iBump) = plot([x_force_mean x_force_mean],[y_force_mean-y_force_sem y_force_mean+y_force_sem],...
            '-','LineWidth',4,'Color',UF_struct.colors_bump(iBump,:),'Parent',hSubForce); 
        
        hLinesEMG(iBump) = plot(UF_struct.emg_all(1,kin_idx,1),UF_struct.emg_all(2,kin_idx,1),...
            '-','Color',UF_struct.colors_bump(iBump,:),'Parent',hSubEMG);
        hDotsEMG(iBump) = plot(UF_struct.emg_all(1,kin_idx,1),UF_struct.emg_all(2,kin_idx,1),...
            '.','Color',UF_struct.colors_bump(iBump,:),'Parent',hSubEMG); 
        hMeanEMGX(iBump) = plot([emg_1_mean-emg_1_sem emg_1_mean+emg_1_sem],[emg_2_mean emg_2_mean],...
            '-','LineWidth',4,'Color',UF_struct.colors_bump(iBump,:),'Parent',hSubEMG);     
        hMeanEMGY(iBump) = plot([emg_1_mean emg_1_mean],[emg_2_mean-emg_2_sem emg_2_mean+emg_2_sem],...
            '-','LineWidth',4,'Color',UF_struct.colors_bump(iBump,:),'Parent',hSubEMG);
        
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
    for iBump = 1:length(UF_struct.bump_indexes)
        [kin_idx,idx,~] = intersect(interesting_idx,UF_struct.bump_indexes{iBump});
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
            
            set(hLinesNeurons(iBump),'XData',mean(f1(idx,(1:iT))))
            set(hLinesNeurons(iBump),'YData',mean(f2(idx,(1:iT))))
            set(hLinesNeurons(iBump),'ZData',mean(f3(idx,(1:iT))))
            
            set(hDotsNeurons(iBump),'XData',f1(idx,iT))
            set(hDotsNeurons(iBump),'YData',f2(idx,iT))
            set(hDotsNeurons(iBump),'ZData',f3(idx,iT))    
            
            set(hMeanNeuronsX(iBump),'XData',[f1_mean(iT)-f1_sem(iT) f1_mean(iT)+f1_sem(iT)])
            set(hMeanNeuronsX(iBump),'YData',[f2_mean(iT) f2_mean(iT)])
            set(hMeanNeuronsX(iBump),'ZData',[f3_mean(iT) f3_mean(iT)])
            
            set(hMeanNeuronsY(iBump),'XData',[f1_mean(iT) f1_mean(iT)])
            set(hMeanNeuronsY(iBump),'YData',[f2_mean(iT)-f2_sem(iT) f2_mean(iT)+f2_sem(iT)])
            set(hMeanNeuronsY(iBump),'ZData',[f3_mean(iT) f3_mean(iT)])
            
            set(hMeanNeuronsZ(iBump),'XData',[f1_mean(iT) f1_mean(iT)])
            set(hMeanNeuronsZ(iBump),'YData',[f2_mean(iT) f2_mean(iT)])
            set(hMeanNeuronsZ(iBump),'ZData',[f3_mean(iT)-f3_sem(iT) f3_mean(iT)+f3_sem(iT)])
            
            set(hDotsPos(iBump),'XData',UF_struct.x_pos(kin_idx,iT));
            set(hDotsPos(iBump),'YData',UF_struct.y_pos(kin_idx,iT));
            
            set(hLinesPos(iBump),'XData',x_pos_mean(1:iT),'YData',y_pos_mean(1:iT));
            
            set(hMeanPosX(iBump),'XData',[x_pos_mean(iT)-x_pos_sem(iT) x_pos_mean(iT)+x_pos_sem(iT)])
            set(hMeanPosX(iBump),'YData',[y_pos_mean(iT) y_pos_mean(iT)])
            
            set(hMeanPosY(iBump),'XData',[x_pos_mean(iT) x_pos_mean(iT)])
            set(hMeanPosY(iBump),'YData',[y_pos_mean(iT)-y_pos_sem(iT) y_pos_mean(iT)+y_pos_sem(iT)])
            
            set(hDotsForce(iBump),'XData',UF_struct.x_force(kin_idx,iT));
            set(hDotsForce(iBump),'YData',UF_struct.y_force(kin_idx,iT));
            
            set(hLinesForce(iBump),'XData',x_force_mean(1:iT),'YData',y_force_mean(1:iT));
            
            set(hMeanForceX(iBump),'XData',[x_force_mean(iT)-x_force_sem(iT) x_force_mean(iT)+x_force_sem(iT)])
            set(hMeanForceX(iBump),'YData',[y_force_mean(iT) y_force_mean(iT)])
            
            set(hMeanForceY(iBump),'XData',[x_force_mean(iT) x_force_mean(iT)])
            set(hMeanForceY(iBump),'YData',[y_force_mean(iT)-y_force_sem(iT) y_force_mean(iT)+y_force_sem(iT)])
            
            % EMG
            set(hDotsEMG(iBump),'XData',UF_struct.emg_all(1,kin_idx,iT));
            set(hDotsEMG(iBump),'YData',UF_struct.emg_all(2,kin_idx,iT));
            
            set(hLinesEMG(iBump),'XData',emg_1_mean(1:iT),'YData',emg_2_mean(1:iT));
            
            set(hMeanEMGX(iBump),'XData',[emg_1_mean(iT)-emg_1_sem(iT) emg_1_mean(iT)+emg_1_sem(iT)])
            set(hMeanEMGX(iBump),'YData',[emg_2_mean(iT) emg_2_mean(iT)])
            
            set(hMeanEMGY(iBump),'XData',[emg_1_mean(iT) emg_1_mean(iT)])
            set(hMeanEMGY(iBump),'YData',[emg_2_mean(iT)-emg_2_sem(iT) emg_2_mean(iT)+emg_2_sem(iT)])
        end
    end
    title(['t = ' num2str(UF_struct.t_axis(iT)) ' s'])
    drawnow
    pause(.05)    
end
