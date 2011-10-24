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

f = bdf.force(:,[2 3]) - repmat(mean(bdf.force(:,[2 3])), length(bdf.force), 1);
P = sum(f .* bdf.vel(:,[2 3]),2);

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

trial_x = (trial_dirs==0) - (trial_dirs==2);
trial_y = (trial_dirs==1) - (trial_dirs==3);
trial_v = (trial_types==1) - (trial_types==0);
trial_spec = [trial_x trial_y trial_v];
trial_spec = trial_spec ./ repmat(sqrt(sum( trial_spec.^2, 2 )), 1, size(trial_spec,2));

pds = zeros(length(ul), 3);
for unitNumber = 1:length(ul)
    pds(unitNumber,:) = mean(trial_spec .*  repmat(q(:,unitNumber), 1, 3));
end

pds = pds ./ repmat(sqrt(sum( pds.^2, 2)), 1, size(pds,2));


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


Pt = zeros(size(t,2), size(bumpreaches,1));
for trial = 1:length(bumpreaches)
    start = find(bumpreaches(trial,4)-.5 < bdf.vel(:,1),1,'first');
    Pt(:,trial) = decimate( P(start:start+1500) , 5 );
end

fr_bump = zeros(size(ul,1), size(t,2), size(bumptrials,1));
for unit = 1:size(ul,1)
    table = raster(get_unit(bdf, ul(unit,1), ul(unit,2)), bumptrials(:,4), -1.5, 2, -1);
    for trial = 1:length(bumptrials)
        spikes = table{trial};
        for i = 1:length(spikes)
            spike = spikes(i);
            fr_bump(unit, :, trial) = fr_bump(unit, :, trial) + ...
                exp( - (t-spike).^2 / (2*kernel_sigma.^2) )./sqrt(2*pi*kernel_sigma^2);  
        end
    end
end

fr_reach = zeros(size(ul,1), size(t,2), size(reachtrials,1));
for unit = 1:size(ul,1)
    table = raster(get_unit(bdf, ul(unit,1), ul(unit,2)), reachtrials(:,8), -1.5, 2, -1);
    for trial = 1:length(reachtrials)
        spikes = table{trial};
        for i = 1:length(spikes)
            spike = spikes(i);
            fr_reach(unit, :, trial) = fr_reach(unit, :, trial) + ...
                exp( - (t-spike).^2 / (2*kernel_sigma.^2) )./sqrt(2*pi*kernel_sigma^2);  
        end
    end
end

%% Plot loop
if 0
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

for trial = 1:20%length(bumpreaches)
    proj = fr(:,:,trial)' * pds;
    %plot3(proj(tp2:tp,1), proj(tp2:tp,2), proj(tp2:tp,3), '-','Color', ltcol(bumpreaches(trial,2)+1,:));
    plot3(proj(tp2:tp,1), proj(tp2:tp,2), proj(tp2:tp,3), 'o',  'MarkerFaceColor', colors(bumpreaches(trial,2)+1,:), ...
        'MarkerEdgeColor', [.5 .5 .5], 'LineWidth', 1);
end

%axis([-50 200 -100 100 -100 100]);
%view([10 83]);
view([-3 41]);
title(t(tp));

figure; hold on;
tp = 176;
tp2 = 115;
tp3 = 80;

for trial = 1:6%length(bumpreaches)
    proj = fr(:,:,trial)' * pds;
    %plot3(proj(tp2:tp,1), proj(tp2:tp,2), proj(tp2:tp,3), '-','Color', ltcol(bumpreaches(trial,2)+1,:));
    plot3(proj(tp3:tp2,1), proj(tp3:tp2,2), proj(tp3:tp2,3), 'o',  'MarkerFaceColor', colors(bumpreaches(trial,2)+1,:), ...
        'MarkerEdgeColor', [.5 .5 .5], 'LineWidth', 1);
    plot3(proj(tp2:tp,1), proj(tp2:tp,2), proj(tp2:tp,3), 'o',  'MarkerFaceColor', colors(bumpreaches(trial,5)+1,:), ...
        'MarkerEdgeColor', [.5 .5 .5], 'LineWidth', 1);
end

%axis([-50 200 -100 100 -100 100]);
%view([10 83]);
view([-3 41]);
title(t(tp));


figure; hold on;
tp = 176;
tp2 = 115;

for trial = 1:length(bumpreaches)
    proj = fr(:,:,trial)' * pds;
    %plot3(proj(tp2:tp,1), proj(tp2:tp,2), proj(tp2:tp,3), '-','Color', ltcol(bumpreaches(trial,5)+1,:));
    plot3(proj(tp2,1), proj(tp2,2), proj(tp2,3), 'o',  'MarkerFaceColor', 'none', ...
        'MarkerEdgeColor', [.5 .5 .5], 'LineWidth', 1);
    plot3(proj(tp,1), proj(tp,2), proj(tp,3), 'o',  'MarkerFaceColor', colors(bumpreaches(trial,2)+1,:), ...
        'MarkerEdgeColor', colors(bumpreaches(trial,2)+1,:), 'LineWidth', 1);
end


axis([-50 200 -100 100 -100 100]);
%view([94 -65]);
%view([10 83]);
view([-3 41]);
title(t(tp));

end
%% v axis plot

x = zeros(length(bumpreaches), length(t));
y = zeros(length(bumpreaches), length(t));
v = zeros(length(bumpreaches), length(t));
for i = 1:length(bumpreaches)
    proj = fr(:,:,i)' * pds;
    %proj = proj - repmat(proj(1,:),length(proj),1);
    x(i,:) = proj(:,1)';
    y(i,:) = proj(:,2)';
    v(i,:) = proj(:,3)';
end


xb = zeros(length(bumptrials), length(t));
yb = zeros(length(bumptrials), length(t));
vb = zeros(length(bumptrials), length(t));
for i = 1:length(bumptrials)
    proj = fr_bump(:,:,i)' * pds;
    %proj = proj - repmat(proj(1,:),length(proj),1);
    xb(i,:) = proj(:,1)';
    yb(i,:) = proj(:,2)';
    vb(i,:) = proj(:,3)';
end

xr = zeros(length(reachtrials), length(t));
yr = zeros(length(reachtrials), length(t));
vr = zeros(length(reachtrials), length(t));
for i = 1:length(reachtrials)
    proj = fr_reach(:,:,i)' * pds;
    %proj = fr_reach(:,:,i)' * lambda;
    %proj = proj - repmat(proj(1,:),length(proj),1);
    xr(i,:) = proj(:,1)';
    yr(i,:) = proj(:,2)';
    vr(i,:) = proj(:,3)';
end

figure; hold on;
plot(t,mean(v-30),'k-');
plot(t,mean(v-30)+ sqrt(var(v-30)),'b-');
plot(t,mean(v-30)- sqrt(var(v-30)),'b-');
%plot(t,mean(vb-30),'b-');
%plot(t,mean(vr-30),'r-');
%plot(t,mean(vb-30)+mean(vr-30),'k--')

figure; hold on;
vr = vr-repmat(mean(vr(:,1:80),2),1,size(vr,2));
vb = vb-repmat(mean(vb(:,1:80),2),1,size(vr,2));
v = v-repmat(mean(v(:,1:80),2),1,size(vr,2));
vr2 = [repmat(vr(:,1),1,25) vr(:,1:end-25)];

plot(t,mean(v),'k-');
plot(t,mean(vb),'b-');
plot(t,mean(vr2),'r-');
plot(t,mean(vb)+mean(vr2),'k--')
