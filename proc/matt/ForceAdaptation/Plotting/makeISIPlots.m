function makeISIPlots(data,saveFilePath,removeOutliers)

if nargin < 3
    removeOutliers = true;
    if nargin < 2
        saveFilePath = [];
    end
end

paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
nBins = str2double(params.num_hist_bins{1});
fontSize = str2double(params.font_size{1});
clear params;

useArrays = data.meta.arrays;
epoch = data.meta.epoch;

fh = figure;
% get units from data, and for each, plot all of the waveforms
for iArray = 1:length(useArrays)
    elecs = data.(useArrays{iArray}).units;
    elec_names = fieldnames(elecs);
    
    for i = 1:length(elec_names)
        elec = elecs.(elec_names{i});
        unit_names = fieldnames(elec);
        for j = 1:length(unit_names)
            unit = elec.(unit_names{j});
            isi = diff(unit.ts).*1000;
            
            if removeOutliers
                out = findOutliers(isi,3);
                isi(out) = [];
            end
            
            set(0, 'CurrentFigure', fh);
            clf reset;
            
            hist(isi,nBins);
            xlabel('ISI (msec)','FontSize',fontSize);
            axis('tight');
            
            if ~isempty(saveFilePath)
                fn = fullfile(saveFilePath,[useArrays{iArray} '_' elec_names{i} unit_names{j} '_' epoch '_isi.png']);
                saveas(fh,fn,'png');
            else
                pause; %pause for viewing
            end
        end
    end
end

end

function out = findOutliers(data,factor)

datamean = mean(data);
datastd = std(data);

out = data > (datamean + factor*datastd);


end

