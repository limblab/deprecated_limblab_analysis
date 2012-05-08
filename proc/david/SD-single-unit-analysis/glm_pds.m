function [pds, errs, moddepth] = glm_pds(binnedData)
% GLM_PDS returns PDS calculated using a velocity GLM
%   PDS = GLM_PDS(BDF) returns the velocity PDs from each unit in the
%       supplied BDF object

% $Id: glm_pds.m 761 2012-03-29 14:47:11Z marc $

% modified this to work with Nick's SD binned/classified data (quick and
% dirty style)
%   -David      April 2012
% 
% binnedData = 
% 
%           timeframe: [24120x1 single]
%                meta: [1x1 struct]
%            emgguide: []
%          emgdatabin: []
%         forcelabels: []
%        forcedatabin: []
%          spikeguide: [94x6 char]
%       spikeratedata: [24120x94 single]
%     cursorposlabels: [2x12 char]
%        cursorposbin: [24120x2 single]
%            velocbin: [24120x3 single]
%         veloclabels: [3x12 char]
%               words: [1683x2 double]
%             targets: [1x1 struct]
%          trialtable: []
%                stim: []
%               stimT: []
%              states: [24120x5 logical]
%        statemethods: [5x14 char]
%         classifiers: {[8]  []  []  {1x2 cell}  {1x2 cell}}
% 

ul = parse_units(binnedData.spikeguide); %unit_list(bdf);
pds = zeros(length(ul),1);
errs = zeros(length(ul),1);
moddepth = zeros(length(ul),1);

tic;
for i = 1:length(ul)
    et = toc;
    fprintf(1, 'ET: %f (%d of %d)\n', et, i, length(ul));
    
    [b, dev, stats] = glm_kin(binnedData, ul(i), 0, 'posvel'); %,1), ul(i,2), 0, 'posvel'); %#ok<ASGLU>
    bv = [b(4) b(5)];
    dbv = [stats.se(4) stats.se(5)];
    J = [-bv(2)/(bv(1)^2+bv(2)^2); bv(1)/(bv(1)^2+bv(2)^2)];
    moddepth(i) = norm(bv,2);
    pds(i,:) = atan2(bv(2), bv(1));
    errs(i,:) = dbv*J;
    moddepth(i,:) = sqrt(bv(1).^2 + bv(2).^2);
end


