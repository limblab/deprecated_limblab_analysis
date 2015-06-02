%%
% NOTE: To export the waveform data in offline sorter:
% File -> Export Per-Unit Data
%
% Select *Matlab file*
%        *All CHannels into one file*
%
% Add Channel, Unit Number, and Number of Waveforms to the right-hand column
% Select *Also Append Template Std Dev Data*

%%
% add a cell to variable 'session' for each day you want to track over. You
% can do this manually since it will probably only be a few days. Or use
% this loop, which prompts for variables.
num_inds = input('Enter number of days you wish to match: '); 

session = cell(num_inds,1);
for ind = 1:num_inds

    clc;
    bdfM = input(sprintf('Variable name for day %d ''bdf'': ',ind)); clc;
    Wave_data = input(sprintf('Path to waveform data for day %d: ',ind),'s'); clc;
    
    R_units = spiketrains(bdfM,1);

    % Add waveform info for PMd
    WAVES = load(Wave_data);
    Wcell = struct2cell(WAVES);
    unitinds = vertcat(bdfM.units.id);

    bdfM_locs = find(unitinds(:,2) ~= 0 & unitinds(:,2) ~= 255);

    for i = 1:length(Wcell)

        mean_wave = Wcell{i}(4:51);
        std_wave = Wcell{i}(52:end);

        % Check the channel/unit
        chan_unit = Wcell{i}(1:2);  
        if chan_unit == bdfM.units(bdfM_locs(i,:)).id    
            bdfM.units(bdfM_locs(i,:)).wave = [mean_wave; std_wave];  
        else
            warning('SOMETHING IS WRONG!!');
        end
    end

    session{ind}.bdf = bdfM;
    session{ind}.units = R_units;

end

%% Do comparisons
COMPS = KS_p(session,0.0025);  % 'COMPS' might be a bit confusing. Just ask...
