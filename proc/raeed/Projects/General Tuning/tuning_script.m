%% Get isometric tuning
folder='Y:\Han_13B1\Processed\experiment_20150128_iso';
clear options
options.prefix='Han_20150128';
options.only_sorted=1;
function_name='get_tuning_curves_v2';
options.labnum=6;
options.dual_array = 1;
options.array_break = 64;
options.move_corr = 'force';
options.plot_curves = true;
options.bdf = bdf;

output_data=run_data_processing(function_name,folder,options);

%% Get active/passive tunings
folder='C:\Users\rhc307\Documents\Data\Chips\experiment_20151117_actpas\';
clear options
options.prefix='Chips_20151117_COactpas';
options.only_sorted=1;
function_name='actpas_tuning';
options.labnum=6;
options.dual_array = false;
options.task = 'CO';

dbstop if error
output_data=run_data_processing(function_name,folder,options);
dbclear if error

%% Get active/passive/RW tunings
folder='C:\Users\rhc307\Documents\Data\experiment_20151117_actpas\';
clear options
options.prefix='Chips_20151117';
options.only_sorted=1;
function_name='compare_actpas_RW';
options.labnum=6;
options.dual_array = false;

output_data=run_data_processing(function_name,folder,options);

%% Get RW tuning
folder='Y:\Han_13B1\Processed\experiment_20141203_RW';
clear options
options.prefix='Han_20141203';
options.only_sorted=1;
function_name='get_tuning_curves_v2';
options.labnum=6;
options.dual_array = 1;
options.array_break = 64;
options.move_corr = 'vel';
options.plot_curves = true;
% options.bdf = bdf;

output_data=run_data_processing(function_name,folder,options);

%% plot waveforms
unit_num = 59;
num_waveforms = 100;
unit = output_data_RW.bdf.units(unit_num);
inds = randsample(length(unit.ts),num_waveforms);
figure(12345)
clf
for i=1:num_waveforms
    plot(unit.waveforms(inds(i),:),'k','linewidth',1)
    hold on
end
plot(mean(unit.waveforms),'y','linewidth',2)
box off
axis off

%% plot firing rate
unit_num = 59;
unit = output_data_RW.bdf.units(unit_num);
tstart = 0;
tstop = 50;
FR = unit.FR(1:tstop*200,2)/0.05;
figure(17831341)
plot(1:tstop*200,FR,'k-','markersize',5)

%% make make bar plot of average moddepth
frac_RW_3a = output_data_RW.frac_moddepth(output_data_RW.unit_ids(:,1)<=64);
frac_RW_2 = output_data_RW.frac_moddepth(output_data_RW.unit_ids(:,1)>64);
frac_iso_3a = output_data_iso.frac_moddepth(output_data_iso.unit_ids(:,1)<=64);
frac_iso_2 = output_data_iso.frac_moddepth(output_data_iso.unit_ids(:,1)>64);

mean_frac_RW_3a = mean(frac_RW_3a);
mean_frac_RW_2 = mean(frac_RW_2);
mean_frac_iso_3a = mean(frac_iso_3a);
mean_frac_iso_2 = mean(frac_iso_2);

figure(123423)
plot([mean_frac_RW_3a mean_frac_RW_2],'ro')
hold on
plot([mean_frac_iso_3a mean_frac_iso_2],'bo')
set(gca,'xlim',[0 3],'xtick',[1 2],'xticklabel',{'Area 3a','Area 2'},'ylim',[0 1.5])

%% show positions
pos = output_data_RW.bdf.pos(:,2:3);
plot(pos(100:10:100000,1),pos(100:10:100000,2),'r-')
hold on
plot([-15 -15],[-50 -45],'k-','linewidth',3)
box off
axis off
hold off

%% show iso trace
pos = output_data_iso.bdf.force(:,2:3);
plot(pos(100:10:100000,1),pos(100:10:100000,2),'b-')
hold on
plot([-6 -6],[-7 -5],'k-','linewidth',3)
box off
axis off
hold off