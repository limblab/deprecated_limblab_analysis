

function LFP_ampl = ampl_lfp( lfp, varargin )

% assign input parameters
if nargin == 2
    win_size        = varargin{1};
elseif nargin == 3
    win_size        = varargin{1};
    win_end         = varargin{2};
end


% Create a matrix that contains the LFP in each window
data                = zeros( (abs(diff(win_size))+1)*lfp.lfpfreq/1000, numel(win_end), size(lfp.data,2) );

for i = 1:numel(win_end) 
    start_idx       = 1+(i-1)*(abs(diff(win_size))+1)*lfp.lfpfreq/1000;
    stop_idx        = i*(abs(diff(win_size))+1)*lfp.lfpfreq/1000;
    data(:,i,:)     = lfp.data(start_idx:stop_idx,:);
end

LFP_ampl.t_domain.data   = data;