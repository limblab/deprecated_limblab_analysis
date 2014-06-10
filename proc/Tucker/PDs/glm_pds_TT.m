function [pds, errs, moddepth] = glm_pds(varargin)
% GLM_PDS returns PDS calculated using a velocity GLM
%   PDS = GLM_PDS(BDF) returns the velocity PDs, in radians, from each unit in the
%       supplied BDF object 
%   PDS = GLM_PDS(BDF,include_unsorted) - Same as above, second input includes
%       unsorted units in unit list if different from zero.

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
    reps = 1000;
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

pds = zeros(length(ul),1);
moddepth = zeros(length(ul),1);

moddepth_boot = zeros(length(ul),reps);
pds_boot = zeros(length(ul),reps);

tic;
for i = 1:length(ul)
    et = toc;
    fprintf(1, 'ET: %f (%d of %d)\n', et, i, length(ul));
    
    [b, dev, stats] = glm_kin(bdf, ul(i,1), ul(i,2), 0, model); %#ok<ASGLU> 
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
    pds(i,:) = atan2(bv(2), bv(1));
    errs(i,:) = dbv*J;
    moddepth(i,:) = sqrt(bv(1).^2 + bv(2).^2); 
end


