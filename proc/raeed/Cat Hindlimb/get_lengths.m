% get_lengths

lengths = zeros(1,5);

for i = 1:5
    s=muscles(i,:);
    l = mp(:,s(1)) - mp(:,s(2));
    lengths(i) = sqrt ( l(1,:)*l(1,:) + l(2,:)*l(2,:) );
end
