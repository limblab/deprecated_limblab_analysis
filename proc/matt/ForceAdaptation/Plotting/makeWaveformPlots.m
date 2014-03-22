function makeWaveformPlots(data,saveFilePath)
% If data is a cell array, put all waveforms on same plot

maxWFDraw = 5000;
plotColors={'b','r','g'};
plotStyles={'-','--','-.'};

if nargin < 2
    saveFilePath = [];
end

if ~iscell(data)
    data = {data};
end

paramFile = fullfile(data{1}.meta.out_directory, [data{1}.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
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
            
            if size(temp.units(idx).wf,1) > maxWFDraw
                % randomly sample
                randInds = randi(size(temp.units(idx).wf,2),[1 maxWFDraw]);
            else
                randInds = 1:size(temp.units(idx).wf,2);
            end
            
            plot(temp.units(idx).wf(:,randInds),[plotColors{iFile} plotStyles{iFile}]);
        end
        
        set(gca,'XTick',[]);
        ylabel('mV','FontSize',fontSize);
        axis('tight');
        if ~isempty(saveFilePath)
            fn = fullfile(saveFilePath,[useArrays{iArray} '_elec' num2str(elec) 'unit' num2str(unit) '_wf.png']);
            saveas(fh,fn,'png');
        else
            pause;
        end
        
    end
end

end




% if nargin < 2
%     saveFilePath = [];
% end
%
% paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
% params = parseExpParams(paramFile);
% fontSize = str2double(params.font_size{1});
% clear params;
%
% useArrays = data.meta.arrays;
% epoch = data.meta.epoch;
%
% fh = figure;
% % get units from data, and for each, plot all of the waveforms
% for iArray = 1:length(useArrays)
%     elecs = data.(useArrays{iArray}).units;
%     for i = 1:length(elecs)
%         elec = elecs(i).id(1);
%         unit = elecs(i).id(2);
%
%         set(0, 'CurrentFigure', fh);
%         clf reset;
%
%         plot(elecs(i).wf,'b');
%         set(gca,'XTick',[]);
%         ylabel('mV','FontSize',fontSize);
%         axis('tight');
%         if ~isempty(saveFilePath)
%             fn = fullfile(saveFilePath,[useArrays{iArray} '_elec' num2str(elec) 'unit' num2str(unit) '_' epoch '_wf.png']);
%             saveas(fh,fn,'png');
%         else
%             pause;
%         end
%
%     end
% end