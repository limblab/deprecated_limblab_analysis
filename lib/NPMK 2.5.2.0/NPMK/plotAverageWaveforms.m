% plotAverageWaveforms
%
% Plots average waveforms for all channels and specified units across the
% array. It will prompt for a CMP file to map each channel to its electrode
% representation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Use plotAverageWaveforms(NEV, units)
% 
% NOTE: All input arguments are optional. Input arguments may be in any order.
%
%   NEV:          NEV structure containing all waveforms.
%                 DEFAULT: Will prompt for NEV.
%
%   'units':      Specify the units to plot (i.e. 2 or 0:5 for all).
%                 DEFAULT: will plot all units.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   USAGE EXAMPLE: 
%   
%   openNEV(NEV, 0:3);
%
%   In the example above, the waveforms in the NEV structure coming from
%   units 0 through 3 will be plotted.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Kian Torab
%   kian@blackrockmicro.com
%   Blackrock Microsystems
%   Salt Lake City, UT
%   
%   Version 2.0.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotAverageWaveforms(NEV, units)

mapfile = 1;
colors = {'magenta', 'cyan', 'red', 'green', 'blue', 'black'};

if ~exist('NEV', 'var')
    NEV = openNEV('read');
end

if ~exist('units', 'var')
    units = 0:5;
end

numberOfElectrodes = length(unique(NEV.Data.Spikes.Electrode));

disp('Select a map file for your array. If none, press cancel or ESC.');
mapFile = KTUEAMapFile;
if ~mapFile.isValid
    disp('Map File was not selected.');
    mapfile = 0;
    plotHeight = floor(sqrt(numberOfElectrodes));
    plotWidth = ceil(numberOfElectrodes/floor(sqrt(numberOfElectrodes)));
end

figure = KTFigure;

figure.EnlargeFigure;
figure.MakeBackgroundWhite;
figure.SetActive;
title('Spikes Average Waveforms for Individual Channels');

for chanIDX = 1:numberOfElectrodes
    
    if mapfile
        mapFile.GenerateChannelSubplot(chanIDX);
    else
        subplot(plotHeight, plotWidth, chanIDX);
    end
    
    hold on;
    for unitIDX = units
        [~, allWaveforms] = findEventTimes(NEV, chanIDX, unitIDX);
        if ~isempty(allWaveforms)
            averageWaveform = mean(allWaveforms, 2);
            plot(averageWaveform, 'color', colors{unitIDX+1}, 'LineWidth',2);
        end
    end
    hold off;
    
    ylim([-1000, 1000]);
%     if size(allWaveforms,2) ~= 0
%         text(1, 0, num2str(size(allWaveforms,2)), 'color', 'red');
%     end
    mapFile.setAxisBackgroundColor('white');
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
end