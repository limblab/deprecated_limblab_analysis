numLags=find(binnedData.timeframe==OLPredData.timeframe(1));

numEMGs = size(binnedData.emgdatabin,2);
offset = zeros(1,numEMGs);
slope = zeros(1,numEMGs);

for i=1:numEMGs
   figure;
    x=binnedData.emgdatabin(numLags:end,i);
    y=OLPredData.preddatabin(:,i);
    plot(x,y,'r.');
    title(sprintf('%s',binnedData.emgguide(i,:)));
    xlabel('Actual Data');
    ylabel('Predicted Data');
    linreg=fit(x,y,'poly1');
    offset(1,i) = linreg.p2;
    slope(1,i) = linreg.p1;
   hold on;
   plot(xlim,linreg(xlim))
   legend(sprintf('offset: %g, slope: %g',offset(1,i),slope(1,i)));
end