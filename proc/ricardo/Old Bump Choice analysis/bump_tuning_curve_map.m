function bump_tuning_curve_map(filename,monkey_array)

load(filename,'bdf','trial_table')

bump_table = trial_table(trial_table(:,4)==1,:);
electrode_pin = electrode_pin_mapping(monkey_array);

chan_unit = reshape([bdf.units(:).id],2,[])';
actual_units = length([bdf.units(:).id])/2;
actual_units = bdf.units(1:actual_units);
time_bin_fr = [.02 .1];
no_ranges = 8;
bump_times = bdf.words(bdf.words(:,2)>=80 &...
    bdf.words(:,2)<90);
bump_dirs = zeros(length(bump_times)-1,2);
firing_rate_matrix = zeros(length(bump_dirs),length(actual_units));
mean_firing_rate = firing_rate_matrix;
pd_vector = zeros(length(actual_units),2);

for i=1:length(bump_times)-1        
    bump_dirs(i,:) = [bump_times(i) bump_table(find(bump_table(:,1)>bump_times(i),1,'first'),6)];
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

figure;
for unit = 1:length(actual_units)        
    if sum(binned_fr_matrix(:,unit))~=0
        subplot(10,10,electrode_pin(electrode_pin(:,2)==actual_units(unit).id(1),1))
        x_points = cos(0:2*pi/no_ranges:2*pi-1/no_ranges).*binned_fr_matrix(:,unit)';
        y_points = sin(0:2*pi/no_ranges:2*pi-1/no_ranges).*binned_fr_matrix(:,unit)';
        pd_vector(unit,:) = sum([x_points' y_points']);
        x_points(end+1) = x_points(1);
        y_points(end+1) = y_points(1);
        plot(x_points,y_points);
        hold on
        plot(cos(0:2*pi/50:2*pi)*mean(binned_fr_matrix(:,unit)),...
            sin(0:2*pi/50:2*pi)*mean(binned_fr_matrix(:,unit)),'r')
        plot(cos(0:2*pi/50:2*pi)*mean_firing_rate(unit),...
            sin(0:2*pi/50:2*pi)*mean_firing_rate(unit),'k')
        plot([0 pd_vector(unit,1)],[0 pd_vector(unit,2)],'k-');
        limits = max(max(abs(x_points)),max(abs(y_points)));
        xlim([-1.1*limits 1.1*limits])
        ylim([-1.1*limits 1.1*limits])
        title(num2str(chan_unit(unit,1)))
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        text(-limits,-.75*limits,num2str(mean(binned_fr_matrix(:,unit)),2),'Color','r')
    end
end
chans_with_units = unique(chan_unit(:,1));
for i=1:length(chans_with_units)
    mean(pd_vector(chan_unit(:,1)==chans_with_units(i),:));
end
subplot(10,10,1)
text(0,1,'Bump FR','Color','b')
text(0,.6,'Mean bump FR','Color','r')
text(0,.2,'Baseline FR','Color','k')
xlim([0 1])
ylim([0 1])
axis off   