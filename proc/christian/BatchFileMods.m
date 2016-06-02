clear
filenums = [2 7 9 11];
filedate = '04-22-11';

for i = 1:length(filenums)
    filenum = strrep(sprintf('%3.0f',filenums(i)),' ','0');   
    
    fileName = sprintf('Jaco_%s_%s.mat',filedate,filenum);
    disp(sprintf('processing file %s',fileName));
    
%     b1 = load(sprintf('C:\\Monkey\\Jaco\\Data\\BinnedData\\%s\\Jaco_%s_%s.mat',filedate,filedate,filenum));
    b2 = load(sprintf('C:\\Monkey\\Jaco\\Data\\BinnedData\\%s\\Jaco_%s_%s_Fcorr.mat',filedate,filedate,filenum));
    

%     b1.binnedData.forcedatabin = b2.binnedData.forcedatabin;
%     binnedData = b1.binnedData;
%     save(sprintf('C:\\Monkey\\Jaco\\Data\\BinnedData\\%s\\Jaco_%s_%s.mat',filedate,filedate,filenum),'binnedData');

    b2.binnedData.stim = binPW_atStimFreq(b2.binnedData.stim);
    binnedData = b2.binnedData;
    save(sprintf('C:\\Monkey\\Jaco\\Data\\BinnedData\\%s\\Jaco_%s_%s_Fcorr.mat',filedate,filedate,filenum), 'binnedData');
    disp('Done'); 
end