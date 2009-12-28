figure;
hold on;
    plot(aveEMGs(:,1),aveEMGs(:,2:end));

    
for i=1:12
    figure;hold on;
    tmpN = binnedData.emgdatabin(:,i)/max(binnedData.emgdatabin(:,i));
    plot(binnedData.timeframe(:,1),tmpN,'b')
    tmpN = ModelData.emgdatabin(:,i)/max(ModelData.emgdatabin(:,i));
    plot(ModelData.timeframe(:,1),tmpN,'g');
    legend(ModelData.emgguide(i,:));
end

