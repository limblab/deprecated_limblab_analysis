function idx=skip_resets(ts)
    %checks for resets in the timestamps and return the index of the first
    %point after the reset, so that we can truncate data with mixed up
    %times and avoid the problem
    dn = diff(ts);
    if any(dn<0) %test whether there was a ts reset in the file
        idx = find(dn<0,1,'last');
        if length(idx)>1
            warning('skip_resets:MultipleResets', ['timeseries contains more than one ts reset.'...
                    'Only the data after the last reset is extracted.']);
        end
    else
        idx=[];%if there were no resets, set the index to empty
    end
end