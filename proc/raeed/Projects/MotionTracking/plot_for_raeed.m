medians=kinect_pos;

xlims=[min(min(medians(:,1,:))) max(max(medians(:,1,:)))];
ylims=[min(min(medians(:,2,:))) max(max(medians(:,2,:)))];
zlims=[min(min(medians(:,3,:))) max(max(medians(:,3,:)))];

figure;
set(gca,'NextPlot','replacechildren');
xlim(xlims)
ylim(ylims)
zlim(zlims)

plot_colors=[1 0 0; 0 1 0; 0 0 1; 1 1 0; 0 1 1; 1 0 1; 0 0 0; 1 .5 0; .5 0 1; 0 1 .5; 0 0 0];

t = kinect_times;
handle_pos = interp1(bdf.pos(:,1),bdf.pos(:,2:3),t);

% vid=[];    
for i=100:200
    scatter3(medians(:,1,i),medians(:,2,i),medians(:,3,i),200,plot_colors,'filled')
    
%     pause;
    title(t(i))
    
    hold on
    start_ind = max(1,i-60);
    plot3(handle_pos(start_ind:i,1),handle_pos(start_ind:i,2),zeros(i-start_ind+1,1),'-b')
    hold off
    
    view([58.1250 36.9294])
    xlim(xlims)
    ylim(ylims)
    zlim(zlims)

    pause(.03)
    
end

%%
medians=kinect_pos;

xlims=[min(min(medians(:,1,:))) max(max(medians(:,1,:)))];
ylims=[min(min(medians(:,2,:))) max(max(medians(:,2,:)))];

figure;
set(gca,'NextPlot','replacechildren');
xlim(xlims)
ylim(ylims)

plot_colors=[1 0 0; 0 1 0; 0 0 1; 1 1 0; 0 1 1; 1 0 1; 0 0 0; 1 .5 0; .5 0 1; 0 1 .5; 0 0 0];

for i=1:2000
    scatter(medians(:,1,i),medians(:,2,i),200,plot_colors,'filled')
%     view([0.8, 0.1, -0.1 ])
    pause(.03)
%     pause;
    title(i)

    
end

%%
medians=kinect_pos;

xlims=[min(min(medians(:,1,:))) max(max(medians(:,1,:)))];
ylims=[min(min(medians(:,2,:))) max(max(medians(:,2,:)))];
zlims=[min(min(medians(:,3,:))) max(max(medians(:,3,:)))];

figure;
set(gca,'NextPlot','replacechildren');
xlim(xlims)
ylim(ylims)
zlim(zlims)

plot_colors=[1 0 0; 0 1 0; 0 0 1; 1 1 0; 0 1 1; 1 0 1; 0 0 0; 1 .5 0; .5 0 1; 0 1 .5; 0 0 0];

% vid=[];    
for i=1:100
%     subplot(221)
    scatter3(medians(:,1,i),medians(:,2,i),medians(:,3,i),200,plot_colors,'filled')
    view([58.1250 36.9294])
%     axis equal
    title(i/30)
    
%     subplot(222)
%     scatter(medians(:,1,i),medians(:,2,i),200,plot_colors,'filled')
%     axis equal
%     title 'Top down'
%     
%     subplot(223)
%     scatter(medians(:,2,i),medians(:,3,i),200,plot_colors,'filled')
%     axis equal
%     title 'Behind'
%     
%     subplot(224)
%     scatter(medians(:,1,i),medians(:,3,i),200,plot_colors,'filled')
%     axis equal
%     title 'Side'
    
    pause(.03)
end