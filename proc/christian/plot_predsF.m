function [vaf,R2,predsF] = plot_predsF(testdata,decoders,mode,varargin)
% decoders = {N2E;E2F} or N2F

plot_flag = true;
if nargin > 4
    plot_flag = varargin{1};
end

spikes = testdata.spikeratedata;

if ~strcmp(mode,'direct')
    predsE = sigmoid(predMIMOCE3(spikes,decoders{1}.H),'direct');
    % predsE = predMIMOCE3(spikes,N2E.H);
    % predsF = predMIMOCE3(sigmoid(predsE,'direct'),E2F.H);
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
