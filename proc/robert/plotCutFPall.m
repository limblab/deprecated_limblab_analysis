function plotCutFPall(cutfp)

figure, set(gcf,'Position',[1         0        1440         801])
% second monitor
% set(gcf,'Position',[-479         879        1920        1007])
set(gca,'Position',[0.0281    0.0437    0.9562    0.9315])

scaleFactor=1000;
hold off

plotTimes=0;
for n=1:length(cutfp)
	plotTimes=plotTimes(end)+1+cutfp(n).times;
	for k=1:size(cutfp(n).data,1)
		if ~isempty(intersect(k,cutfp(n).bestc))
			plot(plotTimes,scaleFactor*k+cutfp(n).data(k,:),'g')
		else
			plot(plotTimes,scaleFactor*k+cutfp(n).data(k,:),'r')
		end
		hold on
	end
end
axis tight