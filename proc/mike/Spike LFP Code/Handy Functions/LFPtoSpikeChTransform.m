function [bestcSpike] = LFPtoSpikeChTransform(bestc)

bestcSpike = zeros(length(bestc),1);

for i = 1:length(bestc)
    
    if bestc(i) < 33
        bestcSpike(i) = bestc(i) + 64;
        
    else
        bestcSpike(i) = bestc(i) - 32;
    
    end
    
end

end