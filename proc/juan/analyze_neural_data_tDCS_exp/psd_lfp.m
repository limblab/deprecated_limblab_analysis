% 
% Function to compute the PSD of an array of LFP. 
%
%   LFP = PSD_LFP( lfp, win_size )  calculates the FFT of the array of LFPs
%   "lfp" in a window of size "win_size" (ms). "lfp" is a struct that
%   follows the usual BDF structure. "win_size" can be either a double or a
%   2-D array (start and end window time). The FFT will be computed using
%   XXXXXXXXXX 
%   LFP = PSD_LFP( lfp, win_size, win_end )  calculates the FFT of the
%   array of LFPs "lfp" in a window of size "win_size" (ms). "lfp" is a
%   struct that follows the usual BDF structure. "win_size" can be either a
%   double or a 2-D array (start and end window time). "win_end" specifies
%   the end of the window (s). The FFT will be computed using XXXXXXXXXX  
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


% compute the Welch periodogram ---the power, not the PSD (change 'power'
% by 'psd' if you want the PSD)   
pxx                 = zeros(nfft/2+1,size(lfp.lfpnames,2));
f                   = lfp.lfpfreq*(0:(nfft/2))/nfft;
for i = 1:size(lfp.lfpnames,2)
    pxx(:,i)        = pwelch(lfp.data(:,i+1),psd_window,noverlap,nfft,lfp.lfpfreq,'power');
end

figure,hold on
plot(f,10*log10(pxx),'color',[.7 .7 .7]), xlim([0 50])
plot(f,10*log10(mean(pxx,2)),'b','linewidth',2), xlim([0 50])
plot(f,10*log10(mean(pxx,2)+std(pxx,0,2)),'-.b','linewidth',2), xlim([0 50])
plot(f,10*log10(mean(pxx,2)-std(pxx,0,2)),'-.b','linewidth',2), xlim([0 50])
xlabel('Frequency (Hz)'),ylabel('Power')


% compute the spectrogram, in non-overlapping windows of length = window
% length, to assess the time course of the LFP
[spec, f_spec, t_spec] = spectrogram(double(lfp.data(:,2)),psd_window,0,nfft,lfp.lfpfreq);
figure,mesh(t_spec,f_spec,10*log10(abs(spec))),
colorbar, 
% CAMBIAR CAXIS caxis([min])
view(2), xlim([0 t_spec(end)]), ylim([0 200])
xlabel('Time (s)'),ylabel('Frequency (Hz)')


% Return variables
LFP.pxx             = pxx;
LFP.f               = f;
