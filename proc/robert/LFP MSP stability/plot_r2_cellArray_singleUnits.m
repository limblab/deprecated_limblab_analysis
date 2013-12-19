function plot_r2_cellArray_singleUnits(r2CellArray,varargin)

r2CellArray_avg=cell(1,size(r2CellArray,1));
for n=1:size(r2CellArray,1)
    r2CellArray_avg{n}=mean(cat(3,r2CellArray{n,1,:}),3); % 1 (y-dimension) is the monkey dimension.
end
r2CellArray_avg=cat(2,r2CellArray_avg{:});
[crossFileMean,sortInd]=sort(nanmean(r2CellArray_avg,2),'descend');

if nargin >= 2
    chansToRemove=varargin{1};    
else
    chansToRemove=[];
end
chansToRemove=unique([rowBoat(chansToRemove); ...
    rowBoat(find(crossFileMean==0))]);

r2CellArray_avg_plot=r2CellArray_avg(sortInd,:);
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