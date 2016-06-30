function dataOUT = remove_offset(dataNEW,sample_rate)

% Removal of baseline
endOffset = 0.1*sample_rate;
dataOUT = dataNEW - repmat(mean(dataNEW(1:endOffset,:)),size(dataNEW,1),1);