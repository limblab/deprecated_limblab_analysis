function [pd_diff_DE pd_diff_SE]= pd_electrode_map(PDm,start,last)
% PD electrode mapping
% Start- first column with PDm components
% End - Last column with PDm components

k=1;
m=1;


    for i = 1: length(PDm)
        for j =i+1:length(PDm)
               if PDm(i,1) ~= PDm(j,1) 
                   pd_diff_DE(m,:)= [acos(sum(PDm(i,start:last).*PDm(j,start:last)))];
                   m=m+1;
               else
                   pd_diff_SE(k,:)= [acos(sum(PDm(i,start:last).*PDm(j,start:last)))];
                   k=k+1;   
               end
        end
    end