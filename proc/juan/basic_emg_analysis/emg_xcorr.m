%

% check EMG correlation
function emg_xcorr_data = emg_xcorr( binned_data, varargin )


% remove selected emgs
if nargin == 2
    for i = 1:length(binned_data)
        binned_data(i).emgdatabin(varargin{1})  = [];
        binned_data(i).emgguide(varargin{1})    = [];
    end
end

% lags to compute the XCorr, in number of bins
my_lags                 = 30;

% some definitions
nbr_bdfs                = length(binned_data);
nbr_emgs                = length(binned_data(1).emgguide);

emg_xcorr_data          = struct('data',[],'lags',[],'emg_pair',[]);


% compute the xcorrs
for i = 1:nbr_bdfs  
    for ii = 1:nbr_emgs
    
        % matrix with the indexes of the rest of the EMGs
        other_emgs      = setdiff(1:nbr_emgs,ii);
        
        for iii = 1:nbr_emgs-1
            [aux_xcorr, aux_lags]       = xcorr( binned_data(i).emgdatabin(:,ii), ...
                binned_data(i).emgdatabin(:,other_emgs(iii)), my_lags );
            
            this_pair                   = [ii other_emgs(iii)];
            
            emg_xcorr_data(i).data      = [emg_xcorr_data(i).data, aux_xcorr];
            emg_xcorr_data(i).lags      = aux_lags';
            emg_xcorr_data(i).emg_pair  = [emg_xcorr_data(i).emg_pair; this_pair];
        end
    end
end

% add the EMGs that were analyzed to the struct --important in case some
% were discarded
