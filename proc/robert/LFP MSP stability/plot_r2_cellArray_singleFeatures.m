function plot_r2_cellArray_singleFeatures(r2Array,bestc,bestf,bandsToUse,featIndFromDecoder)

% this function only works with 2D r2Array.  If there is a monkey dimension
% in the input array, squeeze it out before passing it to this function.

r2Avg=nan(576,size(r2Array,1));
for n=1:size(r2Array,1)
    featind=sub2ind([6 96],bestf{n},bestc{n});
    r2Avg(featind,n)=mean(cat(2,r2Array{n,:}),2);
end
% r2Avg(sum(isnan(r2Avg),2)==size(r2Avg,2),:)=[];

if nargin > 3
    if isempty(bandsToUse)
        bandsToUse=1:6;
    end
    bandInd=zeros(96,length(bandsToUse));
    for n=1:length(bandsToUse)
        bandInd(:,n)=bandsToUse(n):6:size(r2Avg,1);
    end
else
    bandInd=rowBoat(1:size(r2Avg,1));
end
if nargin > 4
    featToKeep=intersect(sort(bandInd(:)),featIndFromDecoder);
else
    featToKeep=sort(bandInd(:));
end
r2Avg=r2Avg(featToKeep,:);
figure, imagesc(r2Avg)

try                                                                         %#ok<TRYNC>
    [~,~,~,~,~,~] = CorrCoeffMap(r2Avg,0);
end
caxis([0 1])
temp=nanmean(get(get(gca,'Children'),'CData'),2); 
figure
plot(temp,'ok','LineWidth',2)
set(gca,'Ylim',[0 1],'FontSize',16,'box','off', ...
    'XTick',[min(get(gca,'Xlim')) max(get(gca,'Xlim'))])
set(gcf,'Color',[0 0 0]+1)