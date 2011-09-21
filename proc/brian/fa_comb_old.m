% preload bdf and trial table;

% Arthur_S1_018.mat
% mini_bumps_005-6.mat
% tiki_rw_006.mat
% Tiki_S1_b_005.mat
% Pedro_S1_011

% Clear except bdf and tt
vars = whos;
for i = 1:length(vars)
    if (~strcmp(vars(i).name,'bdf') && ~strcmp(vars(i).name,'tt'))
        %clear(vars(i).name);
    end
end
%clear i vars

kernel_sigma = .05;%.035;
t = -.5:0.005:1;

ul = unit_list(bdf);

nTargets = max(tt(:,5)) + 1;
bumptrials = tt( tt(:,3) == double('H'), : );
reachtrials = tt( tt(:,2) == -1 & tt(:,10) == double('R'), : );
table = cell(1,nTargets);


onsets = [ reachtrials(:,7); bumptrials(:,4) ];
trial_types = [zeros(size(reachtrials,1),1); ones(size(bumptrials,1),1)];
trial_dirs = [reachtrials(:,5); bumptrials(:,2)];
ps = cell(length(ul), length(onsets));
    
for unitNumber = 1:length(ul)
    chan = ul(unitNumber, 1);
    unit = ul(unitNumber, 2);
    
    table = raster(get_unit(bdf, chan, unit), onsets, -1.5, 2, -1);
    
    for trial = 1:length(table)    
        ps{unitNumber, trial} = zeros(size(t));
        for spike = table{trial}'
            ps{unitNumber, trial} = ps{unitNumber, trial} + ...
                exp( - (t-spike).^2 / (2*kernel_sigma.^2) )./sqrt(2*pi*kernel_sigma^2);        
        end
    end
end

%%
baseline = zeros(1,length(ul));
for unitNumber = 1:length(ul)
    tmp = zeros(1,length(onsets));
    for trial = 1:length(onsets)
        tmp(trial) = ps{unitNumber,trial}(:,1);
    end
    baseline(unitNumber) = mean(tmp);
end

q = [];
for unitNumber = 1:length(ul)
    tmp = [];
    for trial = 1:length(onsets)
        if trial_types(trial)
            tmp = [tmp; ps{unitNumber,trial}(:,116)-baseline(unitNumber)];
        else 
            tmp = [tmp; ps{unitNumber,trial}(:,180)-baseline(unitNumber)];
        end
    end
    q = [q tmp];
end

lambda = factoran([q;q+0.1*randn(size(q))],3);

%% Find projections

bumpreaches = tt( tt(:,2) ~= -1 & tt(:,5) ~= -1 & tt(:,10)==double('R') , : );

fr = zeros(size(ul,1), size(t,2), size(bumpreaches,1));
for unit = 1:size(ul,1)
    table = raster(get_unit(bdf, ul(unit,1), ul(unit,2)), bumpreaches(:,4), -1.5, 2, -1);
    for trial = 1:length(bumpreaches)
        spikes = table{trial};
        for i = 1:length(spikes)
            spike = spikes(i);
            fr(unit, :, trial) = fr(unit, :, trial) + ...
                exp( - (t-spike).^2 / (2*kernel_sigma.^2) )./sqrt(2*pi*kernel_sigma^2);  
        end
    end
end

%% Plot loop

colors = {'ko', 'bo', 'ro', 'go'};

%figure; hold on;
% for trial = 1:length(bumpreaches)
%     proj = fr(:,:,trial)' * lambda;
%     plot3(proj(116,1), proj(116,2), proj(116,3), colors{bumpreaches(trial,2)+1});
% end

%colors = {'k-', 'b-', 'r-', 'g-'};
% 
% for trial = 1:length(bumpreaches)
%     proj = fr(:,:,trial)' * lambda;
%     plot3(proj(116,1), proj(116,2), proj(116,3), colors{bumpreaches(trial,2)+1});
% end

%view([99 -65]);

%colors = {'ko', 'bo', 'ro', 'go'};
%lines = {'k-', 'b-', 'r-', 'g-'};

colors = [0 0 0; 0 0 1; 1 0 0; 0 1 0];
%colors2 = {[0 0 0], 'none', 'none', 'none'};
ltcol = [.5 .5 .5; .5 .5 1; 1 .5 .5; .5 1 .5];

timepoints = [80 115 176];

figure; hold on;
tp = 115;
tp2 = 80;

for trial = 1:length(bumpreaches)
    proj = fr(:,:,trial)' * lambda;
    %plot3(proj(tp2:tp,1), proj(tp2:tp,2), proj(tp2:tp,3), '-','Color', ltcol(bumpreaches(trial,2)+1,:));
    plot3(proj(tp,1), proj(tp,2), proj(tp,3), 'o',  'MarkerFaceColor', colors(bumpreaches(trial,2)+1,:), ...
        'MarkerEdgeColor', [.5 .5 .5], 'LineWidth', 1);
end

axis([-50 200 -100 100 -100 100]);
%view([10 83]);
view([-3 41]);
title(t(tp));



figure; hold on;
tp = 176;
tp2 = 115;

for trial = 1:length(bumpreaches)
    proj = fr(:,:,trial)' * lambda;
    %plot3(proj(tp2:tp,1), proj(tp2:tp,2), proj(tp2:tp,3), '-','Color', ltcol(bumpreaches(trial,5)+1,:));
    plot3(proj(tp2,1), proj(tp2,2), proj(tp2,3), 'o',  'MarkerFaceColor', 'none', ...
        'MarkerEdgeColor', [.5 .5 .5], 'LineWidth', 1);
    plot3(proj(tp,1), proj(tp,2), proj(tp,3), 'o',  'MarkerFaceColor', colors(bumpreaches(trial,2)+1,:), ...
        'MarkerEdgeColor', colors(bumpreaches(trial,5)+1,:), 'LineWidth', 1);
end


axis([-50 200 -100 100 -100 100]);
%view([94 -65]);
%view([10 83]);
view([-3 41]);
title(t(tp));

%% v axis plot

v = zeros(length(bumpreaches), length(t));
for i = 1:length(bumpreaches)
    proj = fr(:,:,i)' * lambda;
    v(i,:) = proj * w;
end


