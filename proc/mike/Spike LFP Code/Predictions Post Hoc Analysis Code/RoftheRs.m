LFPOfflineSorted_NoNan = LFPOfflinePDsSorted(230:300,3:end);

for i = 1:size(LFPOfflineSorted_NoNan,2)
    for j = 1:size(LFPOfflineSorted_NoNan,2)
    r_r = corrcoef(LFPOfflineSorted_NoNan(:,i),LFPOfflineSorted_NoNan(:,j));
    r_r_LFP_Gamma2_PDs(i,j) = r_r(1,2);
%     r_r = corrcoef(r2_Y_SingleUnitsSorted_DayAvg(:,i),r2_Y_SingleUnitsSorted_DayAvg(:,j));
%     r_r_Y_SingleUnitsDayAvg(i,j) = r_r(1,2);
    end
end

% for i = 1:size(LFPOfflineSorted_NoNan,2)
%     r_r_X_mean(i) = mean(r_r_X_SingleUnitsDayAvg(1:109-i,110-i));
% %     r_r_Y_mean(i) = mean(r_r_Y_SingleUnitsDayAvg(1:109-i,110-i));
% end