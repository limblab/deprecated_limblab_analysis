%%
global segments;

clear;leg;get_mp

num_positions = 100;

mtp = mp(:,segments(end,end));

[a,r]=cart2pol(mtp(1), mtp(2));

% get polar points
rs = linspace(-5,-1.25,10) + r;
%rs = r;
as = pi/16 * linspace(-2,4,10) + a;
%as = a;

[rsg, asg] = meshgrid(rs, as);
polpoints = [reshape(rsg,[1,num_positions]); reshape(asg,[1,num_positions])];

[x, y] = pol2cart(polpoints(2,:), polpoints(1,:));
endpoint_positions = [x;y]; % offset by the point where the hip is rotating

%% unconstrained
figure
options = optimset('MaxFunEvals', 5000);
x0 = base_angles';

for i = 1:length(endpoint_positions)
    my_ep = endpoint_positions(:,i);
   if(i==15)
        [angles,val,flag] = fminsearch(@mycost, x0, options);
        start_angles_con(:,i) = angles;
        get_mp;
        hold on
        for i = 1:3
            s=segments(i,:);
            plot(mp(1,s), mp(2,s), 'k-', 'LineWidth', 5)
            %plot(mp(1,s), mp(2,s), 'k-', 'Color', [.8 .8 .8])
            plot(mp(1,s), mp(2,s), 'bo', 'MarkerSize',10, 'LineWidth',5)
        end
    end
    plot(my_ep(1), my_ep(2), 'ko', 'MarkerSize', 10);
end
axis square
axis equal
set(gca,'Xtick',[],'Ytick',[])

% axis([-10 15 -20 5])

%% constrained
options = optimset('MaxFunEvals', 5000, 'MaxIter', 1000, 'Display', 'off', 'Algorithm', 'active-set');
x0 = base_angles';

for i = 1:length(endpoint_positions)
    my_ep = endpoint_positions(:,i);
    if(i==15)
        [angles,val,flag] = fmincon(@mycost, start_angles_con(:,i) , [0 1 -1;0 -1 1], [-pi/15; pi], [1 -1 0], pi/2,[],[],[], options);
        get_mp;
        hold on
        for i = 1:3
            s=segments(i,:);
            plot(mp(1,s), mp(2,s), 'g-','LineWidth', 5)
            %plot(mp(1,s), mp(2,s), 'k-', 'Color', [.8 .8 .8])
            plot(mp(1,s), mp(2,s), 'bo','MarkerSize',10, 'LineWidth',5)
        end
    end
end

axis off
