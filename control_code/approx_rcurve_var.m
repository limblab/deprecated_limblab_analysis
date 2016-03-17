function stdM = approx_rcurve_var(rcurve,usedMusc)

stdM = nan(size(rcurve.y2(1).data,2),size(rcurve.amps,2));
for ii = 1:length(usedMusc)
    % Interpolate at given amplitude
    ind = ii;%usedMusc(ii);
    y2 = rcurve.y2(ind).data;
    stdM(:,ind) = std(y2,0,1);
end