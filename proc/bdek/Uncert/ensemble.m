trial_spikes = cell(length(trains),1);
spike_counts = zeros(length(trains),length(trials2));
for i = 1:length(trials2)
    for j = 1:length(trains)
        
        spikes = trains{j};
        time = trials2(i,4:5);
        trial_spikes{j} = [trial_spikes{j} ; spikes(spikes > time(1) & spikes < time(2))];
        
        spike_counts(j,i) = sum(spikes > time(1) & spikes < time(2));
        
    end
end

highvarspikecounts = spike_counts(:,high_var);
lowvarspikecounts = spike_counts(:,low_var);

figure; 
bar(1:length(trains),[mean(highvarspikecounts,2) mean(lowvarspikecounts,2)]);

trial_ind = zeros(length(trial_spikes),1);
norm_v = zeros(length(trial_spikes),4);
figure; hold on;
for i = 1:length(trial_spikes)
    
    trial_ind(i) = find(comp_tt(:,6) < trial_spikes(i), 1, 'last');
    BDFind = find(BDF.pos(:,1)< trial_spikes(i),1,'last');
    
    trial_type = comp_tt(trial_ind(i),3);
    xy = BDF.pos(BDFind,2:3);
    vxvy = BDF.vel(BDFind,2:3);
    norm_v(i,4) = sqrt(vxvy(1).^2 + vxvy(2).^2);
    norm_v(i,1:2) = vxvy ./ norm_v(i,4);
    
    
    if trial_type == 3.5
        
        norm_v(i,3) = 3.5;
        
        plot(xy(1),xy(2),'r.');
        quiver(xy(1),xy(2),norm_v(i,1),norm_v(i,2),'r');
        
    elseif trial_type == 0.5
        
        norm_v(i,3) = 0.5;
        
        plot(xy(1),xy(2),'b.');
        quiver(xy(1),xy(2),norm_v(i,1),norm_v(i,2),'b');
        
    else
        
        fprintf('Incorrect feedback var: spike at %.3f',trial_spikes(i));
    end
    
    clear xy trial_type
end


title('Movement direction at spike times');

norm_v = unique(norm_v,'rows');
av_dir_highvar = [mean(norm_v(norm_v(:,3)==3.5,1)) mean(norm_v(norm_v(:,3)==3.5,2))];
av_dir_lowvar = [mean(norm_v(norm_v(:,3)==0.5,1)) mean(norm_v(norm_v(:,3)==0.5,2))];
av_speed_highvar = mean(norm_v(norm_v(:,3)==3.5,4));
av_speed_lowvar = mean(norm_v(norm_v(:,3)==0.5,4));

unique_spiking_trials = unique(trial_ind);
non_spike_trials = 1:length(comp_tt);
non_spike_trials = non_spike_trials(~ismember(non_spike_trials,unique_spiking_trials));

lims = [xlim; ylim];
plot([lims(1,1) lims(1,2)],[-3 -3],'k--');
plot([lims(1,1) lims(1,2)],[6.5 6.5],'g--');


figure; hold on;

for i = 1:length(unique_spiking_trials)
    
    trial_type = comp_tt(unique_spiking_trials(i),3);
    trial_shift = comp_tt(unique_spiking_trials(i),2);
    movestart = find(BDF.pos(:,1)<comp_tt(unique_spiking_trials(i),6),1,'last');
    movestop = find(BDF.pos(:,1)>comp_tt(unique_spiking_trials(i),7),1,'first');
    
    if trial_type == 3.5
        plot(BDF.pos(movestart:movestop,2),BDF.pos(movestart:movestop,3),'g','LineWidth',0.5);
    elseif trial_type == 0.5
        plot(BDF.pos(movestart:movestop,2),BDF.pos(movestart:movestop,3),'g','LineWidth',0.5);
    else
        
        fprintf('Incorrect feedback var: spike at %.3f',trial_spikes(i));
    end
end

for i = 1:length(non_spike_trials)
    
    trial_type = comp_tt(non_spike_trials(i),3);
    trial_shift = comp_tt(non_spike_trials(i),2);
    movestart = find(BDF.pos(:,1)<comp_tt(non_spike_trials(i),6),1,'last');
    movestop = find(BDF.pos(:,1)>comp_tt(non_spike_trials(i),7),1,'first');
    
    if trial_type == 3.5
        plot(BDF.pos(movestart:movestop,2),BDF.pos(movestart:movestop,3),'k','LineWidth',0.1);
    elseif trial_type == 0.5
        plot(BDF.pos(movestart:movestop,2),BDF.pos(movestart:movestop,3),'k','LineWidth',0.1);
    else
        
        fprintf('Incorrect feedback var: spike at %.3f',trial_spikes(i));
    end
end
    
figure; quiver(0,0,av_speed_highvar*av_dir_highvar(1),av_speed_highvar*av_dir_highvar(2),'r');
hold on; quiver(0,0,av_speed_lowvar*av_dir_lowvar(1),av_speed_lowvar*av_dir_lowvar(2),'b');
legend(sprintf('%.1f%c\n%.1f cm/s',180/pi*atan2(av_dir_highvar(2),av_dir_highvar(1)),char(176),av_speed_highvar),...
       sprintf('%.1f%c\n%.1f cm/s',180/pi*atan2(av_dir_lowvar(2),av_dir_lowvar(1)),char(176),av_speed_lowvar));
   axis('equal');
    