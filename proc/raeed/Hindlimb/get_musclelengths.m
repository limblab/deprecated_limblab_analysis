function lengths = get_musclelengths(base_leg,angles)
% get muscle lengths from base leg and provided angles

mp = get_legpts(base_leg,angles);

lengths = zeros(1,length(base_leg.muscle_idx));

for i = 1:length(base_leg.muscle_idx)
    s=base_leg.muscle_idx(i,:);
    l = mp(:,s(1)) - mp(:,s(2));
    lengths(i) = sqrt ( l(1,:)*l(1,:) + l(2,:)*l(2,:) );
end

% Consolidate RF muscles
lengths(3) = lengths(3)+lengths(4);
lengths(4) = [];