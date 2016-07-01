function [excel_data] = EvaluateEMGquality(fileName, EMGname,emgPSD)
% Establish metrics for quantifying the quality of EMG recordings

% Look at PSD without 60, 120, 180, 240 info
CleanedUpPSD = emgPSD;
CleanedUpPSD([58:62,118:122,178:182,238:242])=[];
CleanedUpPSDmax = max(CleanedUpPSD);
PeakValue = max(CleanedUpPSD);
HzAtPeak = find(CleanedUpPSD==max(CleanedUpPSD));

maxAround60 = max(emgPSD(58:62));
maxAround120 = max(emgPSD(118:122));
maxAround180 = max(emgPSD(178:182));
maxAround240 = max(emgPSD(238:242));

Max60AndHarmonics = max([maxAround60 maxAround120 maxAround180 maxAround240]);

Max60AndHarmonicsOverPeakValue = Max60AndHarmonics/PeakValue;


excel_data = [fileName,EMGname,num2cell([maxAround60 maxAround120 maxAround180 maxAround240 PeakValue HzAtPeak Max60AndHarmonicsOverPeakValue])];
%output_matrix=[{fileName} col_header; EMGname excel_data]; 



