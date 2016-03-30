function ijlv_test01
%filename=get_filename_reading;
[filename,path] = uigetfile;
load(strcat(path,filename));
data=out_struct.data;
% 6='Fx','Fy','Fz','Mx','My','Mz'
sfreq=out_struct.sample_rate;
d=size(data);
T=[1:d(1)]';
T=T/sfreq;
%plot(T,data(:,6));
plot_3waves_quick(T, data(:,6), data(:,7), data(:,8), 'T', 'Fx', 'Fy', 'Fz', 1);
plot_3waves_quick(T, data(:,9), data(:,10), data(:,11), 'T','Mx', 'My', 'Mz', 2);
