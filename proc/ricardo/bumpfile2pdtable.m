function table = bumpfile2pdtable(filename)

% table = [chan unit pd modulation];

if ~exist([filename '.mat'],'file')    
    curr_dir = pwd;
    cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
    bdf = get_plexon_data([filename '.plx'],2);
    save(filename,'bdf');
    cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\';
    trial_table = BC_build_trial_table(filename);    
    cd(curr_dir)
else
    load(filename,'trial_table','bdf')
end

trial_table = trial_table(trial_table(:,5)==0,:); % remove training trials


%% bump triggered firing rate

chan_unit = reshape([bdf.units(:).id],2,[])';
actual_units = length([bdf.units(:).id])/2;
actual_units = bdf.units(1:actual_units);
%     time_bin_length = .100;
time_bin_fr = [.02 .1];
no_ranges = 8;
bump_times = bdf.words(bdf.words(:,2)>=80&...
    bdf.words(:,2)<90);
bump_dirs = zeros(length(bump_times)-1,2);
firing_rate_matrix = zeros(length(bump_dirs),length(actual_units));
mean_firing_rate = firing_rate_matrix;
pd_vector = zeros(length(actual_units),2);

for i=1:length(bump_times)-1        
    bump_dirs(i,:) = [bump_times(i) trial_table(find(trial_table(:,1)>bump_times(i),1,'first'),6)];
end

for i = 1:length(actual_units)
    for j = 1:length(bump_dirs)
        firing_rate_matrix(j,i) = sum(bdf.units(i).ts>bump_dirs(j,1)+time_bin_fr(1) &...
            bdf.units(i).ts<bump_dirs(j,1)+time_bin_fr(2))/(time_bin_fr(2)-time_bin_fr(1));
        mean_firing_rate(j,i) = sum(bdf.units(i).ts>bump_dirs(j,1)-(time_bin_fr(2)-time_bin_fr(1)) &...
            bdf.units(i).ts<bump_dirs(j,1))/(time_bin_fr(2)-time_bin_fr(1));
    end
end 
mean_firing_rate = mean(mean_firing_rate);

binned_fr_matrix = zeros(no_ranges,length(actual_units));
binned_fr_matrix_std = zeros(no_ranges,length(actual_units));
for i = 1:no_ranges
    binned_fr_matrix(i,:) = mean(firing_rate_matrix(find(bump_dirs(:,2)>=(i-1)*2*pi/no_ranges &...
        bump_dirs(:,2)<i*2*pi/no_ranges),:));
    binned_fr_matrix_std(i,:) = std(firing_rate_matrix(find(bump_dirs(:,2)>=(i-1)*2*pi/no_ranges &...
        bump_dirs(:,2)<i*2*pi/no_ranges),:));
end

for unit = 1:length(actual_units)        
    if sum(binned_fr_matrix(:,unit))~=0        
        x_points = cos(0:2*pi/no_ranges:2*pi-1/no_ranges).*binned_fr_matrix(:,unit)';
        y_points = sin(0:2*pi/no_ranges:2*pi-1/no_ranges).*binned_fr_matrix(:,unit)';
        pd_vector(unit,:) = sum([x_points' y_points']);  
    end
end

modulation = sqrt(pd_vector(:,1).^2 + pd_vector(:,2).^2)./mean(binned_fr_matrix)';
modulation(isnan(modulation))=0;
modulation = (modulation-min(modulation))/(.75*max(modulation-min(modulation)));
modulation = min(1,modulation);
pref_dirs = atan2(pd_vector(:,2),pd_vector(:,1));
pref_dirs(pref_dirs<0) = 2*pi+pref_dirs(pref_dirs<0);

table = [chan_unit pref_dirs modulation];