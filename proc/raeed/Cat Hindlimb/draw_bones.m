% Draw bones

hold on
for i = 1:3
    s=segments(i,:);
    plot(mp(1,s), mp(2,s), 'k-')
    %plot(mp(1,s), mp(2,s), 'k-', 'Color', [.8 .8 .8])
    plot(mp(1,s), mp(2,s), 'ko')
end

%plot(cal(1,:),cal(2,:),'ko')

%    s=segments(1,:);
%    plot(mp(1,s), mp(2,s), 'r-')
%    plot(mp(1,s), mp(2,s), 'ko')

%    s=segments(2,:);
%    plot(mp(1,s), mp(2,s), 'g-')
%    plot(mp(1,s), mp(2,s), 'ko')

%    s=segments(3,:);
%    plot(mp(1,s), mp(2,s), 'b-')
%    plot(mp(1,s), mp(2,s), 'ko')

% return;
for i = 1:5
    s=muscles(i,:);
    plot(mp(1,s), mp(2,s), 'r-')
    %plot(mp(1,s), mp(2,s), 'r-', 'Color', [1 .8 .8])
end

%hold off




