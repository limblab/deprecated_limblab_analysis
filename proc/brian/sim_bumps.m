% sim_bumps.m

ncell = 50;
ntrials = 20;
rec_len = .25; % length of sampling window in seconds

colors = {'ro','go','bo','ko','r*','g*','b*','k*'};

th = 0:pi/2:3*pi/2;
targets = [th th; th mod(th+pi,2*pi)];
ntarg = length(targets);

% Define different models to test
outer_minus = @(a,b) repmat(a,size(b,1),1) - repmat(b,1,size(a,2));
rectify = @(x) x.*(sign(x) == 1);

aligned_pd_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), cp(:,2)) );

reversed_pd_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), pi+cp(:,2)) );

split_pd_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), (pi*(cp(:,5)>pi))+cp(:,2)) );

independent_pd_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), cp(:,5)) );

force_positive_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*abs(cos( outer_minus(targ(2,:), cp(:,2)) ));

force_halfrect_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*rectify(cos( outer_minus(targ(2,:), cp(:,2)) ));

power_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( repmat(targ(2,:) - targ(1,:), ncell , 1) );

power_limit_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,6),1,ntarg).*cos( repmat(targ(2,:) - targ(1,:), ncell , 1) );

shape1_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ).*cos( outer_minus(targ(2,:), cp(:,2)) );

shape2_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), cp(:,1)) ).*rectify(cos( outer_minus(targ(1,:), cp(:,2)) ));

mdls = { aligned_pd_mdl, reversed_pd_mdl, independent_pd_mdl, split_pd_mdl, ...
    force_positive_mdl, force_halfrect_mdl, power_mdl, power_limit_mdl, ...
    shape1_mdl, shape2_mdl };
mdl_names = { 'aligned_pd_mdl', 'reversed_pd_mdl', 'independent_pd_mdl', 'split_pd_mdl', ...
    'force_positive_mdl', 'force_halfrect_mdl', 'power_mdl', 'power_limit_mdl', ...
    'shape1_mdl', 'shape2_mdl' };

% Generate cell parameters
% format is: [baseline pd vel_amp force_amp alt_pd]
cell_params = [ 20+5*randn(ncell,1) , ...
                2*pi*rand(ncell,1)  , ... 
                10*rand(ncell,1)    , ...
                5*rand(ncell,1)     , ...
                2*pi*rand(ncell,1)  ];

cell_params = [cell_params 0.5*cell_params(:,3).*rand(ncell,1)];
%cell_params = [cell_params -.5+cell_params(:,3).*rand(ncell,1)];

for mdl = 1:length(mdls)
            
    f = mdls{mdl}(cell_params, targets);            
    f = f*rec_len;
    f(f<0) = 0;

    s = poissrnd(repmat(f,1,ntrials));   

    p = reshape(repmat(1:ntarg,ntrials,1) + ntarg*repmat((1:ntrials)'-1,1,ntarg),1,[]);
    s = s(:,p);

    lambda = factoran(s'+.01*randn(size(s')),3);
    proj = lambda' * s;

    set(0,'defaulttextinterpreter','none') 
    figure; hold on;
    for i = 1:ntarg
        cur = (1:ntrials) + ntrials*(i-1);
        plot3(proj(1,cur), proj(2,cur), proj(3,cur), colors{i});
        title(mdl_names{mdl});
    end
   
end

%% Generate cell by cell data

th = 0:pi/4:7*pi/4;
[tv, tf] = meshgrid(th,th);
[tv2, tf2] = meshgrid(0:pi/4:2*pi,0:pi/4:2*pi);
targets = [reshape(tv,1,[]); reshape(tf,1,[])];
ntarg = length(targets);

aligned_pd_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), cp(:,2)) )/3;

power_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( repmat(targ(2,:) - targ(1,:), ncell , 1) );

power_limit_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,6),1,ntarg).*cos( repmat(targ(2,:) - targ(1,:), ncell , 1) );

shape1_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ).*cos( outer_minus(targ(2,:), cp(:,5)) );

shape2_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), cp(:,5)) ).*rectify(cos( outer_minus(targ(1,:), cp(:,2)) ));

f = shape1_mdl(cell_params, targets);            
%f = aligned_pd_mdl(cell_params, targets);      
f = f*5;
f(f<0) = 0;

s = poissrnd(f);

cf_all = zeros(9);

for i = 1:3
    figure;
    cf = reshape(f(i,:),8,8);
    [r,c] = find(cf==max(max(cf)));
    cf = cf(:,[c:end 1:c]);
    cf = cf([r:end 1:r],:);
    
    cf = cf(:,[6:end 1:5]);
    cf = cf([6:end 1:5],:);
    
    cf_sub = cf - repmat(mean(cf),length(cf),1);
    %cf_sub = cf;
    
    surface(tv2, tf2, cf_sub);
    axis([0, 2*pi, 0, 2*pi]); view([-57 44]); set(gca, 'XTick', (0:5)*pi/2, 'XTickLabel', {'-180', '-90', '0', '90', '180'});
    set(gca, 'YTick', (0:5)*pi/2, 'YTickLabel', {'-180', '-90', '0', '90', '180'}); set(gca, 'ZTick', []);
    figure; surface(tv2, tf2, cf);
    axis([0, 2*pi, 0, 2*pi]); view([-57 44]); set(gca, 'XTick', (0:5)*pi/2, 'XTickLabel', {'-180', '-90', '0', '90', '180'});
    set(gca, 'YTick', (0:5)*pi/2, 'YTickLabel', {'-180', '-90', '0', '90', '180'}); set(gca, 'ZTick', []);
%     figure; surface(tv2, tf2, cf-cf_sub);
%     axis([0, 2*pi, 0, 2*pi]); view([-57 44]); set(gca, 'XTick', (0:5)*pi/2, 'XTickLabel', {'-180', '-90', '0', '90', '180'});
%     set(gca, 'YTick', (0:5)*pi/2, 'YTickLabel', {'-180', '-90', '0', '90', '180'}); set(gca, 'ZTick', []);
    cf_all = cf_all + cf;
end
return;

cf_all = cf_all / ncell;
figure;
surface(tv2, tf2, cf_all);

tv3 = [tv tv+2*pi; tv tv+2*pi];
tf3 = [tf tf; tf+2*pi tf+2*pi];
cf3 = repmat(cf_all(1:8,1:8),2,2);
figure;
surface(tv3, tf3, cf3);



