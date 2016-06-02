function peak2peak = Analog_Trig_STA(datastructname)
    
    out_struct = LoadDataStruct(datastructname,'bdf');
    
    if isempty(out_struct)
       disp(sprintf('Could not load structure %s',datastructname));
       peak2peak=[];
       return
    end
    numEMGs = size(out_struct.emg.emgnames, 2);
    %[TimeBefore, TimeAfter] = PWTH_GUI;
    TimeBefore = 0.01; %10ms
    TimeAfter  = 0.03; %30ms
    peakWindow_low = 0.004; %4ms
    peakWindow_high= 0.012; %12ms
    emgFreq = out_struct.emg.emgfreq;
    active_stim_ch = [];


    if ~isempty(out_struct.stim_marker)

        %allocate EMG data array
        EMGdata = zeros(round((TimeBefore+TimeAfter)*out_struct.emg.emgfreq)+1, numEMGs+1);
        peak2peak = zeros(1,numEMGs);

        %Calculate STA
        EMGdata = STA(out_struct.stim_marker,out_struct.emg.data,TimeBefore,TimeAfter);

        %Calculate peak to peak values for each muscle 4 to 15 ms after stim
        peak2peak = max(EMGdata(round((peakWindow_low+TimeBefore)*emgFreq):round((peakWindow_high+TimeBefore)*emgFreq),2:numEMGs+1))...
                        -min(EMGdata(round((peakWindow_low+TimeBefore)*emgFreq):round((peakWindow_high+TimeBefore)*emgFreq),2:numEMGs+1));

        %plot the STA
        figure;
        ax=zeros(1,numEMGs);
        t=zeros(1,numEMGs);
        YLim_Max = zeros(1,2);

        for e = 1:numEMGs
            subplot(4,3,e),plot(EMGdata(:,1), EMGdata(:,e+1));
            ax(e)=gca;
            %set(ax(e),'FontSize',[8]);
            YLim_tmp = get(ax(e),'YLim');
            YLim_Max = [min(YLim_Max(1),YLim_tmp(1)) max(YLim_Max(2),YLim_tmp(2))];
            t(e)= text('String',sprintf('%s : %.0f mV',strrep(out_struct.emg.emgnames{1,e},'EMG_',''),peak2peak(e)));
        end

        %set common Y axis limit and display p2p values for every EMG channels
        for e = 1:numEMGs
            set(ax(e),'YLim',YLim_Max);
            set(ax(e),'XLim',[-TimeBefore TimeAfter]);
            set(t(e),'Position',[0 YLim_Max(2)*0.8],'fontsize',8);
        end
    end

end
