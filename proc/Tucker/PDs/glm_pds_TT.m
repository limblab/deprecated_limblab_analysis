function [pds, varargout] = glm_pds_TT(varargin)
    % GLM_PDS returns PDS calculated using a velocity GLM
    %   PDS = GLM_PDS(BDF) returns the velocity PDs, in radians, from each 
    %       unit in the supplied BDF object 
    %   PDS = GLM_PDS(BDF,include_unsorted) - Same as above, second input includes
    %       unsorted units in unit list if different from zero.
    %   PDS = GLM_PDS(BDF,include_unsorted,reps) - includes optional
    %   setting to control number of bootstrapping repetitions. if left
    %   empty glm_pds defaults to reps=100;
    %   PDS = GLM_PDS(BDF,include_unsorted,reps,num_samp) - allows user to
    %   set the number of samples to take for each bootstrap iteration.
    %   default is the same number as the number of time windows in the
    %   firing rate vector
    % $Id: glm_pds.m 1123 2013-04-11 14:29:47Z tucker $

    bdf = varargin{1};


    if length(varargin)>1;
        if isnumeric(varargin{2})
            include_unsorted = varargin{2};
        else
            error('S1_ANALYSIS:LIB:GLM:GLM_PDS:type_error','flag for including unsorted units in PD computation must be an integer value')
        end
    else
        include_unsorted = 0;
    end

    if length(varargin)>2
        if ischar(varargin{3})
            model = varargin{3};
        else
            error('S1_ANALYSIS:LIB:GLM:GLM_PDS:type_error','input for model specification must be a string')
        end
    else
        model='posvel';
    end


    if length(varargin)>3
        if isnumeric(varargin{4})
            reps = varargin{4};
        else
            error('S1_ANALYSIS:LIB:GLM:GLM_PDS:type_error','value for bootstrap repetitions must be an integer value')
        end
    else
        reps = 100;
    end

    if length(varargin)>4

        if isnumeric(varargin{5})
            num_samp = varargin{5};
        else
            error('S1_ANALYSIS:LIB:GLM:GLM_PDS:type_error','value for bootstrap number of samples must be an integer value')
        end
    else
        num_samp = size(bdf.vel,1);
    end

    ul = unit_list(bdf,include_unsorted);

    moddepth = zeros(length(ul),1);
    pds = zeros(length(ul),1);
    errs = zeros(length(ul),1);
    LL = zeros(length(ul),1);
    LLN = zeros(length(ul),1);
    CI = zeros(length(ul),2);
    tic;
    for i = 1:length(ul)
        et = toc;
        fprintf(1, 'ET: %f (%d of %d)\n', et, i, length(ul));

        [b, dev,stats,log_lik,log_lik_null,pd,CI(i,:)] = glm_kin_TT(bdf, ul(i,1), ul(i,2), 0, model, reps, num_samp); %#ok<ASGLU> 
        switch model
            case 'posvel'
                bv = [b(4) b(5)]; % glm weights on x and y velocity
                dbv = [stats.se(4) stats.se(5)];
            case 'forceonly'
                bv = [b(2) b(3)]; % glm weights on x and y force
                dbv = [stats.se(2) stats.se(3)];
            case 'pos'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
            case 'vel'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
            case 'nospeed'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
            case 'forcevel'
                bv = [b(4) b(5)]; % glm weights on x and y velocity
                dbv = [stats.se(4) stats.se(5)];
            case 'forceposvel'
                bv = [b(6) b(7)]; % glm weights on x and y velocity
                dbv = [stats.se(6) stats.se(7)];
            case 'ppforcevel'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
            case 'ppforceposvel'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
            case 'powervel'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
            case 'ppcartfvp'
                error('s1_analysis:lib:glm:glm_pds:UnmappedPDCase',strcat('No output case defined for model type: ',model))
        end
        J = [-bv(2)/(bv(1)^2+bv(2)^2); bv(1)/(bv(1)^2+bv(2)^2)];
        pds(i,:) = pd(1);
        errs(i,:) = dbv*J;
        moddepth(i,:) = pd(2);
        LL(i,:)= log_lik; 
        LLN(i,:)= log_lik_null;
    end
    
    %compute optional outputs
    if nargout>1
        varargout{1}=errs;
    end
    if nargout>2
        varargout{2}=moddepth;
    end
    if nargout>3
        varargout{3}=CI;
    end
    if nargout>4
        varargout{4}=LL;
    end
    if nargout>5
        varargout{5}=LLN;
    end
end


