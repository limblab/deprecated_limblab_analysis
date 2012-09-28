function anglePDs = convertPDsToAngles(pds,type)
% Converts x,y PD into an angular value

anglePDs = zeros(length(pds),2);
anglePDs(:,1) = pds(:,1);

for ipd = 1:length(pds)
    anglePDs(ipd,2) = atan2(pds(ipd,2),pds(ipd,3));
end

switch lower(type)
    case 'deg'
        anglePDs(:,2) = anglePDs(:,2).*180/pi;
    case 'rad'
        
end