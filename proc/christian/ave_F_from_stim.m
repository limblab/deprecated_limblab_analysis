function [ave_f, ave_fpeak] = ave_F_from_stim(bdf,baseline_t,response_t)

force = bdf.force.data;
ts = bdf.stim_marker;
n_stim = length(ts);

baseline_b = baseline_t*bdf.force.forcefreq;
response_b = response_t*bdf.force.forcefreq;

n_bin = baseline_b + response_b + 1;
ave_f = zeros(n_bin,2);
ave_fpeak = nan(n_stim,2);
valid_stim = false(n_stim,1);

f = figure;
set(f,'Position',[45 380 560 420]);
for s = 1:n_stim
    
    stim_b = find(force(:,1)>=ts(s),1,'first');
    
    bin_start = stim_b - baseline_b;
    bin_stop  = stim_b + response_b;
    
    if bin_start<1 || bin_stop>size(bdf.force.data,1)
        warning('could not extract response window from data for stim ts: %d',ts(s));
        continue;
    end
    
    baseline = mean(force(bin_start:stim_b,2:end));
    tmp_force = force(bin_start:bin_stop,2:end)-repmat(baseline,n_bin,1);
    
    plot(force(bin_start:bin_stop,1),tmp_force);

    [~,peak_i]   = max(sqrt(sum( (tmp_force).^2 ,2)));
    tmp_fpeak = tmp_force(peak_i,:);
    hold on;
    plot(force(bin_start+peak_i-1,1),tmp_fpeak,'x','MarkerSize',20);
    legend('Fx','Fy','peak x','peak y');
    
    YesNo = questdlg('Use this response?','Stim Response Validation','Yes','No','Manual Entry','Yes');
    
    switch YesNo
        case 'Yes'
            ave_f = ave_f + tmp_force;
            ave_fpeak(s,:) = tmp_fpeak;
            valid_stim(s) = true;
        case 'No'
            clf(f); hold off;
            continue;
        otherwise
            ave_fpeak(s,:) = input('Enter Peaks [X,Y] : ');
            valid_stim(s) = true;
    end
    clf(f);hold off;
end

ave_f = ave_f/sum(valid_stim);
ave_f = [ (-baseline_t:(1/bdf.force.forcefreq):response_t)' ave_f];
ave_fpeak = mean(ave_fpeak(valid_stim,:),1);

plot(ave_f(:,1),ave_f(:,2:3));
hold on;
plot([-baseline_t;response_t],[ave_fpeak;ave_fpeak],'--');
legend('ave Fx','ave Fy','ave peak x','ave peak y');
            
   
