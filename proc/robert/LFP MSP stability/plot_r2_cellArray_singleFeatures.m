function plot_r2_cellArray_singleFeatures(r2Array,bestc,bestf)

% this function only works with 2D r2Array.  If there is a monkey dimension
% in the input array, squeeze it out before passing it to this function.

r2Avg=nan(576,size(r2Array,1));
for n=1:size(r2Array,1)
    featind=sub2ind([6 96],bestf{n},bestc{n});
    r2Avg(featind,n)=mean(cat(2,r2Array{n,:}),2);
end
% r2Avg(sum(isnan(r2Avg),2)==size(r2Avg,2),:)=[];

figure, imagesc(r2Avg)

try                                                                         %#ok<TRYNC>
    [~,~,~,~,~,~] = CorrCoeffMap(r2Avg,0);
end

temp=nanmean(get(get(gca,'Children'),'CData'),2); 
figure
plot(temp,'ok','LineWidth',2)
set(gca,'Ylim',[0 1],'FontSize',16,'box','off', ...
    'XTick',[min(get(gca,'Xlim')) max(get(gca,'Xlim'))])
set(gcf,'Color',[0 0 0]+1)