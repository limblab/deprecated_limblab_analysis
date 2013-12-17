function [y, fp, t] = fpadjust(binsize, samprate, fptimes, wsz, y, fp, analog_times)

disp('fp adjust')

bs=binsize*samprate;    %This assumes binsize is in seconds.
numbins=floor(length(fptimes)/bs);   %Number of bins total
binsamprate=floor(1/binsize);   %sample rate due to binning (for MIMO input)
if ~exist('wsz','var')
    wsz=256;    %FFT window size
end

%MRS modified 12/13/11
% Using binsize ms bins
if length(fp)~=length(y)
    stop_time = min(length(y),length(fp))/samprate;
    if stop_time < 50 % BC case.
        stop_time = min(length(y),length(fp))/binsamprate;
    end
    fptimesadj = analog_times(1):1/samprate:stop_time;
    %          fptimes=1:samp_fact:length(fp);
    if fptimes(end)>stop_time   %If fp is longer than stop_time( need this because of get_plexon_data silly way of labeling time vector)
        fpadj=interp1(fptimes,fp',fptimesadj);
        fp=fpadj';
        clear fpadj
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
y = interp1(analog_times, y, t);    %This should work for all numbers of outputs as long as they are in columns of y
if size(y,1)==1
    y=y(:); %make sure it's a column vector
end