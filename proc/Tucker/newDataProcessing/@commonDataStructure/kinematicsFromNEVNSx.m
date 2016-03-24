function kinematicsFromNEVNSx(cds,NEVNSx,opts)
    %wrapper function for kinematic processing during cds generation
    
    %get events:
    event_data = double(NEVNSx.NEV.Data.SerialDigitalIO.UnparsedData);
    event_ts = NEVNSx.NEV.Data.SerialDigitalIO.TimeStampSec';       

    idx=skip_resets(NEVNSx.NEV.Data.SerialDigitalIO.TimeStampSec');
    if ~isempty(idx)
        event_data = event_data( (idx(end)+1):end);
        event_ts   = event_ts  ( (idx(end)+1):end);
    end
    clear idx;

    %get encoder data from serial digital data:
    if datenum(opts.dateTime) - datenum('14-Jan-2011 14:00:00') < 0 
        % The input cable for this time was bugged: Bits 0 and 8
        % are swapped.  The WORD is mostly on the high byte (bits
        % 15-9,0) and the ENCODER is mostly on the
        % low byte (bits 7-1,8).
        encStrobes = [event_ts, bitand(hex2dec('00FE'),event_data) + bitget(event_data,9)];
    else
        %The WORD is on the high byte (bits
        % 15-8) and the ENCODER is on the
        % low byte (bits 8-1).
        encStrobes = [event_ts, bitand(hex2dec('00FF'),event_data)];
    end   
    if isempty(encStrobes)
        warning('kinematicsFromNEVNSx:noEncoderData','Found no encoder data, returning without populating cds.pos,cds.vel or cds.acc. Some additional processing relies on kinematics and may fail.');
        disp('load data using the noKin flag to suppress this warning')
        return
    end
    %now that we have the encoder strobes, convert those to actual encoder values    
    jumpTimes=[];
    if opts.ignore_jumps || ~isfield(NEVNSx.MetaTags,'FileSepTime')
        enc = strobed2encoder(encStrobes,[0 opts.duration]);
    else
        [enc, jumpTimes]= strobed2encoder(encStrobes,NEVNSx.MetaTags.FileSepTime);
        if ~isempty(jumpTimes)
            %insert a 'known problem' entry
            cds.addProblem('encoder data contains jumps in encoder output. These have been corrected in software by offsetting the data after the jump')
        end
    end
    
    %check for missing encoder timepoints:
    skips=[];
    %check whether the encoder signal is mangled and make a log of jumps in
    %the times:
    temp=mode(diff(enc(:,1)));
    %get our sig figs for rounding based on the nominal sampling rate:
    sigFig=0;
    while temp<1
        sigFig=sigFig+1;
        temp=temp*10;
    end
    dt=round(diff(enc(:,1)),sigFig);%the rounding allows jitter at ~ 10% of the sample frequency because sigFig is #sig figs+1 after the above while statement
    tstep=unique(round(diff(enc(:,1)),sigFig));
    
    if length(tstep)>1
        %get a list of the skips in data collection
        tstep=tstep(tstep>mode(dt));%we can ignore oversampling, we just care about undersampling
        
        for i=1:length(tstep)
            stepStarts=find(dt==tstep(i));
            stepEnds=stepStarts+1;
            skips=[skips;[enc(stepStarts,1),enc(stepEnds,1)]];
        end
        %interpolate enc to new times:
        newtime=enc(1,1):mode(diff(enc(:,1))):enc(end,1);
        enc=[newtime',interp1(enc(:,1),enc(:,2:3),newtime)];
    end
    enc=decimateData(enc,cds.kinFilterConfig);
    %clip the first 1s because analog data won't start recording for 1s:
    enc=enc(enc(:,1)>=1,:);
    enc=array2table(enc,'VariableNames',{'t','th1','th2'});
    
    set(cds,'enc',enc)
    clear enc
    
    %convert encoders to position:
    if opts.robot
        pos=cds.enc2handlepos(opts.dateTime,opts.labNum);
    else
        pos=cds.enc2WFpos();
    end
    %check for data skips and insert a 'known problem' entry if they exist:
    if ~isempty(skips)
        cds.addProblem('inconsistency in encoder timestamps: some data points appear to be missing and were reconstructed via interpolation')
    end
    
    %handle inconsistencies and make a vector that flags when the data was
    %bad
    %use kinematic filter spec to estimate time for filter ringing to die
    %down. Ringing depends on cutoff frequency, and is ~mostly~ gone after
    %a period equal to 4*(1/cutoff):
    pad=4/cds.kinFilterConfig.cutoff;
    if ~isempty(jumpTimes)
        %convert jump times to window using the pad range:
        jumpTimes=[jumpTimes-pad,jumpTimes+pad];
    end
    if isfield(NEVNSx.MetaTags,'FileSepTime') && ~isempty(NEVNSx.MetaTags.FileSepTime)
        %pad the file separation times and append to the jump times:
        jumpTimes=[jumpTimes;[NEVNSx.MetaTags.FileSepTime(:,1)-pad,NEVNSx.MetaTags.FileSepTime(:,2)+pad]];
    end
    if ~isempty(skips)
        %pad the encoder skip times and append to the jump times:
        jumpTimes=[jumpTimes;[skips(:,1)-pad,skips(:,2)+pad]];
    end
    %sanitize times:
    jumpTimes(jumpTimes<0)=0;
    jumpTimes(jumpTimes>cds.enc.t(end))=cds.enc.t(end);
    
    %convert jump times to flag vector indicating when we have good data:
    goodData=ones(size(cds.enc,1),1);
    temp=[];
    for i=1:size(jumpTimes,1)
        range=[find(cds.enc.t>=jumpTimes(i,1),1,'first'),find( cds.enc.t<=jumpTimes(i,2),1,'last')];
        %if there are no points inside the window, as the case with
        %fileseparateions, the first point of range will be larger than the
        %second. Thus we use min and max to get the actual window for all
        %cases
        temp=[temp;[min(range):max(range)]'];
    end
    if ~isempty(temp)
        goodData(temp)=0;
    end
    
    %find still periods, and build table of kinematics flags:
    still=is_still(sqrt(pos(:,1).^2+pos(:,2).^2));
    
    %use pos to compute vel:
    vx=gradient(pos(:,1),1/cds.kinFilterConfig.SR);
    vy=gradient(pos(:,2),1/cds.kinFilterConfig.SR);
    
    %use cds.vel to compute acc:
    ax=gradient(vx,1/cds.kinFilterConfig.SR);
    ay=gradient(vy,1/cds.kinFilterConfig.SR);
    
    kin=table(cds.enc.t,still,goodData,pos(:,1),pos(:,2),vx,vy,ax,ay, ...
                'VariableNames',{'t','still','good','x','y','vx','vy','ax','ay'});

    kin.Properties.VariableUnits={'s','bool','bool','cm','cm','cm/s','cm/s','cm/s^2','cm/s^2'};
    kin.Properties.VariableDescriptions={ 'time in seconds' ,'Flag indicating whether the cursor was still',...
                                    'Flag indicating whether the data at this time is good, or known to have problems (0=bad, 1=good)',...
                                    'x position in room coordinates. ','y position in room coordinates',...
                                    'x velocity in room coordinates. ','y velocity in room coordinates',...
                                    'x acceleration in room coordinates. ','y acceleration in room coordinates'};
    kin.Properties.Description='Kinematic signals. These are computed from the encoder data, and include position, velocity, acceleration, and flags indicating data quality';
    
    if isempty(cds.kin)
        set(cds,'kin',kin);
    elseif ~isempty(kin)
        cds.mergeTable('kin',kin)
    end
    cds.addOperation(mfilename('fullpath'),cds.kinFilterConfig);
end