function [sig,CG]=getSigFromBCI2000(signal,states,parameters,SIGNALTOUSE)

switch lower(SIGNALTOUSE)
    case {'force','dfdt'}
        CG=[];
    case 'cg'
        % the traditional variable 'sig' contains the PC reconstructions for the 1st N
        % PCs up to 90% variance.  The the 1st 3 fields of CG contain and describe
        % the raw CG data (CG.data is double not uint16).  The last field of CG
        % has the weights for attempting to re-generate all 22 input signals
        % from the N output signals returned in sig.  CG.mean and CG.std will
        % need to be stored as gain factors so that when the PCs are predicted,
        % the gain and offset can be applied in order to tranlate into CG
        % coordinates.  CG.data is the raw data (though converted into double
        % precision).
        CG=struct('data',[],'mean',[],'std',[],'coeff',[]);
end
if nnz(cellfun(@isempty,regexp(parameters.SignalSourceFilterChain.Value(:,1),'TDT'))==0)
    samprate=24414.0625/24; % real TDT sample rate (only if samplingRate is 1000)
else
    samprate=parameters.SamplingRate.NumericValue;
end
blockSize=parameters.SampleBlockSize.NumericValue;

fprintf(1,'finding %s signal...\n',SIGNALTOUSE)
switch SIGNALTOUSE
    case {'force','dfdt'}
        force_ind=find(strcmpi(parameters.ChannelNames.Value,'force'));
        if isempty(force_ind)
            force_ind=find(strcmpi(parameters.ChannelNames.Value,'ainp1'));
        end
        sig=[rowBoat(1:size(signal,1))/samprate, ...
            signal(:,force_ind).*str2double(parameters.SourceChGain.Value{force_ind})];
        % scale further by Normalizer values
%         sig(:,2)=(sig(:,2)-str2double(parameters.NormalizerOffsets.Value{2}))* ...
%             str2double(parameters.NormalizerGains.Value{2});
        % shift 1 more time, for the application (cursor position is
        % defined by its displacement from 50, and is offset by
        % YOffsetValue
        % sig(:,2)=sig(:,2)+50;  % this is hard-coded!
        if isfield(parameters,'YCenterOffset')
            sig(:,2)=sig(:,2)+parameters.YCenterOffset.NumericValue;
        end
        if isequal(SIGNALTOUSE,'dfdt')
%             sig=kindiff([sig, zeros(size(sig,1),1)],samprate);
%             sig(:,end)=[];
            sig(:,2)=kin_diff(sig(:,2));
        end
    case 'CG'
        %         cg=zeros(size(signal,1),22);
        for i=1:22
            CG.data(:,i)=states.(['GloveSensor',int2str(i)]);
        end, clear i
        % make CG.data 1 sample longer, in anticipation of interpolation
        CG.data=CG.data([(blockSize+1):blockSize:size(CG.data,1) size(CG.data,1) size(CG.data,1)],:);
        CG.data=double(CG.data);
        % interpolate back up to the size of signal
        analog_times=(1:size(signal,1))/samprate;
        % blockTimes must wrap analog_times, but analog_times sets the size
        % of the output, so make it == to size(signal,1).
        sampfact=blockSize/samprate;
        blockTimes=(0:(size(CG.data,1)-1))*sampfact;
        CG.data=interp1(blockTimes',CG.data,analog_times');
        % Now, delete outrageously large deviations
        % within the signals, often occurring at the beginning of files.
        CG.mean=mean(CG.data); CG.std=std(CG.data);
        cgz=CG.data-repmat(CG.mean,size(CG.data,1),1);
        cgz=cgz./repmat(CG.std,size(CG.data,1),1);
        % transpose for backwards compatibility with legacy code.
        cgz=cgz';
        %Remove the noise "pops" that occur from using >1 file, or just inherent
        %noise from the sensors, by interpolating in the parts that are >2SDs from
        %the mean
        %Do each channel separately in case they are different on different
        %channels
        cgnew=cgz;
        for j=1:size(cgz,1)
            clear badinds badepoch badstartinds badendinds
            badinds=find(cgz(j,:)<-3);
            if ~isempty(badinds)
                badepoch=find(diff(badinds)>1);
                badstartinds=[badinds(1) badinds(badepoch+1)];
                badendinds=[badinds(badepoch) badinds(end)];
                if badendinds(end)==length(cgnew)
                    badendinds(end)=badendinds(end)-1;
                end
                if badstartinds(1)==1 %If at the very beginning of the file need a 0 at start of file
                    cgnew(j,1)=cgnew(j,badendinds(1)+1);
                    badstartinds(1)=2;
                end
                for i=1:length(badstartinds)
                    cgnew(j,badstartinds(i):badendinds(i))=interp1([(badstartinds(i)-1) ...
                        (badendinds(i)+1)],[cgnew(j,badstartinds(i)-1) cgnew(j,badendinds(i)+1)], ...
                        (badstartinds(i):badendinds(i)));
                end
            else
                cgnew(j,:)=cgz(j,:);
            end
        end
        cgz=cgnew;
        clear cgnew
        
        [CG.coeff,CGscores,variances,junk] = princomp(cgz'); % CG.data
        
        % to determine how many components to use, find the # that account for
        % >= 90% of the variance.
        % FOR POSITION THE FUNCTION EXPECTS A TIME VECTOR PREPENDED
        temp=cumsum(variances/sum(variances));
        cutoff90=find(temp >= 0.9,1,'first');
        positionData=[rowBoat(1:size(cgz,2))/1000, CGscores(:,1:cutoff90)];
        CG.coeff=CG.coeff(:,1:cutoff90);
        fprintf(1,'Using %d PCs, which together account for\n',cutoff90)
        fprintf(1,'%.1f%% of the total variance in the PC signal\n',100*temp(size(positionData,2)-1))
        
        sig=positionData;
end

    % diferentiater function for kinematic signals
    % should differentiate, LP filter at 100Hz and add a zero to adjust for
    % temporal shift
    function dx = kin_diff(x)
        [b, a] = butter(8, 20/samprate);
        dx = diff(x) .* samprate;
        dx = filtfilt(b,a,double(dx));
        if size(dx,1)==1
            dx = [0 dx];
        else
            dx = [0;dx];
        end
    end

end