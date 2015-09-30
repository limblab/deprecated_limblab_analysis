% 
% Function to compute the PSD of an array of LFP. 
%
%   LFP = PSD_LFP( lfp, win_size )  calculates the power spectrum of the
%   array of LFPs "lfp" in a window of size "win_size" (ms). "lfp" is a
%   struct that follows the usual BDF structure. "win_size" can be either a
%   double or a 2-D array (start and end window time). 
%   LFP = PSD_LFP( lfp, win_size, win_end )  calculates the FFT of the
%   array of LFPs "lfp" in a window of size "win_size" (ms). "lfp" is a
%   struct that follows the usual BDF structure. "win_size" can be either a
%   double or a 2-D array (start and end window time). "win_end" specifies
%   the end of the window (s). 
%


function LFP = psd_lfp( lfp, varargin )

% assign input parameters
if nargin == 2
    win_size        = varargin{1};
elseif nargin == 3
    win_size        = varargin{1};
    win_end         = varargin{2};
end

% parameters for the PSD
noverlap            = lfp.lfpfreq/5;
% ... if we are using cursor velocity or EMG as behavior signals
if ~exist('win_end','var')
    psd_window      = 2*lfp.lfpfreq;                         % 2 s
% ... if we are using words
else
    psd_window      = abs(diff(win_size))+1;
end
nfft                = 2^nextpow2(psd_window);


% 1. Welch periodogram ---the power, not the PSD (change 'power' by 'psd'
% if you want the PSD)    
pxx                 = zeros(nfft/2+1,size(lfp.lfpnames,2));
f                   = lfp.lfpfreq*(0:(nfft/2))/nfft;
for i = 1:size(lfp.lfpnames,2)
    pxx(:,i)        = pwelch(lfp.data(:,i+1),psd_window,noverlap,nfft,lfp.lfpfreq,'power');
end

% calculate the mean and SD of the power spectra
mean_pxx            = mean(pxx,2);
std_pxx             = std(pxx,0,2);


% 2. Spectrogram, in non-overlapping windows of length = window length
t_spec              = linspace( psd_window/lfp.lfpfreq/2, ...
    psd_window/lfp.lfpfreq/2+(size(win_end,1)-1)*psd_window/lfp.lfpfreq, size(win_end,1) );
spec                = zeros(nfft/2+1,size(win_end,1),size(lfp.lfpnames,2));
for i = 1:size(lfp.lfpnames,2)
   spec(:,:,i)      = spectrogram(double(lfp.data(:,i+1)),psd_window,0,nfft,lfp.lfpfreq);
end

% calculate the mean and SD of the spectrogram across all channels
mean_spec           = mean(spec,3);
std_spec            = std(spec,0,3);



% ------------------------------------------------------------------------
% Plots

% plot the power spectra, along with the mean and SD
figure,hold on
plot(f,10*log10(abs(pxx)),'color',[.7 .7 .7]), 
plot(f,10*log10(abs(mean(pxx,2))),'b','linewidth',2), 
plot(f,10*log10(abs(mean_pxx+std_pxx)),'-.b','linewidth',2)
plot(f,10*log10(abs(mean_pxx-std_pxx)),'-.b','linewidth',2), xlim([0 80])
xlabel('Frequency (Hz)'),ylabel('Power')

% plot the mean spectrogram and the SD
ylim2               = 80;
figure,mesh(t_spec,f,10*log10(abs(mean_spec))),
colorbar, 
view(2), xlim([0 t_spec(end)]), ylim([0 ylim2])
xlabel('Time (s)'),ylabel('Frequency (Hz)')

cax1 = 10*log10(min(min(abs(mean_spec(1:find(f>ylim2,1),:)))));
cax2 = 10*log10(max(max(abs(mean_spec(1:find(f>ylim2,1),:)))));
caxis([cax1, cax2])


% Return variables
LFP.Pxx.data        = pxx;
LFP.Pxx.f           = f';
LFP.Pxx.mean        = mean_pxx;
LFP.Pxx.std         = std_pxx;

LFP.spec.data       = spec;
LFP.spec.f          = f';
LFP.spec.t          = t_spec;
LFP.spec.mean       = mean_spec;
LFP.spec.std        = std_spec;
