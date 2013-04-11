function [pds, errs, moddepth] = glm_pds(varargin)
% GLM_PDS returns PDS calculated using a velocity GLM
%   PDS = GLM_PDS(BDF) returns the velocity PDs, in radians, from each unit in the
%       supplied BDF object 
%   PDS = GLM_PDS(BDF,include_unsorted) - Same as above, second input includes
%       unsorted units in unit list if different from zero.

% $Id$

bdf = varargin{1};
include_unsorted = 0;
model='posvel';
if length(varargin)>1;
    for i=2:length(varargin)
        if ischar(varargin{i})
            model=varargin{i};
        else
            include_unsorted = varargin{i};
        end
    end
end

ul = unit_list(bdf,include_unsorted);
pds = zeros(length(ul),1);
errs = zeros(length(ul),1);
moddepth = zeros(length(ul),1);

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


