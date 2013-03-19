function plot_path2T_GUI_3(varigin)
% See plot_path2T.m for more information
% Call GUI to load the 3 data sets.
% varigin(1): save, 1 if you want to save figures in a folder
%             0 by default
% Update at 11/09/12 ... By Jose
% Upgrade: boxplot for different features

if nargin==1
    save = varigin(1);
else
    save = 0;
end

%% GUI

dataPath = ':\'; 
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


% Call GUI
[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose N2P + LPF Control BinnedData File');
datafile = fullfile(PathName,FileName_tmp);
% Verify if the file indeed exists
if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
    % It exists.
    N2PLPFData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
    N2PLPFData = N2PLPFData.binnedData; % changin binneData name for other name
else
    % It doesn't exist.
    warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
    uiwait(warndlg(warningMessage));
end



%% Plot
[t_HC x_HC y_HC] = get_path_WF(HCData);
[t_N2E2P x_N2E2P y_N2E2P] = get_path_WF(N2E2PData);
[t_N2P x_N2P y_N2P] = get_path_WF(N2PData);
[t_N2PLPF x_N2PLPF y_N2PLPF] = get_path_WF(N2PLPFData);

[st_HC length_HC] = get_length_path_WF(HCData);
[st_N2E2P length_N2E2P] = get_length_path_WF(N2E2PData);
[st_N2P length_N2P] = get_length_path_WF(N2PData);
[st_N2PLPF length_N2PLPF] = get_length_path_WF(N2PLPFData);

if all((x_HC(:,1)== x_N2E2P(:,1)) & (x_HC(:,1) == x_N2P(:,1)))
    targets = x_HC(:,1);
    for i = 1:length(targets)
    h=figure(i)
    plot(x_HC(targets(i),2:end),y_HC(targets(i),2:end),'b','LineWidth',2); hold on
    plot(x_N2E2P(targets(i),2:end),y_N2E2P(targets(i),2:end),'r','LineWidth',2)
    plot(x_N2P(targets(i),2:end),y_N2P(targets(i),2:end),'k','LineWidth',2); 
    plot(x_N2PLPF(targets(i),2:end),y_N2PLPF(targets(i),2:end),'g','LineWidth',2); 
    trials_HC = sum(t_HC(:,i)~=0);
    trials_N2E2P = sum(t_N2E2P(:,i)~=0);
    trials_N2P = sum(t_N2P(:,i)~=0);
    trials_N2PLPF = sum(t_N2PLPF(:,i)~=0);
    axis([-12 12 -12 12])
    title(sprintf('Path from center to target %i',i));
    xlabel('x (cm)'); ylabel('y (cm)');
    legend(['Hand Control: ',num2str(trials_HC),' trials'],...
        ['CD Control: ',num2str(trials_N2E2P),' trials'],...
        ['N2F Control: ',num2str(trials_N2P),' trials'],...
        ['N2F + LPF Control: ',num2str(trials_N2PLPF),' trials'],...
        'Location','Best');
    rectangle('Position',[-2,-2,4,4],'EdgeColor','cyan')
    rectangle('Position',[5,-2,4,4],'EdgeColor','magenta')
    rectangle('Position',[2.95,2.95,4,4],'EdgeColor','magenta')
    rectangle('Position',[-2,5,4,4],'EdgeColor','magenta')
    rectangle('Position',[-6.95,2.95,4,4],'EdgeColor','magenta')
    rectangle('Position',[-9,-2,4,4],'EdgeColor','magenta')
    rectangle('Position',[-6.95,-6.95,4,4],'EdgeColor','magenta')
    rectangle('Position',[-2,-9,4,4],'EdgeColor','magenta')
    rectangle('Position',[2.95,-6.95,4,4],'EdgeColor','magenta')
    axis equal;    
    if save==1
        saveas(h,['paths_target',num2str(targets(i))],'fig'); %name is a string
        saveas(h,['paths_target',num2str(targets(i))],'png'); %name is a string
    end
    end    
       
    boxplot_compareDecoders3(t_HC,t_N2E2P,t_N2P,t_N2PLPF,'Time to reach a target','seconds')
    boxplot_compareDecoders3(length_HC,length_N2E2P,length_N2P,length_N2PLPF,'Total length to reach a target','cm')
    
    figure();bar([mean(st_HC);mean(st_N2E2P);mean(st_N2P);mean(st_N2PLPF)],0.6);
    title('Successful trials per minute')
    ylabel('trials/min');
end

