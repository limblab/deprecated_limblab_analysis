%%
% Replace all of the ---REPLACE--- dummies with the corresponding variables
% or strings. You can take out the loop and manually run it to add the cell
% to 'session' (for each day)

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
% can do this manually since it will probably only be a few days. Or do a
% sophisticated loop
for ind = ALL_DAYS_YOU_WANT_TO_MATCH 

    bdfPMd = ---REPLACE---;  % Put bdf created from PMd recording
    bdfM1 = ---REPLACE---; % Put bdf created from M1 recording
    Wave_dataP = '---REPLACE---'; % Put file path to PMd waveform data
    Wave_dataM = '---REPLACE---'; % Put file path to M1 waveform data

    PMd_units = spiketrains(bdfPMd,1);
    M1_units = spiketrains(bdfM1,1);

    % Add waveform info for PMd
    WAVESP = load(WAVE_dataP);
    WcellP = struct2cell(WAVESP);
    bdfunitinds = vertcat(bdfPMd.units.id);

    bdf_locs = find(bdfunitinds(:,2) ~= 0 & bdfunitinds(:,2) ~= 255);

    for i = 1:length(WcellP)

        mean_wave = WcellP{i}(4:51);
        std_wave = WcellP{i}(52:end);

        % Check the channel/unit
        chan_unit = WcellP{i}(1:2);  
        if chan_unit == bdfPMd.units(bdf_locs(i,:)).id    
            bdfPMd.units(bdf_locs(i,:)).wave = [mean_wave; std_wave];  
        else
            warning('SOMETHING IS WRONG!!');
        end
    end

    % Add waveform info for M1
    WAVESM = load(WAVE_dataM);
    WcellM = struct2cell(WAVESM);
    bdfunitinds = vertcat(bdfM1.units.id);

    bdf_locs = find(bdfunitinds(:,2) ~= 0 & bdfunitinds(:,2) ~= 255);

    for i = 1:length(WcellM)

        mean_wave = WcellM{i}(4:51);
        std_wave = WcellM{i}(52:end);

        % Check the channel/unit
        chan_unit = WcellM{i}(1:2);  
        if chan_unit == bdfM1.units(bdf_locs(i,:)).id    
            bdfM1.units(bdf_locs(i,:)).wave = [mean_wave; std_wave];  
        else
            warning('SOMETHING IS WRONG!!');
        end
    end

    session{ind}.bdfM1 = bdfM1;
    session{ind}.bdfPMd = bdfPMd;
    session{ind}.PMd_units = PMd_units;
    session{ind}.M1_units = M1_units;

end

%% Do comparisons
COMPS = KS_p(session,0.0025);  % 'COMPS' might be a bit confusing. Just ask...


