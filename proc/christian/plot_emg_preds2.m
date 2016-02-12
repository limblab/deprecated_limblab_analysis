function [vaf,R2,preds] = plot_emg_preds2(testdata,N2E,E2F,varargin)
% E2F = load('/Users/christianethier/Dropbox/Adaptation/temp_data/Jango_20140711_IRFm.mat');
% load('/Users/christianethier/Dropbox/Adaptation/temp_data/Jango_20140711_3m_TEST.mat');

if nargin >3
    ev = varargin{1};
    % with 4FakeEMGs_data: ev = [4 2 1 6]
else
    ev = 1:size(testdata.emgdatabin,2);
end

spikes = testdata.spikeratedata;

predsE = sigmoid(predMIMOCE3(spikes,N2E.H),'direct');
% predsE = predMIMOCE3(spikes,N2E.H);
% predsF = predMIMOCE3(sigmoid(predsE,'direct'),E2F.H);
predsF = predMIMOCE3(predsE,E2F.H);

preds = [predsE predsF];

plot_data = [testdata.emgdatabin(:,ev) testdata.cursorposbin];
plot_labels= [testdata.emgguide(ev,:) ;testdata.cursorposlabels];
% 
% plot_data = [testdata.cursorposbin];
% plot_labels= [testdata.cursorposlabels];

% ttl = '';
% if nargin > 4
%     ttl = varargin{2};
% end

% figure;
num_figs = size(plot_data,2);
vaf = nan(num_figs,1);
R2 = nan(num_figs,1);

for i = 1:num_figs
%     subplot(num_figs,1,i);
    figure;
    hold on;
    plotLM(testdata.timeframe,preds(:,i),'r');
    plotLM(testdata.timeframe,plot_data(:,i),'k');
    R2(i)  = CalculateR2(preds(:,i),plot_data(:,i));
    vaf(i) = calc_vaf(preds(:,i),plot_data(:,i));
    title([plot_labels(i,:) ' ' ttl]);
    legend(sprintf('pred (R^2 = %.2f)',R2(i)),'act');
    xlim([178 208]);
    if i>length(ev)
        ylim([-15 15]);
    else
        ylim([0 1.2]);
    end
end
