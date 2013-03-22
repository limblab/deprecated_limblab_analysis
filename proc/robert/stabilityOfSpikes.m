function [stabilityMatrix,kinInfo]=stabilityOfSpikes(kinStruct,elementsToKeep)

% take each date included in the kinStruct, load in the decoder that was
% used, get from that decoder the information about which channels were
% used and how they were weighted.  Restrict to the top 5-10 weighted
% channels?  For those channels, calculate what the spike rate was.
% See how those changed from day to day.  Also, ultimately it would be good
% information to have, to get the number of unsorted waveforms as a ratio of total
% number of waveforms.  Although with a "threshold only" sort, it shouldn't
% be possible to have unsorted waveforms that are recorded.
% elementsToKeep should be a large enough number that N elements will make
% it through to the end of kinStruct without having been zeroed out or
% otherwise lost along the way.  The final roster of elements kept out of
% this should have been included in every decoder, from first to last, the
% same channel/band each time.  That way, stabillityMatrix has a constant 
% number of columns.


kSind=1;
stabilityMatrix=nan(length(kinStruct),elementsToKeep,3);
kinInfo=struct([]);

for n=1:length(kinStruct)
    if isnan(kinStruct(n).decoder_age)
        fprintf(1,'%s is hand control.  skipping...\n',kinStruct(n).name)
        continue
    end
    fprintf(1,'%s is brain control.  finding path to local copy...\n', ...
        kinStruct(n).name)
    pathToBDF=findBDF_local(kinStruct(n).name,1);
    fprintf(1,'%s found.  loading file...\n',pathToBDF)
    load(pathToBDF)
    % find the actual decoder used, by examining the first line of the
    % BR log.
    fprintf(1,'%s loaded.  finding decoder file...\n',out_struct.meta.filename)
    [pathToDecoderMAT,~]=decoderPathFromBDF(out_struct);
    fprintf(1,'loading neuronIDs, H from %s\n',pathToDecoderMAT)
    load(pathToDecoderMAT,'neuronIDs','H')
    % calculate binnedData for this file.  use 0 Hz as a cutoff, i.e.
    % calculate for all units.
    binsize=0.05; starttime=0; MinFiringRate=0; stoptime=out_struct.meta.duration;
    disp('Converting BDF structure to binned data, please wait...');
    binnedData = convertBDF2binned(pathToBDF,binsize,starttime,stoptime,5,0,MinFiringRate);
    binnedData.spikeguide;
    uList=[cellfun(@str2double,regexp(cellstr(binnedData.spikeguide),'(?<=ee)[0-9]+','match','once')), ...
        cellfun(@str2double,regexp(cellstr(binnedData.spikeguide),'(?<=ee[0-9]+u)[0-9]+','match','once'))];
    fprintf(1,'done\n')
    % judge best units by ranking according to H weight(?)
    H_from_decoder=mean(abs(H(1:10:end,:)),2); clear H %#ok<NODEF>
    [~,sortIndH]=sort(H_from_decoder,'descend');
    neuronIDs=neuronIDs(sortIndH,:);
    kinInfo(kSind).numUnits=0;
    
    for el_ind=1:elementsToKeep        
        unitIndCurrentFile=find(uList(:,1)==neuronIDs(el_ind,1) & ...
            uList(:,2)==neuronIDs(el_ind,2),1,'first');
        if ~isempty(unitIndCurrentFile)
            % if found, stabilityMatrix(kSind,el_ind) will be non-NaN,
            % otherwise, will stay NaN.  For Spikes, use calculated
            % rates, etc.
            % meanFR, 
            SPrateDataToUse=binnedData.spikeratedata(:,unitIndCurrentFile);
            stabilityMatrix(kSind,el_ind,1)=mean(SPrateDataToUse);
            stabilityMatrix(kSind,el_ind,2)=var(SPrateDataToUse);
            stabilityMatrix(kSind,el_ind,3)=sum(SPrateDataToUse); 
            kinInfo(kSind).name=kinStruct(n).name;
            kinInfo(kSind).decoder_age=kinStruct(n).decoder_age;
            kinInfo(kSind).numUnits=kinInfo(kSind).numUnits+1;
        end
    end
    %stabilityMatrix(kSind,:)=xcorr or SFD, or other calc.
    kSind=kSind+1;
    clear out_struct featMat fp PB
    cd('Y:\user_folders\Robert\data\monkey\outputs\LFPcontrol\Stability')
    save([inputname(1),'stability.mat'],'stabilityMatrix','kinInfo')
end, clear n








