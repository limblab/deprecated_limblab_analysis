%
% fig_lfp_freq
%

function fig_lfp_freq( neural_activity_bsln, varargin )

% Assign input parameters
if nargin == 3
    neural_activity_tDCS    = varargin{1};
    neural_activity_post    = varargin{2};
elseif nargin == 2
    neural_activity_tDCS    = varargin{1};
end
    

% plot the power spectra, along with the mean and SD
figure,hold on
plot( neural_activity_bsln.lfp.Pxx.f, 10*log10(abs(neural_activity_bsln.lfp.Pxx.mean)),...
    'k','linewidth',3 ) 
plot( neural_activity_bsln.lfp.Pxx.f, 10*log10(abs(neural_activity_bsln.lfp.Pxx.mean +...
    neural_activity_bsln.lfp.Pxx.std)),'-.k','linewidth',.5 )
plot( neural_activity_bsln.lfp.Pxx.f, 10*log10(abs(neural_activity_bsln.lfp.Pxx.mean -...
    neural_activity_bsln.lfp.Pxx.std)),'-.k','linewidth',.5 )
if exist('neural_activity_tDCS','var')
    plot( neural_activity_tDCS.lfp.Pxx.f, 10*log10(abs(neural_activity_tDCS.lfp.Pxx.mean)),...
        'r','linewidth',3 ) 
    plot( neural_activity_tDCS.lfp.Pxx.f, 10*log10(abs(neural_activity_tDCS.lfp.Pxx.mean + ...
        neural_activity_tDCS.lfp.Pxx.std)),'-.r','linewidth',.5 )
    plot( neural_activity_bsln.lfp.Pxx.f, 10*log10(abs(neural_activity_tDCS.lfp.Pxx.mean -...
        neural_activity_tDCS.lfp.Pxx.std)),'-.r','linewidth',.5 )
end
if exist('neural_activity_post','var')
    plot(neural_activity_post.lfp.Pxx.f,10*log10(abs(neural_activity_post.lfp.Pxx.mean)),...
        'b','linewidth',3 ), 
    plot(neural_activity_post.lfp.Pxx.f,10*log10(abs(neural_activity_post.lfp.Pxx.mean +...
        neural_activity_bsln.lfp.Pxx.std)),'-.b','linewidth',.5 )
    plot(neural_activity_post.lfp.Pxx.f,10*log10(abs(neural_activity_post.lfp.Pxx.mean -...
        neural_activity_bsln.lfp.Pxx.std)),'-.b','linewidth',.5 )
end
set(gca,'FontSize',14), set(gca,'TickDir','out'), xlim([0 80])
xlabel('Frequency (Hz)','FontSize',14),ylabel('Power','FontSize',14)


% plot the mean spectrograms
ylim2               = 80;
fspec = figure;
if nargin == 3
    subplot(311)
    mesh( neural_activity_bsln.lfp.spec.t, neural_activity_bsln.lfp.spec.f, ...
        10*log10(abs(neural_activity_bsln.lfp.spec.mean)) )
    view(2), xlim([0 neural_activity_bsln.lfp.spec.t(end)]), ylim([0 ylim2])
    set(gca,'FontSize',14), set(gca,'TickDir','out'), colorbar
    xlabel('Time (s)','FontSize',14),ylabel('Frequency (Hz)','FontSize',14)
    subplot(312)
    mesh( neural_activity_tDCS.lfp.spec.t, neural_activity_tDCS.lfp.spec.f, ...
        10*log10(abs(neural_activity_tDCS.lfp.spec.mean)) )
    view(2), xlim([0 neural_activity_tDCS.lfp.spec.t(end)]), ylim([0 ylim2])
    set(gca,'FontSize',14), set(gca,'TickDir','out'), colorbar
    xlabel('Time (s)','FontSize',14),ylabel('Frequency (Hz)','FontSize',14)
    subplot(313)
    mesh( neural_activity_post.lfp.spec.t, neural_activity_post.lfp.spec.f, ...
        10*log10(abs(neural_activity_post.lfp.spec.mean)) )
    view(2), xlim([0 neural_activity_post.lfp.spec.t(end)]), ylim([0 ylim2])
    set(gca,'FontSize',14), set(gca,'TickDir','out'), colorbar
    xlabel('Time (s)','FontSize',14),ylabel('Frequency (Hz)','FontSize',14)
elseif nargin == 2
    subplot(211)
    mesh( neural_activity_bsln.lfp.spec.t, neural_activity_bsln.lfp.spec.f, ...
        10*log10(abs(neural_activity_bsln.lfp.spec.mean)) )
    view(2), xlim([0 neural_activity_bsln.lfp.spec.t(end)]), ylim([0 ylim2])
    set(gca,'FontSize',14), set(gca,'TickDir','out'), colorbar
    xlabel('Time (s)','FontSize',14),ylabel('Frequency (Hz)','FontSize',14)
        subplot(212)
    mesh( neural_activity_tDCS.lfp.spec.t, neural_activity_tDCS.lfp.spec.f, ...
        10*log10(abs(neural_activity_tDCS.lfp.spec.mean)) )
    view(2), xlim([0 neural_activity_tDCS.lfp.spec.t(end)]), ylim([0 ylim2])
    set(gca,'FontSize',14), set(gca,'TickDir','out'), colorbar
    xlabel('Time (s)','FontSize',14),ylabel('Frequency (Hz)','FontSize',14)
else
    mesh( neural_activity_bsln.lfp.spec.t, neural_activity_bsln.lfp.spec.f, ...
        10*log10(abs(neural_activity_bsln.lfp.spec.mean)) )
    view(2), xlim([0 neural_activity_bsln.lfp.spec.t(end)]), ylim([0 ylim2])
    set(gca,'FontSize',14), set(gca,'TickDir','out'), colorbar
    xlabel('Time (s)','FontSize',14),ylabel('Frequency (Hz)','FontSize',14)
end


% Color axis
cax1 = 10*log10( min( ...
    [min(abs(neural_activity_bsln.lfp.spec.mean(1:find(neural_activity_bsln.lfp.spec.f>ylim2,1),:))) ...
    min(abs(neural_activity_tDCS.lfp.spec.mean(1:find(neural_activity_bsln.lfp.spec.f>ylim2,1),:))) ...
    min(abs(neural_activity_post.lfp.spec.mean(1:find(neural_activity_bsln.lfp.spec.f>ylim2,1),:))) ]));
cax2 = 10*log10( max( ...
    [max(abs(neural_activity_bsln.lfp.spec.mean(1:find(neural_activity_bsln.lfp.spec.f>ylim2,1),:))) ...
    max(abs(neural_activity_tDCS.lfp.spec.mean(1:find(neural_activity_bsln.lfp.spec.f>ylim2,1),:))) ...
    max(abs(neural_activity_post.lfp.spec.mean(1:find(neural_activity_bsln.lfp.spec.f>ylim2,1),:))) ]));

nbr_specs           = length(findall(fspec,'type','axes'))/2;

figure(fspec)
for i = 1:nbr_specs
    subplot(nbr_specs,1,i), caxis([cax1, cax2])
end

