function plotShadedSD(timeframe,Data, SD)

numpts = length(timeframe);
xIdx  = [1:numpts numpts:-1:1];
xarea = timeframe(xIdx,1);

figure;
plot(timeframe,Data);
hold on;
for i = 1:size(Data,2)
    ytop = Data(:,i) + SD(:,i);
    ybot = Data(:,i) - SD(:,i);
    yarea = [ytop; ybot(end:-1:1)];
    area(xarea,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
end
    
plot(timeframe,Data);    