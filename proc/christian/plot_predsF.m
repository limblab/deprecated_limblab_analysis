function [vaf,R2,predsF] = plot_predsF(testdata,decoders,mode,varargin)
% decoders = {N2E;E2F} or N2F

plot_flag = true; emg_convolve = 1;
if nargin > 3 plot_flag = varargin{1}; end
if nargin > 4 emg_convolve = varargin{2}; end

n_chan = size(decoders{1}.neuronIDs,1);
spikes = zeros(size(testdata.spikeratedata,1),n_chan);

[~,test_idx,filt_idx] = intersect(testdata.neuronIDs,decoders{1}.neuronIDs,'rows','stable');

spikes(:,filt_idx) = testdata.spikeratedata(:,test_idx);

if ~strcmp(mode,'direct')
    predsE = sigmoid(predMIMOCE3(spikes,decoders{1}.H),'direct');
    % predsE = predMIMOCE3(spikes,N2E.H);
    % predsF = predMIMOCE3(sigmoid(predsE,'direct'),E2F.H);
    
    % apply emg_convolve to E2F.H:
    n_emgs   = size(decoders{1}.H,2);
    n_forces = size(decoders{2}.H,2);
    emg_convolve = emg_convolve/sum(emg_convolve);
          decoders{2}.H = reshape((rowvec(decoders{2}.H)*emg_convolve)',...
                                            length(emg_convolve)*n_emgs,n_forces);
    
    predsF = predMIMOCE3(predsE,decoders{2}.H);
else
    predsF = predMIMOCE3(spikes,decoders{1}.H);
end
    
    
f_data = [testdata.cursorposbin];
f_labels= {'Fx'; 'Fy'};
% 
% plot_data = [testdata.cursorposbin];
% plot_labels= [testdata.cursorposlabels];

% figure;
num_figs = size(f_data,2);
vaf = nan(num_figs,1);
R2 = nan(num_figs,1);

t_range = [testdata.timeframe(1) testdata.timeframe(1)+30];

for i = 1:num_figs
    R2(i)  = CalculateR2(predsF(:,i),f_data(:,i));
    vaf(i) = calc_vaf(predsF(:,i),f_data(:,i));
    if plot_flag
        figure;
        hold on;
        
        plotLM(testdata.timeframe,predsF(:,i));
        plotLM(testdata.timeframe,f_data(:,i));
        %     pretty_fig(gca);
        
        ylabel(f_labels(i,:)); xlabel('time (s)');
        legend(sprintf('pred (R^2=%.2f,vaf=%.2f)',R2(i),vaf(i)),'act');
        xlim(t_range);
        ylim([-15 15]);
    end
end
