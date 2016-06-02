function plot_path2T(data1,data2,data3)

% plot average path (center to each target) for 3 different data set
% data1 : hand control data set
% data2 : Cascade control data set
% data3 : Neuron to position control data set
%
% All 3 data sets should have the same number of targets, and should
% correspond to the same task, in this case WF task.
% Update at 11-01/12 ... By Jose

HCData = data1;
N2E2PData = data2;
N2PData = data3;


[t_HC x_HC y_HC] = get_path_WF(HCData);
[t_N2E2P x_N2E2P y_N2E2P] = get_path_WF(N2E2PData);
[t_N2P x_N2P y_N2P] = get_path_WF(N2PData);

if all((x_HC(:,1)== x_N2E2P(:,1)) & (x_HC(:,1) == x_N2P(:,1)))
    targets = x_HC(:,1);
    for i = 1:length(targets)
    figure(i)
    plot(x_HC(targets(i),2:end),y_HC(targets(i),2:end),'b'); hold on
    plot(x_N2E2P(targets(i),2:end),y_N2E2P(targets(i),2:end),'r')
    plot(x_N2P(targets(i),2:end),y_N2P(targets(i),2:end),'k'); 
    axis([-12 12 -12 12])
    title(sprintf('Path from center to target %i',i));
    xlabel('x (cm)'); ylabel('y (cm)');
    legend('Hand Control','Cascade Decoder', 'N2P Decoder')
    rectangle('Position',[-2,-2,4,4],'EdgeColor','cyan')
    rectangle('Position',[5,-2,4,4],'EdgeColor','magenta')
    rectangle('Position',[2.95,2.95,4,4],'EdgeColor','magenta')
    rectangle('Position',[-2,5,4,4],'EdgeColor','magenta')
    rectangle('Position',[-6.95,2.95,4,4],'EdgeColor','magenta')
    rectangle('Position',[-9,-2,4,4],'EdgeColor','magenta')
    rectangle('Position',[-6.95,-6.95,4,4],'EdgeColor','magenta')
    rectangle('Position',[-2,-9,4,4],'EdgeColor','magenta')
    rectangle('Position',[2.95,-6.95,4,4],'EdgeColor','magenta')
    end
    figure(9)
    plot(t_HC(:,1),t_HC(:,2),'b*'); hold on
    plot(t_N2E2P(:,1),t_N2E2P(:,2),'r*')
    plot(t_N2P(:,1),t_N2P(:,2),'g*'); 
    axis([0 10 0 5])
    title(sprintf('Time to reach each table'));
    xlabel('target'); ylabel('time (sec)');
    legend('Hand Control','Cascade Decoder', 'N2P Decoder')
end

