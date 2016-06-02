%createImplausibleBCdecoder
% This scripts creates the Implausible Transformation decoder by swapping
% the filters between neurons and muscles for ECR and FCR. The decoder
% should also only include filters for ECR, FCR, FCU, and ECR. All other
% muscles should have filter weights of 0.

%input to this script should be the struct "filter"
% output is impossfilter

% Locate the indices for ECR, ECU, FCR, FCU
ECRind = strmatch('ECR',filter.outnames(:,1:3)); ECRind = ECRind(1);
ECUind = strmatch('ECU',filter.outnames(:,1:3)); ECUind = ECUind(1);
FCRind = strmatch('FCR',filter.outnames(:,1:3)); FCRind = FCRind(1);
FCUind = strmatch('FCU',filter.outnames(:,1:3)); FCUind = FCUind(1);

ECRfilter = filter.H(:,ECRind);
ECUfilter = filter.H(:,ECUind);
FCRfilter = filter.H(:,FCRind);
FCUfilter = filter.H(:,FCUind);

% Alteration number 1:swap ECR and FCR (the biologically impossible filter)
impossfilter = zeros(length(filter.H(:,1)),length(filter.H(1,:)));
impossfilter(:,ECRind) = FCRfilter; %swapped
impossfilter(:,ECUind) = ECUfilter;
impossfilter(:,FCRind) = ECRfilter; %swapped
impossfilter(:,FCUind) = FCUfilter;



