function raw = get_raw_plx(filename, opts)
% GET_RAW_PLX extracts the units from the named plx file
%   RAW = GET_RAW_PLX(FILENAME, VERBOSE) returns the bdf.raw 
%       structure from the named plx file.  If a progress bar is desired
%       the handle to the waitbar is passed as VERBOSE.  To not display a 
%       progress bar, pass 0.

% $Id$

    if opts.verbose
        disp('Reading continuous data...')
    end

    % list of channels that we care about
    [tscounts, wfcounts, evcounts] = plx_info(filename,1); %#ok<SETNU>
    chans_with_data = sum(evcounts(300:427) > 0);
    [n, chan_list] = plx_adchan_names(filename); %#ok<SETNU>

    chan_count = 1;
    if chans_with_data
        for i = 0:127             
            if evcounts(300+i) > 0 
                [adfreq, n, ts, fn, ad] = plx_ad(filename, i);

                if chans_with_data == size(chan_list, 1)
                    channame = chan_list(chan_count, :);
                else
                    channame = chan_list(i+1, :);
                end
                channame = deblank(channame);
                tmp_channels{chan_count} = channame;

                tmp_data{chan_count} = ad;
                tmp_ts{chan_count} = ts;

                chan_count = chan_count + 1;
            end           

            %if (verbose == 1)
            %    progress = progress + .3/64;
            %    waitbar(progress, h, sprintf('Opening: %s\nget analog (%d of %d)', filename, i+1, 64));
            %end
        end

        raw.analog.channels = tmp_channels;
        raw.analog.ts = tmp_ts;
        for i = 1:length(tmp_channels)
            raw.analog.data{i} = tmp_data{i} / 409.3; % scaling factor to convert a/d units to Volts
            raw.analog.adfreq(i) = adfreq; % This will always be the same for Plexon, but not necessarily for Cerebus
        end
    else
        raw.analog.channels = [];
        raw.analog.ts = [];
        raw.analog.data = [];
        raw.analog.adfreq = [];
    end
        
    % get strobed events and values
    if opts.verbose
        disp('Reading digital events...')
    end
    try
        [n, strobe_ts, strobe_value] = plx_event_ts(filename, 257);
        raw.enc = get_encoder([strobe_ts strobe_value]);
    catch
        er = lasterror;
        disp(er.message);
    end

    % Get individual events
    for i = 3:10
%        if (verbose == 1)
%            progress = progress + .2/8;
%            waitbar(progress, h, sprintf('Opening: %s\nget events', filename));
%        end

        try
            [n, ts] = plx_event_ts(filename, i);
        catch
            ts = [];
        end
        raw.events.timestamps{i-2} = ts;
    end
    
    raw.words = get_words(raw.events.timestamps);
    
    % Kludge for NEV data loaded into offline sorter
    if max(strobe_value) > 255
        raw.nev2plx = 1; % flag for later
        
        strobe_value(strobe_value < 0) = strobe_value(strobe_value < 0) + 65536;
        pos = mod(strobe_value,256) - mod(strobe_value,2);
        pos = pos + bitget(strobe_value,9);
        raw.enc = get_encoder([strobe_ts pos]);
        
        words = strobe_value - mod(strobe_value,512);
        words = words / 256 + bitget(strobe_value(:,1),1);
        tmp_words = [strobe_ts, words];
        tmp_words = tmp_words( [false; diff(words)~=0] , : );
        raw.words = tmp_words(tmp_words(:,2) ~= 0, :);         
    end
end