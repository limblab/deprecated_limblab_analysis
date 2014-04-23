function plot_r2_cellArray_singleUnits(r2CellArray,DecNeuronIDs,featIndFromDecoder)

% plot function is designed to work for 1 monkey at a time.  Therefore, any
% 3D r2 arrays should have the monkey dimension squeezed out before being
% passed in to this function.
%
% featIndFromDecoder only makes sense if the quantity requested is MSP
% performance/stability during LFP control.  In which case, the indices
% should come from the LFP decoder.  MSP control uses all channels, so MSP
% performance/stability during MSP control makes no sense.

universalIDSet=cat(1,DecNeuronIDs{:});
uniqueChSet=unique(universalIDSet(:,1));
uniqueChSet(uniqueChSet==0)=[];

r2CellArray_uniqueSet=cell(size(r2CellArray));
r2CellArray_avg=cell(1,size(r2CellArray,1));
for n=1:size(r2CellArray,1)
    for k=1:size(r2CellArray,2)
        for m=1:length(uniqueChSet)
            matchesUniqeSet=find(DecNeuronIDs{n,k}(:,1)==uniqueChSet(m) & DecNeuronIDs{n,k}(:,2)==1);
            if isempty(matchesUniqeSet)
                r2CellArray_uniqueSet{n,k}(m)=NaN;
            else
                r2CellArray_uniqueSet{n,k}(m)=r2CellArray{n,k}(matchesUniqeSet);
            end
        end
    end
    r2CellArray_avg{n}=nanmean(cat(1,r2CellArray_uniqueSet{n,:}));
end
r2CellArray_avg=cat(1,r2CellArray_avg{:});

if nargin > 2
    [~,ch]=ind2sub([6 96],featIndFromDecoder);
    [~,ind]=setdiff(uniqueChSet,unique(ch));
    r2CellArray_avg(:,ind)=[];
end

[crossFileMean,sortInd]=sort(nanmean(r2CellArray_avg,1),'descend');


chansToRemove=unique(rowBoat(find(crossFileMean==0)));

r2CellArray_avg_plot=r2CellArray_avg(:,sortInd)';
r2CellArray_avg_plot(chansToRemove,:)=[];

figure, imagesc(r2CellArray_avg_plot)


try                                                                         %#ok<TRYNC>
    [~,~,~,~,~,~] = CorrCoeffMap(r2CellArray_avg_plot,0);
end

temp=nanmean(get(get(gca,'Children'),'CData'),2); 
figure
plot(temp,'ok','LineWidth',2)
set(gca,'Ylim',[0 1],'FontSize',16,'box','off', ...
    'XTick',[min(get(gca,'Xlim')) max(get(gca,'Xlim'))])
set(gcf,'Color',[0 0 0]+1)