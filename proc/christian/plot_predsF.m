function [vaf,R2,predsF,predsE,figh] = plot_predsF(testdata,decoders,mode,varargin)
% decoders = {N2E;E2F} or N2F

plot_flag = true; emg_convolve = 1; emg_thresh = 0; title_str = ''; plot_EMGs = 0;
if nargin > 3 && ~isempty(varargin)
    if nargin > 3 plot_flag    = varargin{1}; end
    if nargin > 4 emg_convolve = varargin{2}; end
    if nargin > 5 emg_thresh   = varargin{3}; end
    if nargin > 6 title_str    = varargin{4}; end
    if nargin > 7 plot_EMGs    = varargin{5}; end
end
n_chan = size(decoders{1}.neuronIDs,1);
spikes = zeros(size(testdata.spikeratedata,1),n_chan);

[~,test_idx,filt_idx] = intersect(testdata.neuronIDs,decoders{1}.neuronIDs,'rows','stable');

spikes(:,filt_idx) = testdata.spikeratedata(:,test_idx);

if ~strcmp(mode,'direct')
    predsE = sigmoid(predMIMOCE3(spikes,decoders{1}.H),'direct');
    
    % apply emg_convolve to E2F.H:
    n_emgs   = size(decoders{1}.H,2);
    n_forces = size(decoders{2}.H,2);
    emg_convolve = emg_convolve/sum(emg_convolve);
          decoders{2}.H = reshape((rowvec(decoders{2}.H)*emg_convolve)',...
                                            length(emg_convolve)*n_emgs,n_forces);
    
    predsF = predMIMOCE3(predsE,decoders{2}.H);
else
    predsE = [];
    predsF = predMIMOCE3(spikes,decoders{1}.H);
end
    
    
f_data = [testdata.cursorposbin];
f_labels= {'Fx'; 'Fy'};
% 
% plot_data = [testdata.cursorposbin];
% plot_labels= [testdata.cursorposlabels];

% figure;
num_figs = size(f_data,2);
figh = nan(1,num_figs);
vaf = nan(num_figs,1);
R2 = nan(num_figs,1);

t_range = [testdata.timeframe(1) testdata.timeframe(1)+30];

for i = 1:num_figs
    R2(i)  = CalculateR2(predsF(:,i),f_data(:,i));
    vaf(i) = calc_vaf(predsF(:,i),f_data(:,i));
    if plot_flag
        figh(1,i) = figure;
        hold on;
        
        plotLM(testdata.timeframe,predsF(:,i));
        plotLM(testdata.timeframe,f_data(:,i));
        %     pretty_fig(gca);
        
        ylabel(f_labels(i,:)); xlabel('time (s)');
        legend(sprintf('pred (R^2=%.2f,vaf=%.2f)',R2(i),vaf(i)),'act');
        xlim(t_range);
        ylim([-15 15]);
        if ~isempty(title_str)
            title(title_str);
        end
    end
end

if plot_EMGs
    e_labels = {'ECRb','ECRl','FCR','FCU','ECU'};
    for i = 1:n_emgs
        figure;
        plot(testdata.timeframe,predsE(:,i));
        ylabel(e_labels{i});xlabel('time (s)');
        xlim(t_range);
        ylim([0 1]);
    end
end
    