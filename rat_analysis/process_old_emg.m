%load('EMGdata.mat'); %uncomment for the first time running this code in a session
data = rawCycleData; 
gmax = data{1}(:,1); 
%data{step number}(rows, muscle)

plot(abs(gmax))

hold on

[b, c] = butter(2,.1,'high');
highfilt = abs(filtfilt(b, c, gmax));
%plot(highfilt)

[d, e] = butter(2, .3, 'low'); 
lowfilt = abs(filtfilt(d, e, gmax)); 
plot(lowfilt)

hold off
