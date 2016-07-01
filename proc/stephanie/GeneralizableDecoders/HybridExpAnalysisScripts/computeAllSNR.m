function SNR = computeAllSNR(binnedData,EMGind)


for i = 1:length(EMGind)
    ind = EMGind(i);
    SNR(i,1) = binnedData.emgguide(ind);
    SNR(i,2) = num2cell(ComputeSignal2Noise(binnedData.emgdatabin(:,ind)));
end
