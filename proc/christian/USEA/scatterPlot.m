function [electrodeNumber] = scatterPlot( electrode,emgNumber,electrodeNumber )
%SCATTERPLOIT
% Plotting selectivity curves for a given electrode

if emgNumber == 7
    emgNumber = emgNumber-1;
end

%% Ensure that the PW isn't empty
if size(electrode.PW,1) == 1
    electrodeNumber=0;
    return
end

%% Exclude if none of the muscles reaches selectivity of 19%
if max(electrode.normalized(:,1:emgNumber-1))<=0.19
    electrodeNumber=0;
    return
end

%% Invisible plotting of data
for i=1:emgNumber-1
    figure(electrodeNumber)
    set(electrodeNumber, 'visible','off')
    tempData = [electrode.PW electrode.normalized(:,i)];
    tempData = sortrows(tempData);
    plot(tempData(:,1),tempData(:,2),'-o','MarkerSize',5,'MarkerEdgeColor','k');
    ylim([0 1])
    hold all
end

%% Adding legends and save as PDF.
legend('FDS','FCR','FPB','OP','FDP')
fileName = num2str(electrodeNumber);
print('-dpdf',fileName)