

function LFP_ampl = ampl_lfp( lfp, varargin )

% assign input parameters
if nargin == 2
    win_size        = varargin{1};
elseif nargin == 3
    win_size        = varargin{1};
    win_end         = varargin{2};
end


