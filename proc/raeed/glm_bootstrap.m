function [pds, CI_low, CI_high, moddepth] = glm_bootstrap(varargin)
% GLM_BOOTSTRAP returns PDS calculated using a bootstrapped velocity GLM
%   PDS = GLM_BOOTSTRAP(BDF) returns the velocity PDs, in radians, from each
%       unit in the supplied BDF object 
%   PDS = GLM_BOOTSTRAP(BDF,include_unsorted) - Same as above, second input
%       includes unsorted units in unit list if different from zero.
%   PDS = GLM_BOOTSTRAP(BDF,include_unsorted,model) - Same as above, but
%       sets the model.
%   PDS = GLM_BOOTSTRAP(BDF, include_unsorted, model, reps, num_samp) - Same as
%       above, but specifies bootrstrap repetitions and number of data
%       samples used per repetition (Defaults are 100 and 1000
%       respectively)

% $Id: glm_pds.m 1028 2012-12-05 18:26:49Z tucker $

%% Set up arguments
bdf = varargin{1};
include_unsorted = 0;
model='posvel';
reps = 100;
num_samp = 1000;
if length(varargin)>1;
    include_unsorted = varargin{2};
end

if length(varargin)>2
    if ischar(varargin{3})
        model = varargin{3};
    else
        error('Model must be a string')
    end
end

if length(varargin)>3
    reps = varargin{4};
end

if length(varargin)>4
    num_samp = varargin{5};
end

ul = unit_list(bdf,include_unsorted);

pds = zeros(length(ul),1);
moddepth = zeros(length(ul),1);

moddepth_boot = zeros(length(ul),reps);
pds_boot = zeros(length(ul),reps);

%% loop over units
tic;
for i = 1:length(ul)
    et = toc;
    fprintf(1, 'ET: %f (%d of %d)\n', et, i, length(ul));
    
    %% Set up model inputs
    if isfield(bdf.units,'fr')
        %if the firing rate is already a field in bdf.units
        [s,t]=get_fr(bdf,ul(i,1),ul(i,2));
    else
        %ts = 200; % time step (ms)
        ts = 50;

        vt = bdf.vel(:,1);
        t = vt(1):ts/1000:vt(end);
        spike_times = get_unit(bdf,ul(i,1),ul(i,2));
        spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
        s = train2bins(spike_times, t);
    end
    glmx = interp1(bdf.pos(:,1), bdf.pos(:,2:3), t);
    glmv = interp1(bdf.vel(:,1), bdf.vel(:,2:3), t);
    % glmf = interp1(bdf.force(:,1), bdf.force(:,2:3), t);
    %glmp = sum(glmf .* glmv,2);
    %glmpp = [sum( glmf .* glmv , 2)./sqrt(sum(glmv.^2,2)) ...
    %    sum( glmf .* [-glmv(:,2), glmv(:,1)] , 2)./sqrt(sum(glmv.^2,2))];
    glmpp(1,:) = [0 0];

    if strcmp(model, 'pos')
        glm_input = glmx;
    elseif strcmp(model, 'vel')
        glm_input = [glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
    elseif strcmp(model, 'posvel')
        glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
    elseif strcmp(model, 'nospeed')
        glm_input = [glmx glmv];
    elseif strcmp(model, 'forcevel')
        glm_input = [glmv glmf];
    elseif strcmp(model, 'forceonly')
        glm_input = [glmf];
    elseif strcmp(model, 'forceposvel')
        glm_input = [glmx glmv glmf];
    elseif strcmp(model, 'ppforcevel');
        glm_input = [glmv glmpp];
    elseif strcmp(model, 'ppforceposvel');
        glm_input = [glmx glmv glmpp];
    elseif strcmp(model, 'powervel');
        glm_input = [glmv glmp];
    elseif strcmp(model, 'powerposvel');
        glm_input = [glmx glmv glmp];
    elseif strcmp(model, 'ppcartfvp')
        glm_input = [glmx glmv glmf glmpp];
    else
        error('unknown model: %s', model);
    end
    
    %% Bootstrap
    % bootstrap
    b_mat = zeros(size(glm_input,2)+1,1,reps);
    for bootCt=1:reps
        % grab test set indices
        idx = uint32(1+(length(glmx)-1)*rand(num_samp,1));

        b = glmfit(glm_input(idx,:),s(idx),'normal');
        moddepth_boot(i,bootCt) = norm([b(4) b(5)]);
        pds_boot(i,bootCt) = atan2(b(5),b(4));
        
        b_mat(:,bootCt) = b;
    end
    avg_b = mean(b_mat,2);
    
    %% Get model outputs
    switch model
        case 'posvel'
            bv = [avg_b(4) avg_b(5)]; % glm weights on x and y velocity
        case 'forceonly'
            bv = [avg_b(2) avg_b(3)]; % glm weights on x and y force
        case 'pos'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'vel'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'nospeed'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'forcevel'
            bv = [avg_b(4) avg_b(5)]; % glm weights on x and y velocity
        case 'forceposvel'
            bv = [avg_b(6) avg_b(7)]; % glm weights on x and y velocity
        case 'ppforcevel'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'ppforceposvel'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'powervel'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        case 'ppcartfvp'
            error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
    end
    
    %% Set outputs
    moddepth(i) = norm(bv);
    pds(i) = atan2(bv(2),bv(1));
    
end

%% Find 95 percent confidence interval bounds
% Throw out top and bottom 2.5 percent of samples for each channel
% (according to PD)

% Build vector of distances from mean for each channel
ang_dist = pds_boot-pds(:,ones(1,reps));
ang_dist(ang_dist>pi) = ang_dist(ang_dist>pi)-2*pi;
ang_dist(ang_dist<-pi) = ang_dist(ang_dist<-pi)+2*pi;

% sort vectors along angle distance for each unit
ang_dist_sort = sort(ang_dist,2);

% calculate index range for 2.5 to 97.5 percent
ang_ind_low = ceil(reps*0.025);
ang_ind_high = floor(reps*0.975);

% Calculate confidence bounds (vector, each element corresponds to a
% channel)
CI_low = ang_dist_sort(:,ang_ind_low) + pds;
CI_high = ang_dist_sort(:,ang_ind_high) + pds;
