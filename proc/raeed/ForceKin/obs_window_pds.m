function [fr,thv,thf] = obs_window_pds(bdf)

% set window radius
Wr = 3;

% extract time and position signals
t = bdf.pos(:,1);
x = bdf.pos(:,[2 3]) - repmat(median(bdf.pos(:,[2 3])), size(bdf.pos,1), 1);
f = bdf.force(:,[2 3]) - repmat(median(bdf.force(:,[2 3])), size(bdf.force,1), 1);

% extract trajectories through observation window
Wf = x(:,1).^2 + x(:,2).^2 < Wr.^2;
iStart = find(diff(Wf)>0);
iStop  = find(diff(Wf)<0); 

% A little Kluge to eleminate any partial trajectories at the beginning or
% end of the file
if iStart(1) > iStop(1)
    iStop = iStop(2:end);
end

if length(iStart) > length(iStop)
    iStart = iStart(1:length(iStop));
end

% Select the paths that we're going to use
lMin = 3; % minimum path length
maxLenRat = 1.25; % maximum ratio of displacement to path length
kMax = 1; % maximum peak curvature

keepers = true(size(iStart));
for i = 1:length(keepers)
    snip = x(iStart(i):iStop(i), :);
    
    % Reject paths that are too short
    steps = diff(snip);
    len = sum(sqrt(steps(:,1).^2+steps(:,2).^2));
    keepers(i) = keepers(i) & len > lMin; 
    
    % Reject paths that have too high a length to displacement ratio
    dist = sqrt( (snip(end,1)-snip(1,1)).^2 + (snip(end,2)-snip(1,2)).^2 );
    keepers(i) = keepers(i) & len/dist < maxLenRat;
    
    % Reject paths that have too high a peak curvature
    k = curvature(snip);
    keepers(i) = keepers(i) & max(abs(k)) < kMax;
end

% % Plot all paths to inspect our selection algorithm
% figure; hold on;
% cols = {'r-', 'b-'};
% for i = 1:length(iStart)
%     snipx = x(iStart(i):iStop(i), 1);
%     snipy = x(iStart(i):iStop(i), 2);
%     box = ceil(i/5);
%     offsetx = 2*Wr*mod(box,10);
%     offsety = 2*Wr*ceil(box/10);
%     plot(snipx + offsetx, snipy + offsety, cols{keepers(i)+1});
%     th = 0:.01:2*pi;
%     plot(Wr*cos(th)+offsetx, Wr*sin(th)+offsety, 'Color', [.5 .5 .5]);
% end
% axis equal;


% Dump all the rejected trajectories
iStart = iStart(keepers);
iStop = iStop(keepers);

% Plot the tuning curves
fr = zeros(length(iStart),length(unit_list(bdf)));
for uid = 1:length(unit_list(bdf))
    thv = zeros(length(iStart),1);
    thf = zeros(length(iStart),1);
    la = zeros(size(thv));
    s = bdf.units(uid).ts;
    for i = 1:length(thv)
        snip = x(iStart(i):iStop(i), :);
        thv(i) = atan2( mean(gradient(snip(:,2))), mean(gradient(snip(:,1))) );
        thf(i) = atan2( mean(f(iStart(i):iStop(i),2)), mean(f(iStart(i):iStop(i),1)) );
        la(i) = sum(s < t(iStop(i)) & s > t(iStart(i))) / (iStop(i)-iStart(i)) * 1000;
    end
    fr(:,uid) = la;

    %phi = pi/2; % cutoff plane to separate movements
    %vdf = thv < phi & thv > (phi - pi); % velocity direction filter

    [xx, yy] = meshgrid(-pi:pi/10:pi, -pi:pi/10:pi);
    gx = zeros(size(xx));
    gp = zeros(size(xx));
    sig = .5;
    for offsetx = -2:2
        for offsety = -2:2
            dx = 2*pi*offsetx;
            dy = 2*pi*offsety;
            for i = 1:length(thf)
                gx = gx + la(i) * exp( -sqrt((thf(i)-xx-dx).^2 + (thv(i)-yy-dy).^2) / 2 / sig.^2 );
                gp = gp + exp( -sqrt((thf(i)-xx-dx).^2 + (thv(i)-yy-dy).^2) / 2 / sig.^2 );
            end
        end
    end
    srf = gx ./ gp;

    figure; plot3(thf, thv, la, 'k.');
    hold on;
    mesh(xx,yy,srf);
    xlabel('Force Direction');
    ylabel('Velocity Direction');
    zlabel('Firing Rate');
    title(sprintf('Neuron %d', uid));

end % foreach unit
