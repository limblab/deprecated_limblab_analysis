%
% Compute and plot some summary behavior stats.
%
%   funcion behavior_stats = check_behavior_data( bdf_array, task ) 
%
% Inputs (opt)              : [defaults]
%   bdf                     : BDF or array of BDFs
%   (task)                  : [wf] task ('wf','mg'). WF encompasses the
%                               wrist movement, isometric and spring tasks
%
% Outputs:
%   behavior_stats          : behavior stats.


function behavior_stats = check_behavior_data( bdf_array, varargin ) 

nbr_bdfs            = length(bdf_array);

% input arguments
if nargin == 2
    task            = varargin{1};
else
    task            = 'wf';
end


% get trial table
switch task
    case 'wf'
        if nbr_bdfs > 1
            for i = 1:nbr_bdfs
                tt{i}   = wf_trial_table( bdf_array(i) );
            end
        else
            tt          = wf_trial_table( bdf_array );
        end
    case 'mg'
        if nbr_bdfs > 1
            for i = 1:nbr_bdfs
                tt{i}   = mg_trial_table( bdf_array(i) );
            end
        else
            tt          = mg_trial_table( bdf_array );
        end
    otherwise
        error('only works with mg and wf tasks');
end


% return values
behavior_stats      = tt;
if nbr_bdfs > 1
    for i = 1:nbr_bdfs
        
    end
else
    
end

