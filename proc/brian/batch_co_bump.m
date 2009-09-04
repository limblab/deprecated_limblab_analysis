function res = batch_co_bump(bdf)
% batch_co_bump.m

all_units = unit_list(bdf);
%all_units = [80 1];
th = [0, pi/2, pi, 3*pi/2];

res = zeros(size(all_units,1),13); % [chan unit a_gain a_pd p_gain p_pd]

for i = 1:size(all_units,1)
    chan = all_units(i,1);
    unit = all_units(i,2);
    
    [b,p,a,m,v,anova] = co_bumps(bdf, chan, unit);
    
%     figure;
%     hold on;
%     errorbar([th 2*pi]+.05,[p(1,:) p(1,1)],[p(2,:) p(2,1)],'ko-');
%     errorbar([th 2*pi]-.05,[a(1,:) a(1,1)],[a(2,:) a(2,1)],'bo-');
%     plot([0 2*pi], [b(3) b(3)], 'k--');
%     title(sprintf('%d - %d', chan, unit));    
     
    %a_gain = (max(a(1,:)) - min(a(1,:))) / sqrt(b(3));
    %p_gain = (max(p(1,:)) - min(p(1,:))) / sqrt(b(3));
    a_gain = (max(a(1,:)) - min(a(1,:)));
    p_gain = (max(p(1,:)) - min(p(1,:)));
    
    a_pd = atan2( sum(a(1,:).*sin(th)), sum(a(1,:).*cos(th)) );
    p_pd = atan2( sum(p(1,:).*sin(th)), sum(p(1,:).*cos(th)) );
    
    max_diff = max(max(m)) - min(min(m));
    max_targ_diff = max(max(m,[],1) - min(m,[],1));
    max_bump_diff = max(max(m,[],2) - min(m,[],2));
    max_base = max(max(m)) - b(3);
    
    res(i,:) = [chan unit a_gain a_pd p_gain p_pd max_diff max_targ_diff max_bump_diff anova.p max_base];
    
    %plotstuff_2(m, p(1,:), a(1,:)', b(3), sprintf('%d - %d', chan, unit));
    altplot(m, p(1,:), a(1,:)', b(3), sprintf('%d - %d', chan, unit));
    %print('-dwinc');
    %close(gcf);
end



