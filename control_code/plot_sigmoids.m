function plot_sigmoids(fIN,xIN,color)

for ii = 1:size(fIN,2)
    figure(ii+10); hold on;
    plot(xIN(:,ii),fIN(:,ii),'Color',color)
end