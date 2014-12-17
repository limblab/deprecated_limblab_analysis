function vaf = plot_emg_preds(testdata,N2E,E2F,varargin)
% E2F = load('/Users/christianethier/Dropbox/Adaptation/temp_data/Jango_20140711_IRFm.mat');
% load('/Users/christianethier/Dropbox/Adaptation/temp_data/Jango_20140711_3m_TEST.mat');
spikes = testdata.spikeratedata;

predsE = predMIMOCE3(spikes,N2E.H);
% predsE = predMIMOCE3(spikes,N2E.H);
% predsF = predMIMOCE3(sigmoid(predsE,'direct'),E2F.H);
predsF = predMIMOCE3(predsE,E2F.H);
preds = [predsE predsF];
% preds = predsE;

plot_data = [testdata.emgdatabin testdata.cursorposbin];
plot_labels= [testdata.emgguide;testdata.cursorposlabels];
% 
% plot_data = [testdata.cursorposbin];
% plot_labels= [testdata.cursorposlabels];

ttl = '';
if nargin > 3
    ttl = varargin{1};
end

% figure;
num_figs = size(plot_data,2);
vaf = nan(num_figs,1);

for i = 1:num_figs
%     subplot(num_figs,1,i);
    figure;
    hold on;
    plotLM(testdata.timeframe,preds(:,i),'r');
    plotLM(testdata.timeframe,plot_data(:,i),'k');
    vaf(i) = calc_vaf(preds(:,i),plot_data(:,i));
    title([plot_labels(i,:) ' ' ttl]);
    legend(sprintf('pred (vaf = %.2f)',vaf(i)),'act');
    xlim([500 530]);
end
 
% for i = 1:3
%     subplot(3,1,i);
%     plot(testdata.timeframe,testdata.emgdatabin(:,i),'k');
%     hold on;
%     plot(testdata.timeframe,preds(:,i),'r');
%     vaf = calc_vaf(preds(:,i),testdata.emgdatabin(:,i));
%     title(testdata.emgguide(i,:));
%     legend('act',sprintf('pred (vaf = %.2f)',vaf));
% end
% 
% figure;
% for i = 1:2
%     subplot(2,1,i);
%     plot(testdata.timeframe,testdata.cursorposbin(:,i),'k');
%     hold on;
%     plot(testdata.timeframe,predsF(:,i),'r');
%     vaf = calc_vaf(predsF(:,i),testdata.cursorposbin(:,i));
%     title(testdata.cursorposlabels(i,:));
%     legend('act',sprintf('pred (vaf = %.2f)',vaf));
% end