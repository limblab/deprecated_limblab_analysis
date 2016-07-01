function pds = wf_pds(bdf)

window_length = .5;

tt = wf_trial_table(bdf);
%tt(160,:) = [];

target_centers = [(tt(:,4)+tt(:,2))/2 (tt(:,5)+tt(:,3))/2];
rewards = tt( tt(:,9) == 82, 8);
targids = tt( tt(:,9) == 82, 10);

% map targids to target centers
tidlist = sort(unique(targids));
targmap = zeros(length(tidlist),4);
for i = 1:length(tidlist)
    target = target_centers(find(targids==i,1),:);
    targmap(i,:) = [atan2(target(2),target(1)) i target(1) target(2)];
end

ul = unit_list(bdf);
pds = zeros(length(ul),2);

figure;
for unit = 1:length(ul)
    [table, all, count] = raster(get_unit(bdf,ul(unit,1),ul(unit,2)), rewards, -window_length, 0, -1);
    count = count / window_length;
    
    f = zeros(max(targids),1);
    for tdir = 1:max(targids)
        f(tdir) = mean(count(targids==tdir));        
    end % foreach target direction
    
    tuning_curve = [targmap(:,1) f];
    pds(unit,:) = sum([tuning_curve(:,2).*targmap(:,3) tuning_curve(:,2).*targmap(:,4)]);
    
    tuning_curve = sortrows(tuning_curve,1);

    if mod(unit,9)==0
        figure;
    end
    subplot(3, 3, mod(unit,9)+1);
    polar([tuning_curve(:,1); tuning_curve(1,1)], [tuning_curve(:,2); tuning_curve(1,2)], 'ko-');
    hold on;
    plot([0 pds(unit,1)],[0 pds(unit,2)],'r-');
    
end % foreach unit

