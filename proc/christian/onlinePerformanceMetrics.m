function [time2target path_length trials_min num_reentries] = onlinePerformanceMetrics()

[HC_stats, EC_stats, N2F_stats] = EMG_cascade_compare_stats();

%% Plot time to target

HC_t2t = {HC_stats.time2target;


figure; barwitherr()



time2target = [];
path_length  = [];
trials_min  = [];

[path_t path_x path_y] = get_ave_path_WF(BinnedData);

[st_HC length_HC] = get_length_path_WF(BinnedData);

v_aux = path_t(:);
t2T = v_aux(v_aux~=0);
% HC_label_t2T = repmat('HC    ',length(t2T),1);
% tHC = mean(t2T);

v_aux = length_HC(:);
l_hc = v_aux(v_aux~=0);
% HC_label_l = repmat('HC    ',length(l_hc),1);
% lHC = mean(l_hc);

v_aux = st_HC(:);
% st_hc = v_aux(v_aux~=0);
% stHC = mean(st_hc);
end