figure;
hold on;
    plot(aveEMGs(:,1),aveEMGs(:,2:end));

EMGvector = [3 4 5 9];
for i=1:size(ModelData.emgdatabin,2)
    figure;hold on;
    tmpN = binnedData.emgdatabin(:,EMGvector(i))/max(binnedData.emgdatabin(:,EMGvector(i)));
    plot(binnedData.timeframe(:,1),tmpN,'b')
    tmpN = ModelData.emgdatabin(:,i)/max(ModelData.emgdatabin(:,i));
    plot(ModelData.timeframe(:,1),tmpN,'g');
    legend(ModelData.emgguide(i,:));
end

