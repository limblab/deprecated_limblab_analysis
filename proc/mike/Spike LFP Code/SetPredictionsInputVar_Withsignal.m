function [sig samprate words fp numberOfFps fp_start_time fp_stop_time...
    fptimes analog_times y_test] = SetPredictionsInputVar_Withsignal(bdf);

sig = bdf.vel;
samprate= bdf.raw.analog.adfreq(1,1);
binsize = .1;
bs=binsize*samprate;
wsz=256;
%Sample Rate for this file
%words = [];
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
fp_start_time = 1/samprate;
fp_stop_time = length(fp)/samprate;
fptimes = fp_start_time:1/samprate:fp_stop_time;

%Set analog time base for other signals recorded (Pos/Vel/EMG)
analog_times = sig(:,1);

y = bdf.pos(:,2:3);

if fptimes(end)~= analog_times(end,1)
    stop_time = min(analog_times(end,1),fptimes(end));
    fptimesadj = analog_times(1):1/samprate:stop_time;
    
    %          fptimes=1:samp_fact:length(fp);
    if fptimes(end)>stop_time   %If fp is longer than stop_time( need this because of
        % get_plexon_data silly way of labeling time vector)
        fpadj=interp1(fptimes,fp',fptimesadj);
        fp=fpadj';
        %         clear fpadj
        numbins=floor(length(fptimes)/bs);
    end
end

t = analog_times(1):binsize:analog_times(end);

while ((numbins-1)*bs+wsz)>length(fp)
    numbins=numbins-1;  %if wsz is much bigger than bs, may be too close to end of file
end

%Align numbins correctly
if length(t)>numbins
    t=t(1:numbins);
end
%     y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
% if size(y,2)>1
if t(1)<analog_times(1)
    t(1)=analog_times(1);   %Do this to avoid NaNs when interpolating
end
y = interp1(analog_times, y, t);    % This should work for all numbers of outputs
% as long as they are in columns of y
if size(y,1)==1
    y=y(:); %make sure it's a column vector
end

y_test = y(1:end-2,:); % remove last two bins because fft window can't calculate power on last two bins

end