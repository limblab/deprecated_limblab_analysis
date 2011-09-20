% fa methods figure
% Intended to be run with tiki_rw_006
% run fa_spread first

% Get tt if not set
if isempty(who('tt'))
    tt = co_trial_table(bdf);
end

% Clear except bdf and tt
vars = whos;
for i = 1:length(vars)
    if (~strcmp(vars(i).name,'bdf') && ~strcmp(vars(i).name,'tt') ...
            && ~strcmp(vars(i).name,'lambda') && ~strcmp(vars(i).name,'w'))
        clear(vars(i).name);
    end
end
clear i vars

% Get trial

trial = find( tt(:,2)==1 & tt(:,5)==3 & tt(:,10)==double('R') , 1, 'first');

start_idx = find(bdf.pos(:,1)>tt(trial,1),1);
end_idx = find(bdf.pos(:,1)>tt(trial,9),1)+1000;

t = bdf.pos(start_idx:end_idx,1) - tt(trial,7);
target_on = tt(trial,6) - tt(trial,7);
reward = tt(trial,9) - tt(trial,7);

figure;
subplot(6,1,1),plot(t, bdf.vel(start_idx:end_idx,2)+2, 'k-', target_on, 0, '*', reward, 0, '*');
axis([-2 1.5 -15 5]);

% rasters
ul = unit_list(bdf);

units_of_interest = [23 39 42];
rasters = [];
for uid=1:length(units_of_interest);
    chan = ul(units_of_interest(uid),1);
    unit = ul(units_of_interest(uid),2);
    [tmp, spikes] = raster(get_unit(bdf, chan, unit), tt(trial,7), -3, 5, -1);
    rasters = [rasters; uid*ones(size(spikes)) spikes];
end


figure; hold on;
for idx=1:length(rasters)
    line([rasters(idx,2) rasters(idx,2)], [rasters(idx,1)+.1 rasters(idx,1)+.9]);
end
return

subplot(6,1,2),plot(rasters(:,2), rasters(:,1), 'k.');
axis([-2 1.5 .5 3.5]);

% firing rates
kernel_sigma = 0.05;

frs = zeros(length(t), length(units_of_interest));

for unit=1:length(units_of_interest)
    spikes = rasters(rasters(:,1)==unit,2)';
    for spike = spikes
        frs(:,unit) = frs(:,unit) + ...
            exp( - (t-spike).^2 / (2*kernel_sigma.^2) )./sqrt(2*pi*kernel_sigma^2);        
    end
end

subplot(6,1,3),plot(t, frs(:,3), 'k-');
axis([-2 1.5 0 75]);
subplot(6,1,4),plot(t, frs(:,2), 'k-');
axis([-2 1.5 0 75]);
subplot(6,1,5),plot(t, frs(:,1), 'k-');
axis([-2 1.5 0 75]);

%% Get factor projection

% ps = zeros(length(t), length(ul));
% for unitNumber = 1:length(ul)
%     chan = ul(unitNumber, 1);
%     unit = ul(unitNumber, 2);
%     
%     [tmp, spikes] = raster(get_unit(bdf, chan, unit), tt(trial,7), -3, 3, -1);
%     
%     for spike = spikes'
%         ps(:, unitNumber) = ps(:, unitNumber) + ...
%             exp( - (t-spike).^2 / (2*kernel_sigma.^2) )./sqrt(2*pi*kernel_sigma^2);        
%     end
% end
% 
% q = ps * lambda * w;

q = 2*frs(:,3) + frs(:,2) - frs(:,1);

subplot(6,1,6),plot(t, q(:,1), 'k-');
axis([-2 1.5 -50 100]);

