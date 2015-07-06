function [avg_b, avg_dev, avg_stats, varargout] = glm_kin_TT(bdf, chan, unit,varargin)
    % GLM_KIN fits the kinematic glm model to the requeted neuron
    %
    %   B = GLM_KIN(BDF, CHAN, UNIT, OFFSET) returns B the vector of glm
    %       weights for the fit GLM for the specified CHANnel and UNIT number
    %       in the supplied BDF structure.  Offset will shift the spike train
    %       relative to the kinematics.
    %
    %   [B, DEV, STATS] = GLM_KIN( ... ) also returns DEV and STATS from glmfit
    %
    %   [B, DEV, STATS, L, L0] = GLM_KIN( ... ) also returns the negative log
    %       liklihood L of the model fit given the spike train and L0 the
    %       negative log liklihood under the null hypothesis of constant firing
    %       rate.
    %
    %   [B ... ] = GLM_KIN(BDF, CHAN, UNIT, OFFSET, MDL) will use the speficied
    %       model MDL as follows:
    %         'pos'    -- position only (X, Y)
    %         'vel'    -- velocity and speed (Vx, Vy, sqrt(Vx^2 + Vy^2)
    %         'posvel' -- full kinematic model (X, Y, Vx, Vy, sqrt(Vx^2 + Vy^2)
    %         'nospeed' -- no speed term (X, Y, Vx, Vy)

    % $Id: glm_kin.m 1119 2013-04-04 17:26:17Z tucker $
    %% Assign variable inputs
    if length(varargin)>0
        offset=varargin{1};
    else
        offset=0;
    end
    if length(varargin)>1
        mdl=varargin{2};
    else
        mdl = 'posvel';
    end
    if length(varargin)>2
        reps=varargin{3};
    else
        reps = 100;
    end
    
    vt = bdf.vel(:,1);
    %% calculate firing rate
    if isfield(bdf.units,'fr')
        %if the firing rate is already a field in bdf.units
        [s,t]=get_fr(bdf,chan,unit);
    else
        %ts = 200; % time step (ms)
        ts = 50;
        t = vt(1):ts/1000:vt(end);
        spike_times = get_unit(bdf,chan,unit)-offset;
        spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
        s = train2bins(spike_times, t);
    end
    
    if length(varargin)>3
        num_samp=varargin{4};
    else
        num_samp = floor(1000*(bdf.vel(end,1)-bdf.vel(1,1))/ts);
    end
    
 
       
    
    %% interpolate kinematics and kinetics to firing rate
    glmx = interp1(bdf.pos(:,1), bdf.pos(:,2:3), t);
    glmv = interp1(bdf.vel(:,1), bdf.vel(:,2:3), t);
    if isfield(bdf,'force')
        if ~isempty(bdf.force)
            glmf = interp1(bdf.force(:,1), bdf.force(:,2:3), t);
        elseif strcmp(mdl,'forcevel') | strcmp(mdl,'forceonly') | strcmp(mdl,'ppforcevel' | strcmp(mdl,'ppforceposvel') | strcmp(mdl,'powervel') | strcmp(mdl,'powerposvel') | strcmp(mdl,'ppcartfvp'))
            error('glm_kin:NO_FORCE_IN_BDF', 'the bdf given has an empty array for force, and the selected model requires force to run.')
        end
    elseif strcmp(mdl,'forcevel') | strcmp(mdl,'forceonly') | strcmp(mdl,'ppforcevel' | strcmp(mdl,'ppforceposvel') | strcmp(mdl,'powervel') | strcmp(mdl,'powerposvel') | strcmp(mdl,'ppcartfvp'))
        error('glm_kin:NO_FORCE_IN_BDF', 'the bdf given does not have a field for force, and the selected model requires force to run.')
    end
    %% generate GLM input fector for the specified model type
    %glmp = sum(glmf .* glmv,2);
    %glmpp = [sum( glmf .* glmv , 2)./sqrt(sum(glmv.^2,2)) ...
    %    sum( glmf .* [-glmv(:,2), glmv(:,1)] , 2)./sqrt(sum(glmv.^2,2))];
    glmpp(1,:) = [0 0];

    if strcmp(mdl, 'pos')
        glm_input = glmx;
    elseif strcmp(mdl, 'vel')
        glm_input = [glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
    elseif strcmp(mdl, 'posvel')
        glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
    elseif strcmp(mdl, 'nospeed')
        glm_input = [glmx glmv];
    elseif strcmp(mdl, 'forcevel')
        glm_input = [glmv glmf];
    elseif strcmp(mdl, 'forceonly')
        glm_input = [glmf];
    elseif strcmp(mdl, 'forceposvel')
        glm_input = [glmx glmv glmf];
    elseif strcmp(mdl, 'ppforcevel');
        glm_input = [glmv glmpp];
    elseif strcmp(mdl, 'ppforceposvel');
        glm_input = [glmx glmv glmpp];
    elseif strcmp(mdl, 'powervel');
        glm_input = [glmv glmp];
    elseif strcmp(mdl, 'powerposvel');
        glm_input = [glmx glmv glmp];
    elseif strcmp(mdl, 'ppcartfvp')
        glm_input = [glmx glmv glmf glmpp];
    else
        error('unknown model: %s', mdl);
    end

    %% Bootstrap the GLM to generate the correct errors
    % bootstrap
    b_mat = zeros(size(glm_input,2)+1,reps);
    dev_mat=zeros(size(glm_input,2)+1,reps);

    for bootCt=1:reps
        % grab test set indices
        idx = uint32(1+(length(glmx)-1)*rand(num_samp,1));

        % run glmfit on bootstrap iteration
        [b_mat(:,bootCt),dev_mat(:,bootCt),stats_mat{bootCt}] = glmfit(glm_input(idx,:),s(idx),'poisson');
    end
    % find average regression coefficients, dev and stats for main function
    % output
    avg_b = mean(b_mat,2);
    avg_dev = mean(dev_mat,2);
    %set up a mean stats 
    avg_stats=[];
    avg_stats.beta = 0;
    avg_stats.dfe = 0;
    avg_stats.sfit = 0;
    avg_stats.s = 0;
    avg_stats.estdisp = 0;
    avg_stats.covb = 0;
    avg_stats.se = 0;
    avg_stats.coeffcorr = 0;
    avg_stats.t = 0;
    avg_stats.p = 0;
    avg_stats.resid = 0;
    avg_stats.residp = 0;
    avg_stats.residd = 0;
    avg_stats.resida = 0;
    avg_stats.wts = 0;
    for bootCt=1:reps
        avg_stats.beta = avg_stats.beta+stats_mat{bootCt}.beta;
        avg_stats.dfe = avg_stats.dfe+stats_mat{bootCt}.dfe;
        avg_stats.sfit = avg_stats.sfit+stats_mat{bootCt}.sfit;
        avg_stats.s = avg_stats.s+stats_mat{bootCt}.s;
        avg_stats.estdisp = avg_stats.estdisp+stats_mat{bootCt}.estdisp;
        avg_stats.covb = avg_stats.covb+stats_mat{bootCt}.covb;
        avg_stats.se = avg_stats.se+stats_mat{bootCt}.se;
        avg_stats.coeffcorr = avg_stats.coeffcorr+stats_mat{bootCt}.coeffcorr;
        avg_stats.t = avg_stats.t+stats_mat{bootCt}.t;
        avg_stats.p = avg_stats.p+stats_mat{bootCt}.p;
        avg_stats.resid = avg_stats.resid+stats_mat{bootCt}.resid;
        avg_stats.residp = avg_stats.residp+stats_mat{bootCt}.residp;
        avg_stats.residd = avg_stats.residd+stats_mat{bootCt}.residd;
        avg_stats.resida = avg_stats.resida+stats_mat{bootCt}.resida;
        avg_stats.wts = avg_stats.wts+stats_mat{bootCt}.wts;
    end
    %% compute optional outputs
    if nargout > 3
        % return PD and moddepth
        switch mdl
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
        pd = atan2(bv(2),bv(1));
        moddepth = norm(bv);
        varargout{1}=[pd moddepth];
    end
    if nargout > 4
        % return 95 percent confidence interval bounds
        ang_dist=zeros(1,reps);
        for i=1:reps
            % Build vector of distances from mean for each channel 
            switch mdl
                case 'posvel'
                    bv = [b_mat(4,i) b_mat(5,i)]; % glm weights on x and y velocity
                case 'forceonly'
                    bv = [b_mat(2,i) b_mat(3,i)]; % glm weights on x and y force
                case 'pos'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'vel'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'nospeed'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'forcevel'
                    bv = [b_mat(4,i) b_mat(5,i)]; % glm weights on x and y velocity
                case 'forceposvel'
                    bv = [b_mat(6,i) b_mat(7,i)]; % glm weights on x and y velocity
                case 'ppforcevel'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'ppforceposvel'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'powervel'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
                case 'ppcartfvp'
                    error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
            end
            ang_dist(i) = atan2(bv(2),bv(1))-pd;
            
        end
        %shift distribution to mean 0 by setting range -180->180 rather than
        %0->360
        ang_dist(ang_dist>pi) = ang_dist(ang_dist>pi)-2*pi;
        ang_dist(ang_dist<-pi) = ang_dist(ang_dist<-pi)+2*pi;

        % Throw out top and bottom 2.5 percent of samples for each channel (according to PD)
        % sort vectors along angle distance for each unit
        ang_dist_sort = sort(ang_dist,2);
        ang_ind_low = ceil(reps*0.025);
        ang_ind_high = floor(reps*0.975);

        % Calculate confidence bounds (vector, each element corresponds to a
        % channel)
        CI_low = ang_dist_sort(:,ang_ind_low) + pd;
        CI_high = ang_dist_sort(:,ang_ind_high) + pd;
        varargout{2}=[CI_low CI_high];
    end
end

    
