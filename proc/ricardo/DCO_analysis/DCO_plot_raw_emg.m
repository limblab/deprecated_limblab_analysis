function params = DCO_plot_raw_emg(data_struct,params)

bdf = data_struct.bdf;

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
set(gca,'YTickLabel',{'Bi','Tri','AD','PD','Pos X','Pos Y','Force X','Force Y'})
set(gca,'YDir','reverse')
xlabel('t (s)')