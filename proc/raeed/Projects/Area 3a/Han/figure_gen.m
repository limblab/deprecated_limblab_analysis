%% initialize (dataset date: 5/30/2014, Kramer)
bdf = get_nev_mat_data('Y:\Han_13B1\Processed\Sorted\Han_20141203_raeed_tucker_3aB1B2_2A2B1_001-s.nev',6);
tt=rw_trial_table(bdf);
channel_num = 22;
unit_num = 1;

%% calculate PD
[pds,errs,moddepth] = glm_pds(bdf);
ul = unit_list(bdf);
for i=1:length(ul)
    b(:,i)=glm_kin(bdf,ul(i,1),ul(i,2));
    dir=atan2(b(5),b(4));
end

%% plot firing rate and speed
ts = get_unit(bdf,channel_num,unit_num);
ti = 1:0.01:ts(end);
rates = calcFR(ti,ts,0.2,'gaussian');
vel = interp1(bdf.vel(:,1),bdf.vel(:,2:3),ti);
speed = sqrt(vel(:,1).^2+vel(:,2).^2);

target_go = tt(:,8);
target_reached = tt(:,9);
target_go = target_go(:);
target_reached = target_reached(:);

xwindow = [137.5 142];
ywindow = [0 60];

%rezero everything around window
ti=ti-xwindow(1);
target_go = target_go-xwindow(1);
target_reached = target_reached-xwindow(1);

%Plot
figure
plot(ti,speed,'-r','linewidth',2)
hold on
plot(ti,rates,'-b','linewidth',2)
for i=1:length(target_go)
    plot([target_go(i) target_go(i)],[0 80],'--g','linewidth',5)
    plot([target_reached(i) target_reached(i)],[0 80],'--k','linewidth',5)
end
axis([xwindow-xwindow(1) ywindow])
legend('Speed of hand movement','Neural Firing Rate','Target Presented','Target Reached')
title 'Modulation of Neuron on Area 3a, Bank B2, Channel 22'
xlabel 'Time (s)'
ylabel 'Hand Speed (cm/s)/Firing Rate (Hz)'


%% plot firing rate against directed velocity
dir_vel = vel*dir;
figure
plot(ti,dir_vel,'-r',ti,rates,'-b')
% axis([0 4.9 0 80])

%% Plot PDs
figure
moddepth_rel = moddepth/max(moddepth);
polar(0,-1)
hold on
for iPD=1:19
    h1=polar([pds(iPD) pds(iPD)],[0 moddepth_rel(iPD)]);
    h2=polar(pds(iPD),moddepth_rel(iPD),'o');
    set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
            '-or','String','150','-or','String','210','-or','String','240',...
            '-or','String','300','-or','String','330','-or','String','  0.2',...
            '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
            '-or','String','  0.1','-or','String','  1') ,'String', ' ');
    set(h1,'linewidth',2.5);
    set(h2,'linewidth',2.5);
end
