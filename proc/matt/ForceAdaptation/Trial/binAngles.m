function theta = binAngles(theta,angleBinSize)

theta = round(theta./angleBinSize).*angleBinSize;
% -pi and pi are the same thing
if length(unique(theta)) > int16(2*pi/angleBinSize)
    % probably true that -pi and pi both exist
    utheta = unique(theta);
    if utheta(1)==-utheta(end)
        % almost definitely true that -pi and pi both exist
        theta(theta==utheta(1)) = utheta(end);
    elseif abs(utheta(1)) > abs(utheta(end))
        theta(theta==utheta(1)) = -utheta(1);
        % probably means that -pi instead of pi
    else
        disp('Something fishy is going on with this binning...')
    end
end