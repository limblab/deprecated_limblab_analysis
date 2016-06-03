function [stabilityMatrix,kinInfo]=stabilityOfLFPs(kinStruct)

% take each date included in the kinStruct, load in the decoder that was
% used, get from that decoder the information about which channels were
% used and how they were weighted.  Restrict to the top 5-10 weighted
% channels?  For those channels, calculate the
% power in the appropriate band.  See how those changed from day to
% day.  Is going to take a while to run, because of the need to
% recalculate feature matrix for each day.  
% elementsToKeep should be a large enough number that N elements will make
% it through to the end of kinStruct without having been zeroed out or
% otherwise lost along the way.  The final roster of elements kept out of
% this should have been included in every decoder, from first to last, the
% same channel/band each time.  That way, stabillityMatrix has a constant 
% number of columns.

cd('Y:\user_folders\Robert\data\monkey\outputs\LFPcontrol\Stability')

kSind=1;
stabilityMatrix=nan(length(kinStruct),150,3);
kinInfo=struct([]);

for ind=1:length(kinStruct)
    if isnan(kinStruct(ind).decoder_age)
        fprintf(1,'%s is hand control.  skipping...\n',kinStruct(ind).name)
        continue
    end
    fprintf(1,'%s is brain control.  finding path to local copy...\n', ...
        kinStruct(ind).name)
    pathToBDF=findBDF_local(kinStruct(ind).name,1);
    fprintf(1,'%s found.  loading file...\n',pathToBDF)
    load(pathToBDF)
    if isempty(out_struct.raw.analog.data)
        % this happens in exactly 1 case, but we still have to account for
        % it.
        fprintf(1,'%s had no LFP data.\n',out_struct.meta.filename)
        continue
    end
    % find the actual decoder used, by examining the first line of the
    % BR log.
    fprintf(1,'%s loaded.  finding decoder file...\n',out_struct.meta.filename)
    [pathToDecoderMAT,~]=decoderPathFromBDF(out_struct);
    fprintf(1,'loading bestc, bestf, H from %s\n',pathToDecoderMAT)
    load(pathToDecoderMAT,'bestc','bestf','H')
    if kSind==1
        % only interested in whether H is zero or not, so limit it to a single
        % lag for easier testing.
        H_from_decoder=sum(abs(H(1:10:end,:)),2); clear H %#ok<NODEF>
        [sortedBestCF,~]=sortrows([bestc' bestf'],1);
        bestc_from_decoder=bestc; bestf_from_decoder=bestf;
    end
    % calculate PB for this file.  sig is irrelevant; will not be used for
    % anything anyway.  Is required input because of the structure of the
    % function, but can just feed in junk (which out_struct.pos will be,
    % because it's a brain control file and we're loading it from the local
    % machine's copy, so: junk).
    fprintf(1,'calculating feature matrix...\n')
    fpAssignScript
    [featMat,~]=calcFeatMat(fp,out_struct.pos,256,1000,0.05);
    fprintf(1,'done\n')
    for el_ind=1:size(stabilityMatrix,2)        
        % the H test for zeros includes some unnecessary functionality, but
        % it shouldn't hurt anything to leave it.
        if (H_from_decoder(sortedBestCF(:,1)==bestc_from_decoder(el_ind) & ...
                sortedBestCF(:,2)==bestf_from_decoder(el_ind))) ~= 0 
            % if H==0, stabilityMatrix(kSind,el_ind) will stay NaN
            % otherwise, calculate stability quantity.  For LFPs, this
            % means bandpower values from above.
            featInd=(bestc_from_decoder(el_ind)-1)*6+(bestf_from_decoder(el_ind));
            featToUse=featMat(:,featInd);
            stabilityMatrix(kSind,el_ind,1)=mean(featToUse);
            stabilityMatrix(kSind,el_ind,2)=var(featToUse);
            stabilityMatrix(kSind,el_ind,3)=sum(featToUse); 
            if length(kinInfo)==(kSind-1)
                kinInfo(kSind).name=kinStruct(ind).name;
                kinInfo(kSind).decoder_age=kinStruct(ind).decoder_age;
                kinInfo(kSind).bestcf=[rowBoat(bestc) rowBoat(bestf)];
                clear bestc bestf
            end
        end
    end
    %stabilityMatrix(kSind,:)=xcorr or SFD, or other calc.
    kSind=kSind+1;
    clear out_struct featMat fp PB
    cd('Y:\user_folders\Robert\data\monkey\outputs\LFPcontrol\Stability')
    save([inputname(1),'stability.mat'],'stabilityMatrix','kinInfo')
%     if kSind==8, break, end
end, clear ind

if size(stabilityMatrix,1) >= kSind
    stabilityMatrix(kSind:end,:,:)=[];
end
