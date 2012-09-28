clear all
clc

filePath = 'Y:\LocoRats\LocoRat3\TDTData\RatTest2_eneu_raw.csv';

data=dlmread(filePath,',');

% exclude waveforms if the peak is not in the first 20 samples
[~,I] = min(data(:,3:end),[],2);
badWF = I >= 25;
data(badWF,:) = [];

ts = data(:,1); % first column is time stamps
ch = data(:,2); % second column is channel number
data = data(ts<30,3:end); % the rest of the columns are waveforms
ch = ch(ts<30);
ts = ts(ts<30);

uChans = unique(ch);
nChans = length(uChans);
thresh = zeros(1,nChans);
for iChan = 1:nChans
    temp = data(ch==uChans(iChan),:);
    
    % exclude waveforms with high noise
    stdWF = std(temp(:,[1:15,30:end]),[],2);
    badWF = stdWF >= 2.5*mean(stdWF);
    temp(badWF,:) = [];

    % compute a new threshold
    %thresh(iChan) = 3*sqrt(mean(mean(temp.^2,2)));
    thresh(iChan) = -0e-5;
    wf.(['ch' num2str(uChans(iChan))]).good = temp(min(temp,[],2) > thresh(iChan),:);
    wf.(['ch' num2str(uChans(iChan))]).bad = temp(min(temp,[],2) < thresh(iChan),:);
    clear temp;
end

clear data;

figure;
subplot1(4,4);
for i = 1:16
    subplot1(i);
    hold all
    plot(wf.(['ch' num2str(i)]).bad','k')
    plot(wf.(['ch' num2str(i)]).good','b')
    axis('tight');
    title(['ch' num2str(i)]);
    %text(0.5,0.5,['ch' num2str(i)]);
end
