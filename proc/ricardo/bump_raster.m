function bump_raster(filename,monkey_array,unit_list)
load(filename,'bdf','trial_table')
electrode_pin = electrode_pin_mapping(monkey_array);

time_bin_fr = [.02 .1];
time_pre_bump = .2;
time_post_bump = .4;    
chan_unit = reshape([bdf.units(:).id],2,[])';

bump_table = trial_table(trial_table(:,4)==1,:);
bump_times = bdf.words(bdf.words(:,2)>=80 &...
        bdf.words(:,2)<90);
    
for i=1:length(bump_times)-1        
    bump_dirs(i,:) = [bump_times(i) bump_table(find(bump_table(:,1)>bump_times(i),1,'first'),6)];
end

for unit = 1:length(unit_list)
    figure;
    area([time_bin_fr(1) time_bin_fr(1) time_bin_fr(2) time_bin_fr(2)],...
        [0 2*pi 2*pi 0],'LineStyle','none','FaceColor',[1 .7 .7])
    hold on
    for i = 1:length(bump_dirs)
        unit_index = find(chan_unit(:,1)==unit_list(unit));
        time_bin = bdf.units(unit_index).ts(bdf.units(unit_index).ts>bump_dirs(i,1)-time_pre_bump &...
            bdf.units(unit_index).ts<bump_dirs(i,1)+time_post_bump)-bump_dirs(i,1);
        if ~isempty(time_bin)
            plot(time_bin,bump_dirs(i,2),'k.')
        end
        hold on
    end
    xlim([-time_pre_bump time_post_bump])
    ylim([0 2*pi])
    plot([0 0],[0 2*pi],'r')
    title([num2str(chan_unit(unit_index,1)) '-' num2str(chan_unit(unit_index,2))])
end