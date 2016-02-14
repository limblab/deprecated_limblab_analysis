function [sig samplerate words fp numberOfFps adfreq fp_start_time fp_stop_time...
            fptimes analog_time_base] = SetPredictionsInputVar(bdf)
        
        sig = bdf.vel;
        samplerate= 1000; %bdf.raw.analog.adfreq(1,1);
        
        %Sample Rate for this file
        %words = [      z];
        words=bdf.words;

        % If fp channels do not have same amount of elements, find the
        % shortest and shorten the rest to that length
        fpchans= find(cellfun(@isempty,regexp(bdf.raw.analog.channels,'[0-9]+'))==0);
        fpchanlength = zeros(1,length(fpchans));
        for j = 1:length(fpchans)
            fpchanlength(j) = size(bdf.raw.analog.data{fpchans(j)},1);
        end
        minfpchanlength = min(fpchanlength);
        for k = 1:length(fpchans)
            bdf.raw.analog.data{fpchans(k)}=bdf.raw.analog.data{fpchans(k)}(1:minfpchanlength);
        end

        % Concatenate lfp channels and put into one matrix
        fp=double(cat(2,bdf.raw.analog.data{fpchans}))';

        numberOfFps = size(fp,1);

        %Set time base for fps
        adfreq = samplerate;
        fp_start_time = 1/adfreq;
        fp_stop_time = length(fp)/adfreq;
        fptimes = fp_start_time:1/adfreq:fp_stop_time;

        %Set analog time base for other signals recorded (Pos/Vel/EMG)
        analog_time_base = sig(:,1);
end