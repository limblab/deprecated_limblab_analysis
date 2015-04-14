%
% Function to plot the cortical map with data recorded with the
% stim_trig_avg_simple3() function.
%
%
%   varargout = calculate_sta_metrics( emg, sta_params )
%
%       EMG: structure that contains the evoked EMG response (per stim) and
%       other EMG information
%       STA_PARAMS: structure that contains general information on the
%       experiment
%
%       STA_METRICS: metrics that characterize PSF: 1) Fetz' and Cheney's
%       MPSF; 2) Polyakov and Schiebert's statistics 
%
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       % ToDos:
%       - Calculate MPSI, analogously to MPSF
%       - Resample all EMGs to 4 kHz? (or at least downsample form 10 kHz
%       to 4 kHz)
%



function varargout = calculate_sta_metrics( emg, sta_params, varargin )



if nargin == 2
    
    sta_metrics_params = calculate_sta_metrics_default();
elseif nargin == 3
   
    sta_metrics_params          = varargin{1};
else 
    disp('the function only takes 2 or 3 parameters')
end


if nargout > 1
    
    disp('the funciton only returns one variable of type sta_metrics')
    return;
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
% Calculate the "Mean percent facilitation" (Cheney & Fetz, 1985) - height
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
% Calculate "Multiple fragment statistical analysis," (Poliakov &
% Schiebert, 1998)


% Definitions for the intervals in which we will divide the data
% for clarity, the values are first specified in ms and then transformed to
% indexes in the vectors
r_T_intvl                       = [8 18];
r_c1_intvl                      = [-12 -2];
r_c2_intvl                      = [18 28];

r_T_intvl                       = (r_T_intvl + sta_params.t_before) * emg.fs /1000 + 1;
r_c1_intvl                      = (r_c1_intvl + sta_params.t_before) * emg.fs /1000 + 1;
r_c2_intvl                      = (r_c2_intvl + sta_params.t_before) * emg.fs /1000 + 1;

% check that we are not outside margins
if min(t_emg(r_c1_intvl)) < -sta_params.t_before
    disp('the r_c1 interval falls outside limits');
    return;
end

if max(t_emg(r_c2_intvl)) > sta_params.t_after
    disp('the r_c2 interval falls outside limits');
    return;
end


% 1. Divide the dataset into sqrt(nbr of stimuli) non-overlapping windows
% (of size sqrt(nbr of spikes)) 

nbr_non_overlap_wdws            = floor(sqrt(length(emg.evoked_emg)));
Xj_MFSA                         = zeros( nbr_non_overlap_wdws, emg.nbr_emgs );
r_T                             = zeros( nbr_non_overlap_wdws, emg.nbr_emgs );
r_c1                            = zeros( nbr_non_overlap_wdws, emg.nbr_emgs );
r_c2                            = zeros( nbr_non_overlap_wdws, emg.nbr_emgs );
%Z_MFSA                          = zeros( nbr_non_overlap_wdws, emg.nbr_emgs );
P_Z_test                        = zeros( 1, emg.nbr_emgs );


% 2. Calculate the mean SpTA rEMG for each segment, 'mean_temp_STAs_MFSA'

for i = 1:emg.nbr_emgs
    
    for ii = 1:nbr_non_overlap_wdws
       
        temp_start_indx         = 1+(ii-1)*nbr_non_overlap_wdws;
        temp_end_indx           = ii*nbr_non_overlap_wdws;
        
        % 'temp_StTAs_MFSA' is the mean rectified EMG for this 'fragment',
        % and muscle
        temp_StTAs_MFSA         = mean(abs(squeeze(emg.evoked_emg(:,i,temp_start_indx:temp_end_indx))),2);
        
        % 3. Calculate the test parameter X for each segment. 
        % 	X_j = mean(r_T - (r_c1 + r_C2)/2 (j = 1:nr_non_overlap_wdws)
        r_T(ii,i)               = mean(temp_StTAs_MFSA(r_T_intvl));
        r_c1(ii,i)              = mean(temp_StTAs_MFSA(r_c1_intvl));
        r_c2(ii,i)              = mean(temp_StTAs_MFSA(r_c2_intvl));
        
        Xj_MFSA(ii,i)           = r_T(ii,i) - (r_c1(ii,i) + r_c2(ii,i))/2;
                
    end
        
    % 4. Test the null hypothesis that the mean value of X was zero
    % with a two-tailed z-test.
    %   Take the mean and SD of the sample population and the
    %   standard (i.e. ~N(0,1)) normal distribution

    [~, P_Z_test(i)]             = ztest(Xj_MFSA(:,i),0,1);
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return metrics
    

sta_metrics.nbr_stims           = sta_metrics_params.last_evoked_EMG - sta_metrics_params.first_evoked_EMG + 1;
sta_metrics.mean_emg            = mean_emg;
sta_metrics.mean_baseline_emg   = mean_mean_baseline_emg;
sta_metrics.std_baseline_emg    = std_mean_baseline_emg;

sta_metrics.MPSF                = MPSF;
sta_metrics.t_after_stim_start_PSF = t_after_stim_start_PSF;
sta_metrics.duration_MPSF       = duration_PSF;

sta_metrics.P_Ztest             = P_Z_test;
sta_metrics.Xj_Ztest            = Xj_MFSA;


if nargout == 1
   
    varargout{1}                = sta_metrics;
end



% Plot, if specified in 'sta_metrics_params.plot_yn'
if sta_metrics_params.plot_yn
    
    plot_sta( emg, sta_params, sta_metrics );
end