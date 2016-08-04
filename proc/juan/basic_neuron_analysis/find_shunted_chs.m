%
% Find channels with >= 50 % spike time coincidences in a Utah array. This
% is a wrapper for Matt Perich's crosstalk_analysis.m
%
%   function [shunted_chs, shunted_chs_summary] = find_shunted_chs( bdf_array )
%
% Inputs (optional)     : [default]
%   bdf_array           : BDF struct or array of BDFs
%   (use_sort)          : [false] use sorted channels (bool)
%
% Outputs
%   shunted_chs         : array with shunted channels, or cell array with
%                           shunted channels for each BDF, if bdf_array is
%                           an array
%   shunted_chs_summary : array with the channels that appear in >= 1 of
%                           the BDFs in bdf_array, if it is an array
%
%

function [shunted_chs, shunted_chs_summary] = find_shunted_chs( bdf_array, varargin )

if nargin == 1
    use_sort            = false;
else
    use_sort            = varargin{1};
end

% we assume that channels that appear as test and ref with >=
% max_perc_coinc are shunted
max_perc_coinc          = 50;
nbr_bdfs                = length(bdf_array);

if nbr_bdfs > 1
    shunted_chs         = cell(1,nbr_bdfs);
end

for i = 1:nbr_bdfs
    
    % calculate percentage of spike coincidences
    ctlk                = crosstalk_analysis(bdf_array(i),'spike','do_plots',true,'use_sort',use_sort);
    [ref_chs, test_chs] = find(ctlk>max_perc_coinc);
    
    % find channels that appear as reference and test
    shunted_chs_this    = intersect(ref_chs,test_chs);
    
    
    % if we've passed an array of BDFs save all values, otherwise just
    % return the shunted channels for this BDF
    if nbr_bdfs > 1
        shunted_chs{i}  = shunted_chs_this;
    else
        shunted_chs     = shunted_chs_this;
    end
end

% Find all shunted channels
if nbr_bdfs > 1
    shunted_chs_summary = [];
    for i = 1:nbr_bdfs
        shunted_chs_summary = union(shunted_chs_summary,shunted_chs{i});
    end
else
    shunted_chs_summary = shunted_chs;
end