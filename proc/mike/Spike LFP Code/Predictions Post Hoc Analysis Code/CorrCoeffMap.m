function [r_map,r_r_mean] = CorrCoeffMap(Data);

for i = 1:size(Data,2)
    for j = 1:size(Data,2)
    r_r = corrcoef(Data(:,i),Data(:,j));
    r_map(i,j) = r_r(1,2);
%     r_r = corrcoef(r2_Y_SingleUnitsSorted_DayAvg(:,i),r2_Y_SingleUnitsSorted_DayAvg(:,j));
%     r_r_Y_SingleUnitsDayAvg(i,j) = r_r(1,2);
    end
end

for i=1:size(Data,2)
    inds=setdiff(1:(size(Data,2)),i);
    r_r_mean(i)=mean(r_map(inds,i));
end
