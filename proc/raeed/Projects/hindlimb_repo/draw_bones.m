function draw_bones(base_leg, angles, plot_muscle, linewidth)
% Draw bones

mp = get_legpts(base_leg,angles);

holdstat = ishold;

hold on
for i = 1:3
    s=base_leg.segment_idx(i,:);
    plot(mp(1,s), mp(2,s), 'k-','LineWidth',linewidth)
    plot(mp(1,s), mp(2,s), 'bo', 'MarkerSize',10, 'LineWidth',linewidth)
end

% plot(cal(1,:),cal(2,:),'ko')

%    s=segments(1,:);
%    plot(mp(1,s), mp(2,s), 'r-')
%    plot(mp(1,s), mp(2,s), 'ko')
% 
%    s=segments(2,:);
%    plot(mp(1,s), mp(2,s), 'g-')
%    plot(mp(1,s), mp(2,s), 'ko')
% 
%    s=segments(3,:);
%    plot(mp(1,s), mp(2,s), 'b-')
%    plot(mp(1,s), mp(2,s), 'ko')
% 
% return;
if(plot_muscle)
    for i = 1:9
        s=base_leg.muscle_idx(i,:);
    %     plot(mp(1,s), mp(2,s), 'r-')
        plot(mp(1,s), mp(2,s), 'r-', 'Color', [1 .8 .8])
    end
end

axis equal

if(~holdstat)
    hold off;
end