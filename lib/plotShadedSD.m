function f = plotShadedSD(X,Y, SD)

numpts = length(X);
xIdx  = [1:numpts numpts:-1:1 1];
xarea = X(xIdx);

for i = 1:size(Y,2)
    ytop = Y(:,i) + SD(:,i);
    ybot = Y(:,i) - SD(:,i);
    yarea = [ytop; ybot(end:-1:1); ytop(1)];
    f = fill(xarea,yarea,[.5 .5 .5],'LineStyle','none','FaceAlpha',0.5);
end
hold on;    
plot(X,Y,'--ko');