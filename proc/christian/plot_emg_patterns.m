function plot_emg_patterns(varargin)
% polar plots of emg_patterns. can plot up to five patterns on top of each other
% patterns have to have the same number of EMGs and targets.
% varargin = {emg_patterns1, emg_patterns2,...};

num_patterns = nargin;
%if nargin >1, more than one set of patterns to plot on top of each other
numEMGs = size(varargin{1},2);
numTgts = size(varargin{1},1)-1;

col = ['k';'r';'b';'g';'c'];

%EMG pattern for Go_Cues:
figure;
theta = 0:2*pi()/(numEMGs):2*pi();
%This is just a way to plot radial axis from 0 to 1:
P = polar(theta, ones(size(theta)));
set(P, 'Visible', 'off'); hold on;

%now plot EMG pattern:
for n = 1:num_patterns
    rho = [varargin{n}(1,:) varargin{n}(1,1)];
    polar(theta,rho,col(n));
    title('Center Hold');
end

%EMG patterns for tgts
for t=1:numTgts
    figure;
    theta = 0:2*pi()/(numEMGs):2*pi();
    %same trick here:
    P = polar(theta, ones(size(theta)));
    set(P, 'Visible', 'off'); hold on;
    for n = 1:num_patterns
        rho = [varargin{n}(t+1,:) varargin{n}(t+1,1)];
        polar(theta,rho,col(n));
        title(sprintf('Target %g',t));
    end
end