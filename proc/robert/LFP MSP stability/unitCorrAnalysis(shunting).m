%% to do corr analysis for all recording in allChewieNames
binsize=0.001;
starttime=0;
MinFiringRate=0.5;
for n=1:length(allChewieNames)
    try
        load(findBDFonCitadel(allChewieNames{n}))
        stoptime=out_struct.meta.duration;
        binnedData = convertBDF2binned('out_struct',binsize,starttime,stoptime,5,0,MinFiringRate);
        units_Chewie{n}=binnedData.spikeguide;                              %#ok<*SAGROW>
        clear out_struct
        for k=1:size(binnedData.spikeratedata,2)
            for m=1:size(binnedData.spikeratedata,2)
                corrMat_Chewie{n}(k,m)=corr(binnedData.spikeratedata(:,k),binnedData.spikeratedata(:,m));
            end, clear m
        end, clear k
        clear binnedData
    catch ME
        continue
    end
end, clear n

%% to do corr analysis for all recording in allMiniNames
for n=1:length(allMiniNames)
    try
        load(findBDFonCitadel(allMiniNames{n}))
        stoptime=out_struct.meta.duration;
        binnedData = convertBDF2binned('out_struct',binsize,starttime,stoptime,5,0,MinFiringRate);
        units_Mini{n}=binnedData.spikeguide;
        clear out_struct
        for k=1:size(binnedData.spikeratedata,2)
            for m=1:size(binnedData.spikeratedata,2)
                corrMat_Mini{n}(k,m)=corr(binnedData.spikeratedata(:,k),binnedData.spikeratedata(:,m));
            end, clear m
        end, clear k
        clear binnedData
    catch ME
        continue
    end
end, clear n
clear MinFiringRate binsize *time

%% post-processing of corrMat_* using units_*
units_Chewie_num=cellfun(@(x) cellfun(@str2num,x,'UniformOutput',0), ...
    cellfun(@(x) regexp(x,'(?<=ee)[0-9]{2}(?=u1)','match','once'), ...
    cellfun(@cellstr,units_Chewie,'UniformOutput',0),'UniformOutput',0),'UniformOutput',0)';
units_Chewie_num=cellfun(@(x) cat(1,x{:}),units_Chewie_num,'UniformOutput',0);

units_Mini_num=cellfun(@(x) cellfun(@str2num,x,'UniformOutput',0), ...
    cellfun(@(x) regexp(x,'(?<=ee)[0-9]{2}(?=u1)','match','once'), ...
    cellfun(@cellstr,units_Mini,'UniformOutput',0),'UniformOutput',0),'UniformOutput',0)';
units_Mini_num=cellfun(@(x) cat(1,x{:}),units_Mini_num,'UniformOutput',0);

%
corrMatAll_Chewie=zeros(96,96,length(corrMat_Chewie));
for n=1:length(corrMat_Chewie)
    [~,unitsIncluded,~]=intersect(1:96,units_Chewie_num{n});
    corrMatAll_Chewie(unitsIncluded,unitsIncluded,n)=corrMat_Chewie{n};
end, clear n unitsIncluded
figure, imagesc(mean(corrMatAll_Chewie,3))

corrMatAll_Mini=zeros(96,96,length(corrMat_Mini));
for n=1:length(corrMat_Mini)
    [~,unitsIncluded,~]=intersect(1:96,units_Mini_num{n});
    corrMatAll_Mini(unitsIncluded,unitsIncluded,n)=corrMat_Mini{n};
end, clear n unitsIncluded
figure, imagesc(mean(corrMatAll_Mini,3))

