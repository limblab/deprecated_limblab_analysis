function units = get_units_plx(filename, opts)
% GET_UNITS_PLX extracts the units from the named plx file
%   UNITS = GET_UNITS_PLX(FILENAME, VERBOSE) returns the bdf.units 
%       structure from the named plx file.  If a progress bar is desired
%       the handle to the waitbar is passed as VERBOSE.  To not display a 
%       progress bar, pass 0.

% $Id$

    %if verbose ~= 0
    %    h = verbose;
    %    progress = 0;
    %end

    if opts.verbose
        disp('Reading units...')
    end
    
    % Get general info needed for events and units
    tscounts = plx_info(filename, 1);
    [max_num_units num_channels] = size(tscounts);

    %
    % Get Units 
    %
    num_total_units = sum(sum(tscounts > 0));
    ids = cell(1, num_total_units);
    tss = cell(1, num_total_units);
    unit_counter = 1;

    for chan = 1:num_channels-1
        %if (verbose == 1)
        %    progress = progress + .3/num_channels;
        %    waitbar(progress, h, sprintf('Opening: %s\nget units (%d)', filename, chan));
        %end
        if opts.verbose
            disp(sprintf('Spike channel: %d', chan));
        for unit = 1:max_num_units-1
            % only create a unit if it has spikes
            if (tscounts(unit+1, chan+1) > 0)
                [n, ts] = plx_ts(filename, chan, unit);

                ids{unit_counter} = [chan unit];
                tss{unit_counter} = ts;

                unit_counter = unit_counter + 1;
            end
        end
    end

    units = struct('id', ids, 'ts', tss); 
end
