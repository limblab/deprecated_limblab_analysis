function peak2peak = STA_cmd(datastructname, command)

    out_struct = LoadDataStruct(datastructname,'bdf');
    
    if isempty(out_struct)
       disp(sprintf('Could not load structure %s',datastructname));
       peak2peak=[];
       return
    end
    
    numEMGs = size(out_struct.emg.emgnames, 2);
    %[TimeBefore, TimeAfter] = PWTH_GUI;
    TimeBefore = 0.01; %10ms
    TimeAfter  = 0.03; %20ms
    peakWindow_low = 0.004; %4ms
    peakWindow_high= 0.02; %12ms
    emgFreq = out_struct.emg.emgfreq;

    %which stimulator channels were active?
    % ( out_struct.stim : [ts cmd chan freq I PW NP] )
    active_stim_ch = unique(out_struct.stim(:,3));
    num_stim_ch = length(active_stim_ch);
    peak2peak = zeros(num_stim_ch,numEMGs);

    %extract file name from meta
    beg_fn = find(out_struct.meta.filename=='\',1,'last');
    if beg_fn
        filename = out_struct.meta.filename(beg_fn:end);
    else
        filename = 'datafile';
    end

    if ~isempty(active_stim_ch);

        %allocate EMG data array
        %EMGdata = zeros(round((TimeBefore+TimeAfter)*out_struct.emg.emgfreq)+1, numEMGs+1, num_stim_ch );

        if command == 'update'
            command = 14;
        elseif command == 'start'
            command = 12;
        end

        % extract stim info:
        stim_ts = out_struct.stim( out_struct.stim(:,2) ==command, 1);

        %Calculate STA
        EMGdata = STA(stim_ts,out_struct.emg.data,TimeBefore,TimeAfter);

        %Calculate peak to peak values for each muscle 4 to 15 ms after stim
        peak2peak = max(EMGdata(round((peakWindow_low+TimeBefore)*emgFreq):round((peakWindow_high+TimeBefore)*emgFreq),2:numEMGs+1))...
                        -min(EMGdata(round((peakWindow_low+TimeBefore)*emgFreq):round((peakWindow_high+TimeBefore)*emgFreq),2:numEMGs+1));

        %plot the STA
        h=figure;
    %    set(h,'Name',sprintf('Stim ch %d, %dus, %.2fmA, %dpulses',active_stim_ch(i),PW,I,NP) );
        set(h,'Name',filename);
        ax=zeros(1,numEMGs);
        t=zeros(1,numEMGs);
        YLim_Max = zeros(1,2);

        for e = 1:numEMGs
            subplot(4,3,e),plot(EMGdata(:,1), EMGdata(:,e+1));
            ax(e)=gca;
            set(ax(e),'FontSize',[8]);
            YLim_tmp = get(ax(e),'YLim');
            YLim_Max = [min(YLim_Max(1),YLim_tmp(1)) max(YLim_Max(2),YLim_tmp(2))];
            t(e)= text('String',sprintf('%s : %.0f mV',strrep(out_struct.emg.emgnames{1,e},'EMG_',''),peak2peak(e)));
        end
        for e = 1:numEMGs
            set(ax(e),'YLim',YLim_Max);
            set(ax(e),'XLim',[-TimeBefore TimeAfter]);
            set(t(e),'Position',[0 YLim_Max(2)*0.8],'fontsize',8);
        end

    else
        disp('no stim information was found in this file');
    end
end


