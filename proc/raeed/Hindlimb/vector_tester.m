%% vector tester
% vectors = [0 -1; 0 -1; 0 -1; -sqrt(2)/2 sqrt(2)/2];
% vectors = [0 -1; -1 0];

% [th,ra] = cart2pol(vectors(:,1),vectors(:,2));

theta_trials = linspace(pi,pi/2,6)';

for i = 1:length(theta_trials)

    th = [-pi/2 theta_trials(i)]';
    ra = ones(size(th));
    [x,y] = pol2cart(th,ra);

    vectors = [x y];

    rng('default');
    neurons = random('Normal', 0, 1, 1000000, size(vectors,1));

%     neurons = abs(neurons);
    
    output = neurons*vectors;

    [th_out,ra_out] = cart2pol(output(:,1),output(:,2));
    
    figure(12345)
    subplot(3,2,i)
    plot_PD_distr(th_out,1000)
    hold on

    % figure
    % h1 = polar(0,5,'.');
    % set(h1,'MarkerSize',0.1)
    % hold on
    % 
    % for i = 1:length(neurons)
    %     h3 = polar([th_out(i) th_out(i)],[0 ra_out(i)],'-ob');
    %     set(h3,'Linewidth',2.5)
    % end
    
    for i = 1:size(vectors,1)
        h2 = polar([th(i) th(i)],[0 ra(i)],'-or');
        set(h2,'Linewidth',2.5)
    end
    
    title(['Angle = ' num2str(th(2)*180/pi)])
    
%     waitforbuttonpress
end