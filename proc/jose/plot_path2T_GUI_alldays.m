function plot_path2T_GUI_alldays(varigin)
% See plot_path2T.m for more information
% Call GUI to load the 3 data sets.
% varigin(1): save, 1 if you want to save figures in a folder
%             0 by default
% Update at 11/09/12 ... By Jose

if nargin==1
    save_fig = varigin(1);
else
    save_fig = 0;
end

%% GUI

dataPath = 'C:\Users\Jose Luis\Desktop\Spike\replicate_RealData\CascadevsN2P\'; 
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
[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose N2P Low Pass Filter Control BinnedData File');
datafile = fullfile(PathName,FileName_tmp);
% Verify if the file indeed exists
if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
    % It exists.
    N2PLPData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
    N2PLPData = N2PLPData.binnedData; % changin binneData name for other name
else
    % It doesn't exist.
    warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
    uiwait(warndlg(warningMessage));
end

% Call GUI
[FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose N2V Control BinnedData File');
datafile = fullfile(PathName,FileName_tmp);
% Verify if the file indeed exists
if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
    % It exists.
    N2VData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
    N2VData = N2VData.binnedData; % changin binneData name for other name
else
    % It doesn't exist.
    warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
    uiwait(warndlg(warningMessage));
end

%% Plot
[t_HC x_HC y_HC] = get_path_WF(HCData);
[t_N2E2P x_N2E2P y_N2E2P] = get_path_WF(N2E2PData);
[t_N2P x_N2P y_N2P] = get_path_WF(N2PData);
[t_N2PLP x_N2PLP y_N2PLP] = get_path_WF(N2PLPData);
[t_N2V x_N2V y_N2V] = get_path_WF(N2VData);

length_HC = get_length_path_WF(HCData);
length_N2E2P = get_length_path_WF(N2E2PData);
length_N2P = get_length_path_WF(N2PData);
length_N2PLP = get_length_path_WF(N2PLPData);
length_N2V = get_length_path_WF(N2VData);

if all((x_HC(:,1)== x_N2E2P(:,1)) & (x_HC(:,1) == x_N2P(:,1)))
    targets = x_HC(:,1);
    for i = 1:length(targets)
    h=figure(i);
    plot(x_HC(targets(i),2:end),y_HC(targets(i),2:end),'b','LineWidth',2); hold on
    plot(x_N2E2P(targets(i),2:end),y_N2E2P(targets(i),2:end),'r','LineWidth',2)
    plot(x_N2P(targets(i),2:end),y_N2P(targets(i),2:end),'k','LineWidth',2); 
    plot(x_N2PLP(targets(i),2:end),y_N2PLP(targets(i),2:end),'m','LineWidth',2); 
    plot(x_N2V(targets(i),2:end),y_N2V(targets(i),2:end),'g','LineWidth',2); 
    trials_HC = sum(t_HC(:,i)~=0);
    trials_N2E2P = sum(t_N2E2P(:,i)~=0);
    trials_N2P = sum(t_N2P(:,i)~=0);
    trials_N2PLP = sum(t_N2PLP(:,i)~=0);
    trials_N2V = sum(t_N2V(:,i)~=0);        
    axis([-12 12 -12 12])
    title(sprintf('Path from center to target %i',i));
    xlabel('x (cm)'); ylabel('y (cm)');
    legend(['Hand Control: ',num2str(trials_HC),' trials'],...
        ['N2E2F Control: ',num2str(trials_N2E2P),' trials'],...
        ['N2F Control: ',num2str(trials_N2P),' trials'],...
        ['N2FLP Control: ',num2str(trials_N2PLP),' trials'],...
        ['N2V Control: ',num2str(trials_N2V),' trials'],'Location','Best');
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
    if save_fig==1
        saveas(h,['paths_target',num2str(targets(i))],'fig'); %name is a string
    end
    end    
       
    boxplot_compareDecoders(t_HC,t_N2E2P,t_N2P,'Time to reach a target','time(sec)')
    boxplot_compareDecoders2(t_HC,t_N2PLP,t_N2V,'Time to reach a target','time(sec)')    
    boxplot_compareDecoders(length_HC,length_N2E2P,length_N2P,'Total length to reach a target','length(cm)')
    boxplot_compareDecoders2 (length_HC,length_N2PLP,length_N2V,'Total length to reach a target','length(cm)')
end

