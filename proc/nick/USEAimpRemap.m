% function USEAimpRemap(datafile,mapfile)
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_02_26_13\Sarah_impedance_poststim_2_26_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_03_6_13\Sarah_impedance_poststim_3_06_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_03_6_13\Sarah_impedance_poststim2_3_06_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_03_13_13\Sarah_impedance_poststim_3_13_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_03_21_13\Sarah_impedance_prestim_3_21_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_03_27_13\Sarah_impedance_prestim_3_27_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_03_27_13\Sarah_impedance_poststim_3_27_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_04_03_13\Sarah_impedance_prestim_4_3_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_04_10_13\Sarah_impedance_prestim_4_10_13';
datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_05_09_13\Sarah_impedance_prestim_5_9_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_05_23_13\Sarah_impedance_prestim_5_23_13';
% datafile = '\\165.124.111.182\data\Sarah_1I3\USEA Data\ExperimentFolder_Sarah_05_30_13\Sarah_impedance_prestim_5_30_13_map';
mapfile = '\\165.124.111.182\limblab\lab_folder\Animal-Miscellany\Sarah 1I3\TDT1ReversedArray_ArrayMap.cmp';

data = importdata(datafile);
strchannels = data.textdata(10:end,1);
strvalues = data.textdata(10:end,2);
for x = 1:length(strchannels)
    if strncmp(strchannels{x,1},'chan',4)
        numchannels(x,1) = str2double(strchannels{x,1}(5:end));
    else
        numchannels(x,1) = str2double(strchannels{x,1}(7:end));
    end
    numvalues(x,1) = str2double(strvalues{x,1});
end

% for x = 1:2:95
%     temp1 = numvalues(numchannels == x);
%     temp2 = numvalues(numchannels == x + 1);
%     
%     numvalues(numchannels == x) = temp2;
%     numvalues(numchannels == x + 1) = temp1;
% end

map = importdata(mapfile);
strmap = map(23:end,1);
for x = 1:length(strmap)
    mapcol(x,1) = str2double(strmap{x,1}(1,1));
    maprow(x,1) = str2double(strmap{x,1}(1,3));
    mapbank(x,1) = strmap{x,1}(1,5);
    mapbankchan(x,1) = str2double(strmap{x,1}(1,7:8));
    mapelec(x,1) = str2double(strmap{x,1}(1,11:13));
    mapchan(x,1) = str2double(strmap{x,1}(1,16:17));
end

impmap = zeros(10,10);
for x = 1:10
    for y = 1:10
        if sum(maprow == x-1 & mapcol == y-1)
            impmap(x,y) = numvalues(numchannels == mapchan(maprow == x-1 & mapcol == y-1));
        end
    end
end

figure;
surf([-impmap zeros(10,1); zeros(1,11)]);
for x = 1:10
    for y = 1:10
        if(impmap(y,x) == 0)
            text(x+0.5,y+0.5,'REF','HorizontalAlignment','center')
        elseif(impmap(y,x) > 500)
            text(x+0.5,y+0.5,['\color{white}' num2str(impmap(y,x))],'HorizontalAlignment','center')
        else
            text(x+0.5,y+0.5,num2str(impmap(y,x)),'HorizontalAlignment','center')
        end
    end
end
view(0,90)
set(gca,'XTick',1.5:1:10.5)
set(gca,'YTick',1.5:1:10.5)
set(gca,'XTickLabel',[' 1';' 2';' 3';' 4';' 5';' 6';' 7';' 8';' 9';'10'])
set(gca,'YTickLabel',[' 0';'10';'20';'30';'40';'50';'60';'70';'80';'90'])
ylabel('long electrodes / wires')
% title('corrected electrode impedances for 2/26/13, viewed from pad side')
% title('corrected electrode impedances for 3/6/13, viewed from pad side')
% title('corrected electrode impedances for 3/6/13 (2), viewed from pad side')
% title('corrected electrode impedances for 3/13/13, viewed from pad side')
% title('corrected electrode impedances for 3/21/13, viewed from pad side')
% title('corrected electrode impedances for 3/27/13, viewed from pad side')
% title('corrected electrode impedances for 3/27/13 (2), viewed from pad side')
% title('corrected electrode impedances for 4/3/13, viewed from pad side')
% title('corrected electrode impedances for 4/10/13, viewed from pad side')
title('corrected electrode impedances for 5/9/13, viewed from pad side')
% title('corrected electrode impedances for 5/23/13, viewed from pad side')
% title('corrected electrode impedances for 5/30/13, viewed from pad side')
caxis([-1000 0])
colormap('Gray')
