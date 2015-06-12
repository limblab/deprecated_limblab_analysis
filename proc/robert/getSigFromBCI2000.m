function [sig,CG,varargout]=getSigFromBCI2000(signal,states,parameters,SIGNALTOUSE)

if ~isempty(regexp(SIGNALTOUSE,'force|dfdt','once'))
    CG=[];
end
if ~isempty(regexp(SIGNALTOUSE,'CG','once'))
        % the traditional variable 'sig' contains the PC reconstructions 
        % for the 1st N PCs up to 90% variance.  The the 1st 3 fields of 
        % CG contain and describe the raw CG data (CG.data is double 
        % not uint16).  The last field of CG has the weights for 
        % attempting to re-generate all 22 input signals from the N 
        % output signals returned in sig.  CG.mean and CG.std will
        % need to be stored as gain factors so that when the PCs are 
        % predicted, the gain and offset can be applied in order to 
        % tranlate into CG coordinates.  CG.data is the raw data 
        % (though converted into double precision).
        CG=struct('data',[],'mean',[],'std',[],'coeff',[]);
end

if nnz(cellfun(@isempty,regexp(parameters.SignalSourceFilterChain.Value(:,1),'TDT'))==0)
    samprate=24414.0625/24; % real TDT sample rate (only if samplingRate is 1000)
else
    samprate=parameters.SamplingRate.NumericValue;
end
blockSize=parameters.SampleBlockSize.NumericValue;

fprintf(1,'finding %s signal...\n',SIGNALTOUSE)
if ~isempty(regexp(SIGNALTOUSE,'force|dfdt','once'))
    force_ind=find(strcmpi(parameters.ChannelNames.Value,'force'));
    if isempty(force_ind)
        force_ind=find(strcmpi(parameters.ChannelNames.Value,'ainp1'));
        if isempty(force_ind)
            error('force channel not found\n')
        end
    end
    sig=[rowBoat(1:size(signal,1))/samprate, ...
        signal(:,force_ind).*str2double(parameters.SourceChGain.Value{force_ind})];
    fprintf(1,'force channel gain was %s\n', ...
        parameters.SourceChGain.Value{force_ind});
    % We want to re-create the value that goes into the Application
    % module.  The Application's input is scaled such that the screen
    % position is defined as a value from 0 (bottom of the screen) to
    % 100 (top of the screen). To get into this range when doing hand
    % control, we use the Normalizer.
    sig(:,2)=(sig(:,2)-str2double(parameters.NormalizerOffsets.Value{2}))* ...
        str2double(parameters.NormalizerGains.Value{2});
    fprintf(1,'force channel adjusted by offset (%s) and gain (%s).\n', ...
        parameters.NormalizerOffsets.Value{2}, ...
        parameters.NormalizerGains.Value{2});
    %         % In addition, in Eric's original code there is an offset by a
    %         % value of 50, which makes the cursor starting position the
    %         % center of the screen (for zero-valued input signals).  Currently,
    %         % this is hard-coded.
    %         EWLshift=50;
    %         sig(:,2)=sig(:,2)+EWLshift;
    %         fprintf(1,'shifting force signal upwards by %d (EWL code).\n', ...
    %             EWLshift);
    %         % Lastly, there is an addition parameter, YCenterOffset, that I
    %         % added so that I could make the start position be the top of the
    %         % screen (or the bottom, with a negative value) instead of the
    %         % center.  This is adjustable from within parameters.
    %         if isfield(parameters,'YCenterOffset')
    %             sig(:,2)=sig(:,2)+parameters.YCenterOffset.NumericValue;
    %         end
    %         fprintf(1,'shifting force signal upwards by %d (YCenterOffset parameter).\n', ...
    %             parameters.YCenterOffset.NumericValue);
    if isequal(SIGNALTOUSE,'dfdt')
        %             sig=kindiff([sig, zeros(size(sig,1),1)],samprate);
        %             sig(:,end)=[];
        sig(:,2)=kin_diff(sig(:,2));
    end
end
if ~isempty(regexp(SIGNALTOUSE,'CG','once'))
    CG.channelIndex=1:22;
    for i=1:22
        if isfield(states,['GloveSensor',num2str(i)])
            CG.data(:,i)=states.(['GloveSensor',int2str(i)]);
        else
            CG.channelIndex(CG.channelIndex==i)=[];
        end
    end, clear i
    % there can be a mismatch here, if channels in the middle were cut
    % out by some other function, they will be filled in with all 0's
    % by the above loop.  So make sure they're taken out
    CG.data=CG.data(:,CG.channelIndex);
    % it could also happen independently of outside cut-out that CG
    % channels are all =0 (say for instance, a file that has not yet
    % been analyzed).
    CG.channelIndex(all(CG.data==0,1))=[];
    CG.data(:,all(CG.data==0,1))=[];
    % additionally, look for channels with a max-min range of 0 after
    % blockSize*2+1 (so as to exclude the initial 1-2 blocks where
    % everything is zero).  These are flat channels, therefore we want
    % to exclude them.
    CG.channelIndex((max(CG.data(blockSize*2+2:end,:))- ...
        min(CG.data(blockSize*2+2:end,:)))==0)=[];
    CG.data(:,(max(CG.data(blockSize*2+2:end,:))- ...
        min(CG.data(blockSize*2+2:end,:)))==0)=[];
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
    % if any elements of CG.std are 0, change them to 1 for purposes of
    % division
    CG.std(CG.std==0)=1;
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
    
    % assignin('base','CG',CG)
    if ~isempty(regexp(SIGNALTOUSE,'vel','once'))
        CG.data=kin_diff(CG.data,samprate);
    end
    
    [CG.coeff,CGscores,variances,junk] = princomp(cgz'); %#ok<NASGU> % CG.data
    
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
    % testing...
%     if ~isempty(regexp(SIGNALTOUSE,'vel','once'))
%         sig=[positionData(:,1) kin_diff(positionData(:,2:end),samprate)];
%     end
    
    if nargout > 2
        % do the same for VR data as we did for CG data
        for i=1:20
            VR.data(:,i)=double(states.(['VR',int2str(i)]))-500;
        end, clear i
        % for some reason the VR period of floor values lasts for 2
        % blocks instead of 1 (the CG data only lasts for 1 block)
        VR.data=VR.data([blockSize*2+1 (blockSize*2+1):blockSize:size(VR.data,1) ...
            size(VR.data,1) size(VR.data,1)],:);
        VR.data=interp1(blockTimes',VR.data,analog_times');
        VR.mean=mean(VR.data); VR.std=std(VR.data);
        % if any elements of VR.std are 0, change them to 1 for purposes of
        % division
        VR.std(VR.std==0)=1;
        varargout{1}=VR;
        % there are no (out-of-range) artifacts in VR data, so it is
        % not necessary to implement the artifact removal code here as
        % it was for CG data.
    end
end

    function dx = kin_diff(x,fs)
        % diferentiater function for kinematic signals
        % should differentiate, LP filter at 100Hz and
        % add a zero to adjust for temporal shift
        [b, a] = butter(8, 100/fs);
        dx = diff(x) .* fs;
        dx = filtfilt(b,a,dx);
        if size(dx,1) > size(dx,2)
            dx = [zeros(1,size(dx,2)); dx];
        else
            dx = [zeros(size(dx,1),1), dx];
        end
        
    end % function kin_diff

end