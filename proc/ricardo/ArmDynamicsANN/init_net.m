function net = init_net(inputs, targets, typ)
% function net = init_net(inputs, targets)
% Initializes an ANN to predict arm kinematics from the EMG data loaded by
% the 'load_data.m' script.
% Optional input arg 'typ' is network type. Current options: 'layrecnet'
% (layer recurrent network') or 'narxnet' (nonlinear autoregressive). Will
% try both and compare. 
% 
% David Bontrager
% Miller Limb Lab
% Northwestern University
% June 2014

%% Anonymous function(s?)
isvertical = @(x) size(x,1) > size(x,2);

%% Initialize
lrn = 'layrecnet';
nrx = 'narxnet';
if nargin<3, typ = lrn; end % default if no type argument is given
X = inputs; % Inputs should be matrices
T = targets;
if isvertical(X), X=X'; end % Time stamps along 2nd dimension
if isvertical(T), T=T'; end

if strcmp(typ,lrn)
    layerDelays = 1:2;
    hiddenSizes = 5;
    net = layrecnet(layerDelays,hiddenSizes);
    LRN = 1;
elseif strcmp(typ,nrx)
    inputDelays = 1:2;
    feedbackDelays = 1:2;
    hiddenSizes = 5;
    net = narxnet(inputDelays,feedbackDelays,hiddenSizes);
    LRN = 0;
else
    disp('No matching net type.');
    return;
end

numInputs = size(X,1);
% numTargets = size(T,1);
net.numInputs = numInputs;
net.inputConnect = [ones(1,numInputs); zeros(1,numInputs)];
net.dividefcn = 'divideblock';

% Configure network
if LRN % net is of type 'layrecnet'
else   % net is of type 'narxnet'
end

%% NOTES
% 
% -remember to change 'divideFcn' (block, not rnd)


