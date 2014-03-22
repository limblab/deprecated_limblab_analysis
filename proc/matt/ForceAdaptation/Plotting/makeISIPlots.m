function makeISIPlots(data,saveFilePath,removeOutliers)

plotColors={'b','r','g'};
nBins = 25; %hard code for now
doNorm = true; % normalize?

if nargin < 3
    removeOutliers = true;
    if nargin < 2
        saveFilePath = [];
    end
end

if ~iscell(data)
    data = {data};
end

paramFile = fullfile(data{1}.meta.out_directory, [data{1}.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
% nBins = str2double(params.num_hist_bins{1});
fontSize = str2double(params.font_size{1});
clear params;

useArrays = data{1}.meta.arrays;

fh = figure;
% get units from data, and for each, plot all of the waveforms
for iArray = 1:length(useArrays)
    
    allSG = cellfun(@(x) x.(useArrays{iArray}).sg,data,'UniformOutput',false);
    
    % check to make sure the unit guides are the same
    badUnits = checkUnitGuides(allSG);
    sg = setdiff(allSG{1},badUnits,'rows');
    
    for i = 1:size(sg,1)
        elec = sg(i,1);
        unit = sg(i,2);
        
        set(0, 'CurrentFigure', fh);
        clf reset;
        hold all;
        
        for iFile = 1:length(data)
            temp = data{iFile}.(useArrays{iArray});
            
            [~,idx] = intersect(temp.sg,sg(i,:),'rows');
            
            % ignore anything over a second
            isi = diff(temp.units(idx).ts);
            isi = isi(isi < 1);
            isi = isi.*1000;
            
            if removeOutliers
                out = findOutliers(isi,3);
                isi(out) = [];
            end
            
            [N,X] = hist(isi,nBins);
            
            if doNorm
                N = N./max(N);
            end
            plot(X,N,[plotColors{iFile} '-'],'LineWidth',3);
            
        end
        xlabel('ISI (msec)','FontSize',fontSize);
        axis('tight');

        if ~isempty(saveFilePath)
            fn = fullfile(saveFilePath,[useArrays{iArray} '_elec' num2str(elec) 'unit' num2str(unit) '_isi.png']);
            saveas(fh,fn,'png');
        else
            pause;
        end
        
    end
end



% fh = figure;
% % get units from data, and for each, plot all of the waveforms
% for iArray = 1:length(useArrays)
%     elecs = data.(useArrays{iArray}).units;
%     for i = 1:length(elecs)
%         elec = elecs(i).id(1);
%         unit = elecs(i).id(2);
%
%         % ignore anything over a second
%         isi = diff(elecs(i).ts);
%         isi = isi(isi < 1);
%         isi = isi.*1000;
%
%         if removeOutliers
%             out = findOutliers(isi,3);
%             isi(out) = [];
%         end
%
%         set(0, 'CurrentFigure', fh);
%         clf reset;
%
%         hist(isi,nBins);
%         xlabel('ISI (msec)','FontSize',fontSize);
%         axis('tight');
%
%         V = axis;
%         axis([0 1000 0 V(4)]);
%
%         if ~isempty(saveFilePath)
%             fn = fullfile(saveFilePath,[useArrays{iArray} '_elec' num2str(elec) 'unit' num2str(unit) '_' epoch '_isi.png']);
%             saveas(fh,fn,'png');
%         else
%             pause; %pause for viewing
%         end
%
%     end
% end

end

function out = findOutliers(data,factor)

datamean = mean(data);
datastd = std(data);

out = data > (datamean + factor*datastd);


end

