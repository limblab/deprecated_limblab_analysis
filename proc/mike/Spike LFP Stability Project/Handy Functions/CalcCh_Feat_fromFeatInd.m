function [bestc bestf] = CalcCh_Feat_fromFeatInd(featind)

for j = 1:length(featind)
    bestc(j) = ceil(featind(j)/6);
    
    if rem(featind(j),6) ~=0
        bestf(j) = rem(featind(j),6);
    else
        bestf(j) = 6;
    end
    
end

end