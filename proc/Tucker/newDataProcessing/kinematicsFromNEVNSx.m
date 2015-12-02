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

    DateTime = [int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(2)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(4)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(1)) ...
    ' ' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(5)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(6)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(7)) '.' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(8))];

    %get encoder data from serial digital data:
    if datenum(DateTime) - datenum('14-Jan-2011 14:00:00') < 0 
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
    
    %now that we have the encoder strobes, convert those to actual encoder values    
    jumpTimes=[];
    if opts.ignore_jumps
        enc = strobed2encoder(encStrobes,[0 cds.meta.duration]);
    else
        [enc, jumpTimes]= strobed2encoder(encStrobes,cds.meta.fileSepTime);
        if ~isempty(jumpTimes)
            %insert a 'known problem' entry
            cds.addProblem('encoder data contains jumps in encoder output. These have been corrected in software by offsetting the data after the jump')
        end
    end
    
    %check for missing encoder timepoints:
    skips=[];
    %check whether the encoder signal is mangled and make a log of jumps in
    %the times:
    temp=mode(diff(cds.enc.t));
    %get our sig, figs for rounding based on the nominal sampling rate:
    SF=0;
    while temp<1
        SF=SF+1;
        temp=temp*10;
    end
    dt=round(diff(enc(:,1)),SF);%the rounding allows jitter at ~ 10% of the sample frequency because SF is #sig figs+1 after the above while statement
    tstep=unique(round(diff(enc(:,1)),SF));
    
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
    enc=array2table(enc,'VariableNames',{'t','th1','th2'});
    cds.setField('enc',enc)
    clear enc
    
    %convert encoders to position:
    if opts.robot
        pos=enc2handlepos(cds);
    else
        pos=enc2WFpos(cds);
        if ~isempty(skips)
            %insert a 'known problem' entry
            cds.addProblem('inconsistency in encoder timestamps: some data points appear to be missing and were reconstructed via interpolation')
        end
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
    if ~isempty(cds.meta.fileSepTime)
        %pad the file separation times and append to the jump times:
        jumpTimes=[jumpTimes;[cds.meta.fileSepTime(:,1)-pad,cds.meta.fileSepTime(:,2)+pad]];
    end
    if ~isempty(skips)
        %pad the encoder skip times and append to the jump times:
        jumpTimes=[jumpTimes;[skips(:,1)-pad,skips(:,2)+pad]];
    end
    %sanitize times:
    jumpTimes(jumpTimes<0)=0;
    jumpTimes(jumpTimes>cds.enc.t(end))=cds.enc.t(end);
    
    %convert jump times to flag vector indicating when we have good data:
    goodData=ones(size(pos(:,1)));
    temp=[];
    for i=1:size(jumpTimes,1)
        range=[find(pos.t{:,:}>=jumpTimes(i,1),1,'first'),find( pos.t{:,:}<=jumpTimes(i,2),1,'last')];
        %if there are no points inside the window, as the case with
        %fileseparateions, the first point of range will be larger than the
        %second. Thus we use min and max to get the actual window for all
        %cases
        temp=[temp;[min(range):max(range)]'];
    end
    if ~isempty(temp)
        goodData(temp)=0;
    end
    %find still periods:
    still=is_still(sqrt(pos.x.^2+pos.y.^2));
    %append the goodData flag vector, and still vector to pos
    pos=[pos,table(still,goodData,'VariableNames',{'still','good'})];
    %configure labels on pos
    pos.Properties.VariableUnits={'s','cm','cm','bool','bool'};
    pos.Properties.VariableDescriptions={'time','x position in room coordinates. ','y position in room coordinates','Flag indicating whether the cursor was still','Flag indicating whether the data at this time is good, or known to have problems (0=bad, 1=good)'};
    pos.Properties.Description='For the robot this will be handle position, for other tasks this is whatever is fed into the encoder stream';
    cds.setField('pos',pos);
    clear pos
    %use cds.pos to compute vel:
    vx=gradient(cds.pos.x,1/cds.kinFilterConfig.SR);
    vy=gradient(cds.pos.y,1/cds.kinFilterConfig.SR);
    vel=table(cds.pos.t,vx,vy,cds.pos.still,cds.pos.good,'VariableNames',{'t','vx','vy','still','good'});
    clear vx
    clear vy
    vel.Properties.VariableUnits={'s','cm/s','cm/s','bool','bool'};
    vel.Properties.VariableDescriptions={'time','x velocity in room coordinates. ','y velocity in room coordinates','Flag indicating whether the cursor was still','Flag indicating whether the data at this time is good, or known to have problems (0=bad, 1=good)'};
    vel.Properties.Description='For the robot this will be handle velocity. For all tasks this is the derivitive of position';
    cds.setField('vel',vel)
    clear vel
    ax=gradient(cds.vel.vx,1/cds.kinFilterConfig.SR);
    ay=gradient(cds.vel.vy,1/cds.kinFilterConfig.SR);
    acc=table(cds.pos.t,ax,ay,cds.pos.still,cds.pos.good,'VariableNames',{'t','ax','ay','still','good'});
    clear ax
    clear ay
    acc.Properties.VariableUnits={'s','cm/s^2','cm/s^2','bool','bool'};
    acc.Properties.VariableDescriptions={'time','x acceleration in room coordinates. ','y acceleration in room coordinates','Flag indicating whether the cursor was still','Flag indicating whether the data at this time is good, or known to have problems (0=bad, 1=good)'};
    acc.Properties.Description='For the robot this will be handle acceleration. For all tasks this is the derivitive of velocity';
    cds.setField('acc',acc)
    clear acc
    
    cds.addOperation(mfilename('fullpath'),cds.kinFilterConfig);
end