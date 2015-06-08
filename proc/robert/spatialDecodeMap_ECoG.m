function spatialDecodeMap_ECoG(VAFstruct,gridDims,gridBaseIndex,scaleColor)

% syntax spatialDecodeMap_ECoG(VAFstruct,gridDims,gridBaseIndex,scaleColor);
% 
%   INPUTS
%           VAFstruct           - the structure containing the VAFs from a
%                                 parameter sweep.  Also contains
%                                 meta-data.
%           gridDims            - [rows X columns], the size of the grid.
%                                 can leave this empty; the function
%                                 will guess as to the grid dimensions.
%           girdBaseIndex       - what should the first index of the grid
%                                 indexing be in the montage (if it is, or
%                                 were present)?  e.g. values are 1, 17,
%                                 33, or 49 for PMT grids.  This should
%                                 always be 1 for an Integra grid, unless
%                                 its VAFstruct from a sweep is included
%                                 with sweep data from another array, for
%                                 some reason.
%           scaleColor          - (0 or 1) whether to scale the color
%                                 intensities to [0, 1] limits (if so, pick
%                                 0 for this flag) or the min and max of
%                                 the data (to do this, pick scaleColor=1).

switch nargin
    case 0
        help spatialDecodeMap_ECoG
        return
    case 1
        gridDims=[];
        gridBaseIndex=1;
        scaleColor=0;
    case 2
        gridBaseIndex=1;
        scaleColor=0;
    case 3
        scaleColor=0;
end
if isempty(gridBaseIndex), gridBaseIndex=1; end

infoStruct=ECoGprojectAllFileInfo;
infoStructInd=cellfun(@isempty,regexp({infoStruct.path},VAFstruct(1).name))==0;
electrodesUsed=VAFstruct(1).electrodeType;
defaultElectrodeTypes={'MS','ME','S','EP'};
montageAll=infoStruct(infoStructInd).montage{strcmp(electrodesUsed, ...
    defaultElectrodeTypes)};
% gridIndices will always be 1-based.
gridIndices=montageAll-(gridBaseIndex-1);

figure
set(gcf,'Units','normalized','Position',[0.2285 0.0625 0.7432 0.8451])
if ~isempty(gridDims)
    gridPlotData=nan(gridDims(1),gridDims(2),size(VAFstruct(1).vaf,2));
else
    gridPlotData=nan(sqrt(2^nextpow2(numel(montageAll))), ...
        sqrt(2^nextpow2(numel(montageAll))),size(VAFstruct(1).vaf,2));
end
for k=1:size(VAFstruct(1).vaf,2)
    for n=1:numel(montageAll)
        VAFstructSub=VAFstruct(cat(1,VAFstruct.montage)==montageAll(n));
        [~,ind]=max(cellfun(@(x,p) mean(x(1:10,p)),{VAFstructSub.vaf}, ...
            num2cell(repmat(k,1,numel(VAFstructSub)))));
        [r,c]=ind2sub([size(gridPlotData,1),size(gridPlotData,2)],gridIndices(n));
        gridPlotData(r,c,k)=mean(VAFstructSub(ind).vaf(1:10,k));
    end
    if size(VAFstruct(1).vaf,2) > 1
        if k==1
            axH=gridPlotSetup(gcf,size(VAFstruct(1).vaf,2));
        end
    else
        axH=gca;
    end
    set(gcf,'CurrentAxes',axH(k))
    imagesc(squeeze(gridPlotData(:,:,k)))
    colorbar
    set(gca,'XTickLabel',{},'YTickLabel',{})
    if ~scaleColor, caxis([0 1]), end
    set(gca,'TickLength',[0 0])
    for n=1:size(gridPlotData,1)
        if gridPlotData(size(gridPlotData,2),n,k) < 0.35
            textColor=[1 1 1];
        else
            textColor=[0 0 0];
        end
        text(n,size(gridPlotData,2),num2str(n), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'Color',textColor,'Tag','numLabel')
    end
    for n=1:(size(gridPlotData,1)-1) % better to use actual RGB value
        if gridPlotData(n,size(gridPlotData,1),k) < 0.35
            textColor=[1 1 1];
        else
            textColor=[0 0 0];
        end
        text(size(gridPlotData,1),n,num2str(n), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'Color',textColor,'Tag','numLabel')
    end
    tmp=squeeze(gridPlotData(:,:,k));
    [~,ind]=max(tmp(:)); clear tmp
    [r,c]=ind2sub([size(gridPlotData,1) size(gridPlotData,2)],ind);
    text(c,r,'M','FontSize',20,'Color','w','Tag','maxStar', ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle')
    labelPositionsH=findobj(gca,'Tag','numLabel');
    numLabelPositions=get(labelPositionsH,'Position');
    numLabelPositions=cat(1,numLabelPositions{:});
    numLabelPositions(:,3)=[];
    [indLabelPos,~]=ismember(numLabelPositions,[c,r],'rows');
    if nnz(indLabelPos)
        delete(labelPositionsH(indLabelPos))
    end
end

if scaleColor
    clim=[min(gridPlotData(:)) max(gridPlotData(:))];
    if clim(1)<0, clim(1)=0; end
    for k=1:numel(axH)
        set(gcf,'CurrentAxes',axH(k))
        caxis(clim)
    end
end

% pretty up the colorbars
set(findobj(gcf,'Tag','Colorbar'),'TickLength',[0 0],'box','off')

% put a label in empty space, if there is any.  Otherwise, put it in the
% last set of axes, which is sure to contain the lowest levels of decoding.
if sqrt(size(gridPlotData,3))^2 ~= floor(sqrt(size(gridPlotData,3)))^2
    % it is not square, put it in empty space
    plot2pos=get(axH(2),'Position');
    labelAx=axes('Position',[plot2pos(1) 0 plot2pos(3:4)]);
    set(labelAx,'Visible','off')
    text(0.5,0.5,VAFstruct(1).electrodeType,'FontSize',40, ...
        'FontWeight','bold')
end

