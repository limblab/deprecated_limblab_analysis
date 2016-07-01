function [meanValue steValue] = FindMeanAndSTE(data)

meanValue = mean(data);
steValue = std(data)/sqrt(length(data));

end