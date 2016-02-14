function [r_map,r_map_mean, rho, pval, f, x] = CorrCoeffMap(Data,PlotOn,DecoderAge)

r_map = zeros(size(Data,2), size(Data,2));

for i = 1:size(Data,2)
    for j = 1:size(Data,2)
%     r_r = circ_nancorrcc(Data(:,i),Data(:,j));
    r_r = corrcoef(Data(:,i),Data(:,j));
    r_map(i,j) = r_r(1,2);
%     r_r = corrcoef(r2_Y_SingleUnitsSorted_DayAvg(:,i),r2_Y_SingleUnitsSorted_DayAvg(:,j));
%     r_r_Y_SingleUnitsDayAvg(i,j) = r_r(1,2);
    end
end

% figure
% imagesc(r_map)
title('Correlation Coefficient Map')
xlabel('LFP Decoder Age')
ylabel('LFP Decoder Age')

for i=1:size(Data,2)
    inds=setdiff(1:(size(Data,2)),i);
    r_map_mean(i)=nanmean(r_map(inds,i));
end

if PlotOn == 1   
%     figure
    if iscell(DecoderAge)
        x = cell2mat(DecoderAge)';
    else
        x = DecoderAge;
    end
    
    figure
    plot(x, r_map_mean,'ko')
    xlabel('Decoder Age')
    ylabel('Mean Correlation Coefficient')
    title('Mean Corr Coeff Map')
    
    ah = findobj(gca,'TickDirMode','auto')    
    set(ah,'Box','off')
    set(ah,'TickLength',[0,0])
    
    Xticks = [floor(min(x)/100)*100 ceil(max(x)/100)*100]
% size(Xlabels,1)];
%     Xticks = [Xticks' get(gca,'Xtick')]';
%     Xticks = sort(Xticks)
%     Xticks = unique(Xticks);
    set(gca,'XTick',Xticks,'XTickLabel',Xticks)
    
    hold on 
    x(isnan(r_map_mean)==1) = [];
    r_map_mean(isnan(r_map_mean)==1) = [];
    
    p = polyfit(x,r_map_mean,1);
    f = polyval(p,x);
    plot(x,f,'k-')
    ylim([0 1])
    
    [rho pval] = corr(x',r_map_mean')
    legend('Mean PD Map Correlation',['Linear Fit - ','R= ' num2str(rho,4) '  (P = ',num2str(pval),')'])
    
end

% f = fittype('a*x+b','independent','x','coefficient',{'a' 'b'})
% [c2,gof2] = fit(x',r_map_mean',f,'startpoint',[0,0])
% plot(c2,'c-x')
