%createNormalBCdecoder
% This scripts creates the normal neuron-to-muscle decoder, which only has
% weights for ECR, ECU, FCR, and FCU

%input to this script should be the struct "filter"
%output is normalfilter

% Locate the indices for ECR, ECU, FCR, FCU
ECRind = strmatch('ECR',filter.outnames(:,1:3)); ECRind = ECRind(1);
ECUind = strmatch('ECU',filter.outnames(:,1:3)); ECUind = ECUind(1);
FCRind = strmatch('FCR',filter.outnames(:,1:3)); FCRind = FCRind(1);
FCUind = strmatch('FCU',filter.outnames(:,1:3)); FCUind = FCUind(1);

ECRfilter = filter.H(:,ECRind);
ECUfilter = filter.H(:,ECUind);
FCRfilter = filter.H(:,FCRind);
FCUfilter = filter.H(:,FCUind);

% Create new normal filter (only weights for ECR, ECU, FCR, FCU)
normalfilter = zeros(length(filter.H(:,1)),length(filter.H(1,:)));
normalfilter(:,ECRind) = ECRfilter;
normalfilter(:,ECUind) = ECUfilter;
normalfilter(:,FCRind) = FCRfilter;
normalfilter(:,FCUind) = FCUfilter;