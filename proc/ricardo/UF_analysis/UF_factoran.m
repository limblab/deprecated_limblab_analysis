function UF_factoran(UF_struct,save_figs)
show_dots = 1;
num_factors = 2;
interesting_idx = UF_struct.bump_indexes{3};
interesting_idx = [];

if isempty(interesting_idx)
    interesting_idx = 1:size(UF_struct.firingrates,1);
end

firingrates = UF_struct.firingrates(interesting_idx,:,:);
baseline = repmat(mean(mean(firingrates(:,1:find(UF_struct.t_axis<0,1,'last'),:),1),2),[size(firingrates,1) size(firingrates,2) 1]);
% baseline = 0;
firingrates = firingrates - baseline;

lambda_mean = zeros(20,size(firingrates,3),num_factors);
delete_idx = [];
for i = 1:30
    try
        lambda = factoran(squeeze(firingrates(:,find(UF_struct.t_axis>(.03+i*.001),1,'first'),:)),num_factors);
    catch
        delete_idx(end+1) = i;
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
x = zeros(size(firingrates,1),size(firingrates,2));
y = x;
z = x;
for iT = 1:length(UF_struct.t_axis)
     proj = squeeze(firingrates(:,iT,:)) * lambda(:,[1 2 3]);
     x(:,iT) = proj(:,1);
     y(:,iT) = proj(:,2);
     z(:,iT) = proj(:,3);     
end

clear hLines hDots hMean
figure; 
hold on
for iField = 1:length(UF_struct.field_indexes)
    [~,idx,~] = intersect(interesting_idx,UF_struct.field_indexes{iField});
    if ~isempty(idx)
        hLines(iField) = plot3(mean(x(idx,1)),...
            mean(y(idx,1)),...
            mean(z(idx,1)),'-','Color',UF_struct.colors_field(iField,:));
        hDots(iField) = plot3(x(idx,1),...
            y(idx,1),...
            z(idx,1),'.','Color',UF_struct.colors_field(iField,:));
        hMean(iField) = plot3(mean(x(idx,1)),...
            mean(y(idx,1)),...
            mean(z(idx,1)),...
            '*','MarkerSize',30,'Color',UF_struct.colors_field(iField,:));
        drawnow
    end
end
xlim([min(x(:)) max(x(:))])
ylim([min(y(:)) max(y(:))])
if num_factors>2
    zlim([min(z(:)) max(z(:))])
end
if ~show_dots
    set(hDots,'Visible','off')
end
for iT = 2:length(UF_struct.t_axis)
    for iField = 1:length(UF_struct.field_indexes)
        [~,idx,~] = intersect(interesting_idx,UF_struct.field_indexes{iField});
        if ~isempty(idx)
            set(hLines(iField),'XData',mean(x(idx,(1:iT))))
            set(hLines(iField),'YData',mean(y(idx,(1:iT))))
            set(hLines(iField),'ZData',mean(z(idx,(1:iT))))
            set(hDots(iField),'XData',x(idx,iT))
            set(hDots(iField),'YData',y(idx,iT))
            set(hDots(iField),'ZData',z(idx,iT))      
            set(hMean(iField),'XData',mean(x(idx,iT)))
            set(hMean(iField),'YData',mean(y(idx,iT)))
            set(hMean(iField),'ZData',mean(z(idx,iT)))
        end
    end
    title(num2str(UF_struct.t_axis(iT)))
    drawnow
    pause(.05)    
end

clear hLines hDots hMean
figure; 
hold on
for iBump = 1:length(UF_struct.bump_indexes)
    [~,idx,~] = intersect(interesting_idx,UF_struct.bump_indexes{iBump});
    if ~isempty(idx)
        hLines(iBump) = plot3(mean(x(idx,1)),...
            mean(y(idx,1)),...
            mean(z(idx,1)),'-','Color',UF_struct.colors_bump(iBump,:));
        hDots(iBump) = plot3(x(idx,1),...
            y(idx,1),...
            z(idx,1),'.','Color',UF_struct.colors_bump(iBump,:));
        hMean(iBump) = plot3(mean(x(idx,1)),...
            mean(y(idx,1)),...
            mean(z(idx,1)),...
            '*','MarkerSize',30,'Color',UF_struct.colors_bump(iBump,:));
        drawnow
    end
end
xlim([min(x(:)) max(x(:))])
ylim([min(y(:)) max(y(:))])
if num_factors>2
    zlim([min(z(:)) max(z(:))])
end

for iT = 2:length(UF_struct.t_axis)
    for iBump = 1:length(UF_struct.bump_indexes)
        [~,idx,~] = intersect(interesting_idx,UF_struct.bump_indexes{iBump});
        if ~isempty(idx)
            set(hLines(iBump),'XData',mean(x(idx,(1:iT))))
            set(hLines(iBump),'YData',mean(y(idx,(1:iT))))
            set(hLines(iBump),'ZData',mean(z(idx,(1:iT))))
            set(hDots(iBump),'XData',x(idx,iT))
            set(hDots(iBump),'YData',y(idx,iT))
            set(hDots(iBump),'ZData',z(idx,iT))
            set(hMean(iBump),'XData',mean(x(idx,iT)))
            set(hMean(iBump),'YData',mean(y(idx,iT)))
            set(hMean(iBump),'ZData',mean(z(idx,iT)))
        end
    end
    title(num2str(UF_struct.t_axis(iT)))
    drawnow
    pause(.1)    
end
