function[newarray,stdarray] = bin_array(array,num_down,num_across,binkind,varargin)

if nargin < 4
    binkind = 'mean';
end

ddown = round(linspace(1,size(array,1)+1,num_down+1));
dacross = round(linspace(1,size(array,2)+1,num_across+1));

array2 = zeros(num_down,size(array,2));
newarray = zeros(num_down,num_across);

stdarray2 = zeros(num_down,size(array,2));
stdarray = zeros(num_down,num_across);

switch binkind
    
    case 'mean'
      
    for i = 1:length(ddown)-1 
        array2(i,:) = nanmean(array(ddown(i):ddown(i+1)-1,:),1);
        stdarray2(i,:) = nanstd(array(ddown(i):ddown(i+1)-1,:),[],1);
    end
    for j = 1:length(dacross)-1
        newarray(:,j) = nanmean(array2(:,dacross(j):dacross(j+1)-1),2); 
        stdarray(:,j) = nanstd(array2(:,dacross(j):dacross(j+1)-1),[],2);
    end
    
    case 'sum'
    
    for i = 1:length(ddown)-1 
        array2(i,:) = nansum(array(ddown(i):ddown(i+1)-1,:),1);
        stdarray2(i,:) = nanstd(array(ddown(i):ddown(i+1)-1,:),[],1);
    end
    for j = 1:length(dacross)-1
        newarray(:,j) = nansum(array2(:,dacross(j):dacross(j+1)-1),2); 
        stdarray(:,j) = nanstd(array2(:,dacross(j):dacross(j+1)-1),[],2);
    end
end
end
    

