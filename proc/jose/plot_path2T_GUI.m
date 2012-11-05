function plot_path2T_GUI()
% See plot_path2T.m for more information
% Call GUI to load the 3 data sets.
% Update at 11-01/12 ... By Jose

%% GUI
dataPath = 'C:\Users\Jose Luis\Desktop\Spike\replicate_RealData\'; 
% Call GUI
[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Hand Control BinnedData File');
datafile = fullfile(PathName,FileName_tmp);
% Verify if the file indeed exists
if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
    % It exists.
    HCData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
    HCData = HCData.binnedData; % changin binneData name for other name
else
    % It doesn't exist.
    warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
    uiwait(warndlg(warningMessage));
end

% Call GUI
[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Cascade Control BinnedData File');
datafile = fullfile(PathName,FileName_tmp);
% Verify if the file indeed exists
if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
    % It exists.
    N2E2PData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
    N2E2PData = N2E2PData.binnedData; % changin binneData name for other name
else
    % It doesn't exist.
    warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
    uiwait(warndlg(warningMessage));
end

% Call GUI
[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose N2P Control BinnedData File');
datafile = fullfile(PathName,FileName_tmp);
% Verify if the file indeed exists
if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
    % It exists.
    N2PData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
    N2PData = N2PData.binnedData; % changin binneData name for other name
else
    % It doesn't exist.
    warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
    uiwait(warndlg(warningMessage));
end


%% Plot
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
    axis([0 10 0 5]);
    axis equal;
    title(sprintf('Time to reach each table'));
    xlabel('target'); ylabel('time (sec)');
    legend('Hand Control','Cascade Decoder', 'N2P Decoder')
end

