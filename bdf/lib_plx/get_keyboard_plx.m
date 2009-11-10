function keyboard_events = get_keyboard_plx(filename, opts)
% GET_KEYBOARD_PLX extracts the units from the named plx file
%   UNITS = GET_KEYBOARD_PLX(FILENAME, VERBOSE) returns the bdf.keyboard_events 
%       structure from the named plx file.  If a progress bar is desired
%       the handle to the waitbar is passed as VERBOSE.  To not display a 
%       progress bar, pass 0.

% $Id$

    %if verbose ~= 0
    %    h = verbose;
    %    progress = 0;
    %end

    if opts
        disp('Reading keyboard events...')
    end
    
    keyboard_events = [];
    for k = 1:9
        %if (verbose == 1)
        %    progress = progress + .1/9;
        %    waitbar(progress, h, sprintf('Opening: %s\nget keyboard events', filename));
        %end
        
        event_index = 100 + k;
        try 
            [n, ts] = plx_event_ts(filename, event_index);
        catch
            ts = [];
        end
        for evt = 1:length(ts)
            keyboard_events = [keyboard_events; ts(evt) k]; %#ok<AGROW>
        end
    end

end