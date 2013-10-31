function [time2Target pathLength trials_min] = onlinePerformanceMetrics(BinnedData)

time2Target = [];
pathLength = [];
trials_min = [];

[path_t path_x path_y] = get_path_WF(BinnedData);

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