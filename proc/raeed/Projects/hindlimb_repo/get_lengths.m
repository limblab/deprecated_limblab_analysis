% get_lengths

lengths = zeros(1,length(muscles));

for i = 1:length(muscles)
    s=muscles(i,:);
    l = mp(:,s(1)) - mp(:,s(2));
    lengths(i) = sqrt ( l(1,:)*l(1,:) + l(2,:)*l(2,:) );
end

% Consolidate RF muscles
lengths(3) = lengths(3)+lengths(4);
lengths(4) = [];