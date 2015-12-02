function [dataD]=decimateData(data,filter_config)
    %kin=kinematics/kinetics in column vector, first column must be time
    DF=1/filter_config.SR;%DF= desired frequency of decimated signal
    SF=mode(diff(data(:,1)));%SF= sample frequency of data
    %upsample the signal:
    %dataD=interp1(data(:,1),data(:,2:end),t_upsamp);
    %upsample the data so that we can use simple decimation rather than
    %interpolation to downsample
    [p,q]=rat(DF/SF,.0001);
    dataD=upsample(data(:,2:end),q);%fills with zeros rather than interpolating, which is technically more correct. If q is 1 returns the original vector, if q is 2, inserts 1 zero between eacy pair of points etc.
    %lowpass filter using filter_config
    %convert our cutoff into a fraction of the upsampled frequency. SF is
    %in s, filter_config.cutoff is expcted in hz
    %butter builds a filter with a cutoff using 1/2 the specified frequency for some reason so we multiply our cutoff by 2
    cutoff=filter_config.cutoff*(SF*q)*2;
    [b, a] = butter(filter_config.poles, cutoff);%butterworth uses cutoff/(samplerate/2), or 2*cutoff/samplerate to specify cutoff
    dataD=filtfilt(b,a,dataD);
    dataD=[(data(1,1):DF:data(end,1))',dataD(1:p:end,:)];
end