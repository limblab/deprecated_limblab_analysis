function [ normalized ] = normalize( electrode , norm)
%NORMALIZE
% Normalizing the data

for i=1:size(electrode.mWave,1)
    electrode.normalized(i,:)=electrode.mWave(i,:)./norm;
end

normalized = electrode.normalized;
end