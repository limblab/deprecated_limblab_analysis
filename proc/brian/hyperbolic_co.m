function errs = hyperbolic_co(bdf)

show_plots = 0;
colors = [1 0 0; 1 .5 0; 1 1 0; 0 1 0; 0 1 1; 0 0 1; .5 0 1; 1 0 .5; 0 0 0];

% get data
ul = unit_list(bdf);
ul = ul(ul(:,2) ~= 0,:);
ul = ul(ul(:,2) ~= 255,:);
% Center Out task
tt = co_trial_table(bdf);
tt = tt( tt(:,10)==double('R') , :);
events = tt(:,8);

% Wrist flexion task
%tt = wf_trial_table(bdf);
%tt = tt( tt(:,9)==double('R') , :);
%events = tt(:,8);

for cell=1:length(ul)
    spikes = bdf.units(cell).ts;
%    table = raster(spikes, events, -.1, .3, -1);
    table = raster(spikes, events, -.4, 0, -1);
    for trial=1:length(events)
        T(trial,cell) = length(table{trial});
    end
end


T = T + .01*randn(size(T));

D = pdist(T);
Y = mdscale(D, 2);

% Draw the figure
%plot(Y(:,1), Y(:,2), 'ko');
% if show_plots
%     figure; hold on;
%     for reachdir = 0:7
%         f = tt(:,5) == reachdir;
%         plot(Y(f,1), Y(f,2), 'ko', ...
%             'MarkerEdgeColor', colors(reachdir+1,:),...
%             'MarkerFaceColor', colors(reachdir+1,:));
%     end
%     axis equal;
%     axis square;
%     title('Euclidian');
% end

% calculate the error
De = pdist(Y);
err_Y = sum(sum((De-D).^2))/sum(sum(D));

%%%%%%%%%%%%%%%%%%%%%%%
% now do H^n distances
%%%%%%%%%%%%%%%%%%%%%%%
Ks = -1:-.1:-20;
err_Yh = zeros(size(Ks));

tic
for i = 1:length(Ks)
    toc
    K = Ks(i)
    T0 = sqrt(sum(T.^2,2)-K);
    Th = [T T0];

    Dh = zeros(size(Th,1));

    metric = @(a,b) sqrt(sum( (a(1:end-1)-b(1:end-1)).^2) + K*(a(end)-b(end)).^2);

    for x = 1:size(Dh,1)
        for y = 1:size(Dh,2)
            if x==y
                Dh(x,y) = 0;
            else
                v = Th(x,:); u = Th(y,:);
                Dh(x,y) = acosh( metric(v,u) );
            end
        end
    end

    Yh = mdscale(real(Dh), 2);

%    figure; plot(Yh(:,1), Yh(:,2), 'ko');
%     if show_plots
%         figure; hold on;
%         for reachdir = 0:7
%             f = tt(:,5) == reachdir;
%             plot(Yh(f,1), Yh(f,2), 'ko', ...
%                 'MarkerEdgeColor', colors(reachdir+1,:),...
%                 'MarkerFaceColor', colors(reachdir+1,:));
%         end
%         axis equal;
%         axis square;
%         title('Hyperbolic');
%     end

    Y0 = sqrt(sum(Yh.^2,2)-K);
    Yh = [Yh Y0];

    Dhe = zeros(size(Th,1));
    for x = 1:size(Dh,1)
        for y = 1:size(Dh,2)
            if x==y
                Dhe(x,y) = 0;
            else
                v = Yh(x,:); u = Yh(y,:);
                Dhe(x,y) = acosh( metric(v,u) );
            end
        end
    end

    err_Yh(i) = sum(sum((Dhe-Dh).^2))/sum(sum(Dh));
    
    % Poincare projection
    if show_plots
        Yp = [Yh(:,1)./(1+Yh(:,3)) Yh(:,2)./(1+Yh(:,3))];
         figure; hold on;
         for reachdir = 0:8
%             f = tt(:,5) == reachdir;
             f = tt(:,10) == reachdir;
             plot(Yp(f,1), Yp(f,2), 'ko', ...
                 'MarkerEdgeColor', colors(reachdir+1,:),...
                 'MarkerFaceColor', colors(reachdir+1,:));
         end
        plot(Yp(:,1), Yp(:,2), 'ko');
        t = 0:pi/100:2*pi;
        plot(sin(t), cos(t), 'k-');
        axis square;
        title(sprintf('Poincare Projection | K = %d', K));
    end
end
errs = abs([err_Y, err_Yh]);

