function onsets = get_cycle_onsets_from_ided_times(ang,ided_times, criteria)

npairs = size(ided_times,1);
onsets = zeros(npairs,1);
nn = 1;
for ii = 1:npairs
    ind = ided_times(ii,1):ided_times(ii,2);
    [mx,mxind] = max(ang(ind));
    onsets(ii) = ind(mxind);
    if any(isnan(ang(ind)))
        onsets(ii) = NaN;  % flag it as bad because there are dropped frames 
    end
end

nn = 1;
for ii = 1:npairs-1
    ind = onsets(ii):onsets(ii+1);
    if (criteria(1) < length(ind)) & (length(ind) < criteria(2)) & (~any(isnan(ang(ind))))
        real_onsets(nn,1) = onsets(ii);
        real_onsets(nn,2) = onsets(ii+1)-1;
        nn = nn+1;
    end
end  

onsets = real_onsets;
