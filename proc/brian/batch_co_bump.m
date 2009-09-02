function res = batch_co_bump(bdf)
% batch_co_bump.m

all_units = unit_list(bdf);
%all_units = [80 1];
th = [0, pi/2, pi, 3*pi/2];

res = zeros(size(all_units,1),9); % [chan unit a_gain a_pd p_gain p_pd]

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
    
    res(i,:) = [chan unit a_gain a_pd p_gain p_pd anova.p];
    
    %figure;
    %image(m);
    %colorbar;
    %axis square;
    %ylabel('target');
    %xlabel('bump');
    %set(gca, 'YTick', [1 2 3 4])
    %set(gca, 'XTick', [1 2 3 4])
    %title(sprintf('%d - %d', chan, unit));
    plotstuff_2(m, p(1,:), a(1,:)', b(3), sprintf('%d - %d', chan, unit));
    %print('-dpng', sprintf('tmp/%d-%d.png', chan, unit));
    %close(gcf);
end

