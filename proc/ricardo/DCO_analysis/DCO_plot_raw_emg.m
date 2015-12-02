function params = DCO_plot_raw_emg(data_struct,params)

bdf = data_struct.bdf;
DCO = data_struct.DCO;

params.fig_handles(end+1) = figure;
hold on

for iEMG = 2:size(bdf.emg.data,2)
    plot(bdf.emg.data(:,1),bdf.emg.data(:,iEMG)/(2*max(abs(bdf.emg.data(:,iEMG))))+iEMG-2);
end

plot(bdf.pos(:,1),(bdf.pos(:,2)-mean(bdf.pos(:,2)))/(2*max(abs(bdf.pos(:,2)-mean(bdf.pos(:,2)))))+iEMG-2+1);
plot(bdf.pos(:,1),(bdf.pos(:,3)-mean(bdf.pos(:,3)))/(2*max(abs(bdf.pos(:,3)-mean(bdf.pos(:,3)))))+iEMG-2+2);
plot(bdf.force(:,1),(bdf.force(:,2)-mean(bdf.pos(:,2)))/(2*max(abs(bdf.force(:,2)-mean(bdf.pos(:,2)))))+iEMG-2+3);
plot(bdf.force(:,1),(bdf.force(:,3)-mean(bdf.force(:,3)))/(2*max(abs(bdf.force(:,3)-mean(bdf.force(:,3)))))+iEMG-2+4);

set(gca,'YTick',0:7)
set(gca,'YTickLabel',strrep([bdf.emg.emgnames' {'Pos X','Pos Y','Force X','Force Y'}],'_',' '))
set(gca,'YDir','reverse')
xlabel('t (s)')

%%
params.fig_handles(end+1) = figure;
hold on
t_start = 2010;
t_end = 2019;
bmi_t_idx = find(DCO.BMI.data(:,1) >= t_start & DCO.BMI.data(:,1) <= t_end);
bdf_t_idx = find(bdf.emg.data(:,1) >= t_start & bdf.emg.data(:,1) <= t_end);
plot(bdf.emg.data(bdf_t_idx,1),800+bdf.emg.data(bdf_t_idx,1+find(strcmp(bdf.emg.emgnames,'EMG_TRI'))),'r')
plot(bdf.emg.data(bdf_t_idx,1),800+bdf.emg.data(bdf_t_idx,1+find(strcmp(bdf.emg.emgnames,'EMG_BRD'))),'b')

plot(DCO.BMI.data(bmi_t_idx-2,1),DCO.BMI.data(bmi_t_idx,find(strcmp(DCO.BMI.params.headers,'EMG_TRI'))),'r')
plot(DCO.BMI.data(bmi_t_idx-2,1),000+DCO.BMI.data(bmi_t_idx,find(strcmp(DCO.BMI.params.headers,'EMG_BRD'))),'b')

xlabel('t (s)')
legend('TRI','BRD')

