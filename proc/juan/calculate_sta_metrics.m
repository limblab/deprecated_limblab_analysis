%
% Function to plot the cortical map with data recorded with the
% stim_trig_avg_simple3() function.
%
%
%   varargout = calculate_sta_metrics( emg, sta_params, varargin )
%
%       EMG: structure that contains the evoked EMG response (per stim) and
%       other EMG information
%       STA_PARAMS: structure that contains general information on the
%       experiment
%       VARARGIN: ...
%
%       STA_METRICS: metrics that characterize PSF: 1) Fetz' and Cheney's
%       MPSF; 2) Polyakov and Schiebert's statistics 
%
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       % ToDos:
%       - Calculate MPSI, analogously to MPSF
%       - Include Polyakov's and Schiebert's code
%



function sta_metrics = calculate_sta_metrics( emg, sta_params, varargin )



if nargin == 2
    
    sta_metrics_params = calculate_sta_metrics_default();
elseif nargin == 3
   
    sta_metrics_params          = varargin{1};
else 
    disp('the function only takes 2 or 3 parameters')
end



% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Some parameters to choose - read from the structure
% 
% min_duration_PSF             	= sta_metrics_params.min_duration_PSF;    % (ms) [has to be greater!]
% 
% 
% % For the MPSF by Fetz & Cheney
% beg_bsln                        = sta_metrics_params.beg_bsln;    % (ms) when the baseline begins [0 = the beginning]
% end_bsln                        = sta_metrics_params.t_before - 2;   % (ms) when the baseline ends [0 = the beginning] 
% t_after_stimulus                = sta_metrics_params.min_t_after_stim_PSF;    % (ms) minimum time for the EMG activity to be possibily considered an effect. Anything that happens earlier will be disregarded for the PSF  
% 


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you want to high pass filter the EMG...

if sta_metrics_params.hp_filter_EMG_yn
   
    % design the filter
    order                       = 1;
    W_n                         = sta_metrics_params.fc_hp_filter_EMG/(emg.fs/2);
    [a, b]                      = butter(order,W_n,'high');

    % filter all the EMG channels
    for i = 1:emg.nbr_emgs
        
        emg.evoked_emg_filt(:,i,:)  = filtfilt( a, b, squeeze(emg.evoked_emg(:,i,:)) );
    end
    
    % The hihg-pass filtered EMG will replace 'emg.evoked_emg'. The raw EMG
    % will be stored in new field 'evoked_EMG_raw'
    emg.evoked_emg_raw          = emg.evoked_emg;
    emg.evoked_emg              = emg.evoked_emg_filt;
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some preliminary stuff

% get rid of the EMG data epochs that are zero (because of a misalignment
% of the sync pulse in the time stamps and analog data that are read from
% central)

zero_emg_rows                   = all(emg.evoked_emg==0,1);
zero_emg_rows                   = squeeze(zero_emg_rows(1,1,:));    % array of logic variables that tell if that row is == 0
emg.evoked_emg(:,:,zero_emg_rows)   = [];


% check, if the 'last_evoked_EMG' ~= 0 (last sample), if the specified
% value is within limits
if ( sta_metrics_params.last_evoked_EMG == 0 ) || ( sta_metrics_params.last_evoked_EMG > length(emg.evoked_emg) )
    sta_metrics_params.last_evoked_EMG  = length(emg.evoked_emg);
    sta_metrics_params.last_evoked_EMG  = length(emg.evoked_emg);
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the StTAs
% Calculate mean (and SD) rectified EMG -> The mean is used to compute the STA

mean_emg                      	= mean(abs(emg.evoked_emg(:,:,sta_metrics_params.first_evoked_EMG:sta_metrics_params.last_evoked_EMG)),3);
%std_emg                                 = std(abs(emg.evoked_emg(:,:,first_evoked_emg:last_evoked_emg)),0,3);



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the 'Mean percent facilitation' (Cheney & Fetz, 1985) - height
% of the PSF peak above the mean baseline level, divided by the baseline
% noise  


% Calculate the mean and SD baseline EMG for each channel. 
% Fetz & Cheney calculate the baseline -5:5 ms w.r.t to the spike. Since we
% have stimulation artefacts I use -20:-2 ms as standard (more similarly to 
% (Griffin et al., 2009) 

mean_baseline_emg            	= mean(abs(emg.evoked_emg((sta_metrics_params.beg_bsln*emg.fs/1000+1):((sta_params.t_before - sta_metrics_params.end_bsln)*emg.fs/1000+1), ...
    :,sta_metrics_params.first_evoked_EMG:sta_metrics_params.last_evoked_EMG)),3);
mean_mean_baseline_emg          = mean(mean_baseline_emg,1);
std_mean_baseline_emg           = std(mean_baseline_emg,0,1);


% Look for a threshold (mean + 2*SD) crossing that lasts > 1 ms (the time
% specified in 'sta_metrics_params.min_duration_PSF'). The code start
% several ms after the stimulus (sta_metrics_params.min_t_after_stim_PSF)
% to avoid the effect of stimulation artefacts

start_PSF_win               	= (sta_params.t_before + sta_metrics_params.min_t_after_stim_PSF)*emg.fs/1000 + 1;
MPSF                            = zeros(emg.nbr_emgs,1);
duration_PSF                    = zeros(emg.nbr_emgs,1);
t_after_stim_start_PSF          = zeros(emg.nbr_emgs,1);

t_emg                           = -sta_params.t_before:1/emg.fs*1000:sta_params.t_after;       % in ms



for i = 1:emg.nbr_emgs
    
    
    % Look for the peak EMG activity 
    [~, aux_pos_max]            = max(mean_emg(start_PSF_win:end,i));
    pos_peak_PSF                = aux_pos_max + start_PSF_win - 1;      % this is the position of the peak wrt the beginnig 
    
    
    % See if the peak is above the baseline EMG (mean + 2*SD)
    aux_emg_without_bsln        = mean_emg(:,i) - ( mean_mean_baseline_emg(i) + 2*std_mean_baseline_emg(i) );
    
    if aux_emg_without_bsln(pos_peak_PSF) > 0
        
        start_PSF               = find(aux_emg_without_bsln(1:pos_peak_PSF-1) < 0, 1, 'last') + 1;
        end_PSF                 = find(aux_emg_without_bsln(pos_peak_PSF+1:end) < 0, 1) - 1 + pos_peak_PSF;
                
        if ( ~isempty(end_PSF) && ~isempty(start_PSF) ) && ( (end_PSF - start_PSF) > sta_metrics_params.min_duration_PSF*emg.fs/1000 )
                
            duration_PSF(i)     = (end_PSF - start_PSF)*1000/emg.fs;
            
            MPSF(i)             = ( mean(mean_emg(start_PSF:end_PSF,i)) - mean_mean_baseline_emg(i)) / mean_mean_baseline_emg(i) * 100;
            t_after_stim_start_PSF(i)   = t_emg(start_PSF );
        end
    end
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate MPSI - similar to MPSF but for inhibition

MPSI                            = zeros(emg.nbr_emgs,1);

% TODO!!




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return NPSF metrics
    
sta_metrics.MPSF                = MPSF;
sta_metrics.t_after_stim_start_PSF = t_after_stim_start_PSF;
sta_metrics.duration_MPSF       = duration_PSF;
sta_metrics.nbr_stims           = sta_metrics_params.last_evoked_EMG - sta_metrics_params.first_evoked_EMG + 1;
sta_metrics.mean_emg            = mean_emg;
sta_metrics.mean_baseline_emg   = mean_mean_baseline_emg;
sta_metrics.std_baseline_emg    = std_mean_baseline_emg;
