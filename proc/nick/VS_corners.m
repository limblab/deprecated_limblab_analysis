function corners = VS_corners(binnedData, target_num, target_rad, target_size)
% corners = VS_corners(binnedData, target_num, target_rad, target_size)
%
% Calculates a matrix from a VS binnedData file without corner information
% that includes [timestamps, ULx, ULy, LRx, LRy].

PI = 3.14159;

word_rows = (binnedData.words(:,2)>=64 & binnedData.words(:,2)<80);

timestamps = binnedData.words(word_rows,1);

targets = binnedData.words(word_rows,2);

ULx = target_rad*cos(PI/2 - (targets - 64)*2*PI/target_num) - target_size/2;
ULy = target_rad*sin(PI/2 - (targets - 64)*2*PI/target_num) + target_size/2;
LRx = target_rad*cos(PI/2 - (targets - 64)*2*PI/target_num) + target_size/2;
LRy = target_rad*sin(PI/2 - (targets - 64)*2*PI/target_num) - target_size/2;

corners = [timestamps, ULx, ULy, LRx, LRy];