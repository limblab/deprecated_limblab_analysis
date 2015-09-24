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
    
    %note: length(base_chan_num) is not always the same as num_channels. When
    %channels are left out of the .plx recording, the loading utilities get
    %fucked up, and you can have channels that appear in chan_list, that do
    %not appear in offline_sorter. Further, neither the list of channels in
    %offline sorter, nor chan_list has to correspond to the number of
    %columns in tscounts. calling plx_waves with the missing channel as input
    %will still try to extract data from the missing channel, crashing
    %plx_waves. to deal with this asshattery as best we can, we will
    %extract a list of reported channels. We will loop through the channel 
    %list trying to extract time samples and waves for each. If the data load 
    %crashes we will then skip that index. We will use the reported channel 
    %name as the basis to assign channel numbers, as this ~APPEARS~ to be 
    %correct
    [n, chan_list] = plx_chan_names(filename);
    base_chan_num=str2num(chan_list(:,4:end));
    temp=strfind(chan_list(:,1)','B');
    bank2_start=temp(1);
    temp=strfind(chan_list(:,1)','C');
    bank3_start=temp(1);
    chan_num=base_chan_num'+32*([1:n]>=bank2_start)+32*([1:n]>=bank3_start);
    
    max_num_units=find(sum(tscounts,2),1,'Last');
    %
    % Get Units 
    %
%     num_total_units = sum(sum(tscounts > 0));
%     ids         = cell(1, num_total_units);
%     tss         = cell(1, num_total_units);
%     waveforms   = cell(1, num_total_units);
     unit_counter = 1;
%     skipped_chans
    for chan = 1:length(chan_num)
        %if (verbose == 1)
        %    progress = progress + .3/num_channels;
        %    waitbar(progress, h, sprintf('Opening: %s\nget units (%d)', filename, chan));
        %end
        if opts.verbose
            disp(sprintf('Spike channel: %d', chan_num(chan)));
        end
        for unit = 0:max_num_units
            % only create a unit if it has spikes
                %[n, ts] = plx_ts(filename, chan, unit);
            try
                [~, ~, ts, wave]=plx_waves(filename, chan_num(chan), unit);
                ids{unit_counter} = [chan unit];
                tss{unit_counter} = ts;
                waveforms{unit_counter}=wave;
                unit_counter = unit_counter + 1;
            catch temperr
                %if we tried to load a channel/unit combo that does not
                %have any data in it we need to skip that 
                %skipped_chans=skipped_chans+1;
                
                %warning disabled because it gets thrown for every empty
                %cell in tscounts and I haven't figured out a clever way to
                %skip 
%                 warning('get_units_plx:FileWonky','the file is reporting a channel has data when it does not')
%                 disp(['channel: ',num2str(chan_num(chan)), ' (',chan_list(chan,:),'), appears in the list of channels, but contains no data'])
            end
        end
    end

    units = struct('id', ids, 'ts', tss,'waveforms',waveforms); 
end

