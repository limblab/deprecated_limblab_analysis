function [bdf]=testAllTuning(bdf)
    %tests tuning on all units when given a bdf from a RW dataset. Uses an
    %ANOVA and bins angle in 45deg chunks. grabs a count of spikes in a
    %100ms bin around target onset, and another at peak speed for a given
    %reach. Tests whether the unit modulates with reach, with direction,
    %and with the interaction between the two. Stores a boolean flag and a
    %dataset array in each bdf.units cell. Boolean flag is true if the
    %significance of either the angle bins or the interaction between angle
    %bin and time during movement is a predictor of FR. will throw a
    %warning if there is a unit that is not modulated with movement but is
    %tuned
    %note this function filters the velocity before finding the peak in
    %order to remove fluctuations in the 200hz range

    %% set basic parameters
        window=.1;

    %% get the trial table for the bdf
        bdf.TT=rw_trial_table(bdf);
    %% find individual reaches within trial
        %get list of target onset times
        numTarg=bdf.TT(:,2);
        targetOn=bdf.TT(:,7+numTarg:7+2*numTarg-1);
        targetOn=reshape(targetOn',(size(targetOn,1)*size(targetOn,2)),1);%make it a column vector
        mask=targetOn>1;%exclude reaches that weren't done (time is -1 in trial table)
        targetOn=targetOn(mask);

    %% find times of peak speed
        %get speed:
        spd=sqrt(bdf.vel(:,2).^2+bdf.vel(:,3).^2);
        [B,A]=butter(3,.1,'low');
        sspd=filtfilt(B,A,spd);

        T=zeros(size(targetOn,1)-1,1);%excludes the last point, which will be dealt with outside the loop
        for i=1:length(targetOn)-1
            %just find first peak in speed after target appearance
            inds=find(bdf.pos(:,1)>targetOn(i) & bdf.pos(:,1)<targetOn(i+1));
            [maxVal,maxInd]=extrema(sspd(inds));
            if isempty(maxInd)
                warning('testAllTuning:NoMaxVel',strcat('Could not find a velocity maxima for target onset# ',num2str(i)))
                disp('skipping target')
                continue
            end
            if maxInd(1)==1 & length(maxInd)>1
                T(i)=inds(1)+maxInd(2);
            else
                T(i)=inds(1)+maxInd(1);
            end

        end
        %deal with last point:
        i=i+1;%adds a single index to the array for the last point
        endTime=bdf.TT(bdf.TT(:,7+2*numTarg(end)-1)==targetOn(i),7+2*numTarg(end));%;locate the correct row
        if ~isempty(endTime)
            inds=find(bdf.pos(:,1)>targetOn(i) & bdf.pos(:,1)<endTime);
            [maxVal,maxInd]=extrema(sspd(inds));
            if isempty(maxInd)
                warning('testAllTuning:NoMaxVel',strcat('Could not find a velocity maxima for target onset# ',num2str(i)))
                T=T(1:end-1);
                disp('skipping target')
            elseif maxInd(1)==1 & length(maxInd)>1
                T(i)=inds(1)+maxInd(2);
            else
                T(i)=inds(1)+maxInd(1);
            end
        end
    %% get angle of individual reaches
        %get positions at target onset
        pos=zeros(size(T,1),2);
        for i=1:size(T,1)
            pos(i,:)=bdf.pos(find(bdf.pos(:,1)>targetOn(i),1),2:3);
        end
        %get positions at vmax
        posVmax=bdf.pos(T,2:3);
        dirVect=posVmax-pos;

        angle=atan2(dirVect(:,2),dirVect(:,1));
        %convert angles from -180->180 range to 0->360 range
        angle(angle<0)=angle(angle<0)+2*pi;    
    %% get tuning info for each unit
        for unit=1:length(bdf.units)
            % find FR at target appearance
                FRA=zeros(size(T,1),1);
                for i=1:length(T)%uses T, to avoid the last point if that was not a complete trial
                    FRA(i)=length(find(bdf.units(unit).ts>(targetOn(i)-window/2) & bdf.units(unit).ts<(targetOn(i)+window/2)));
                end    
            % find the FR at peak speed
                FRB=zeros(size(T,1),1);
                for i=1:size(T,1)
                    FRB(i)=length(find(bdf.units(unit).ts>(T(i)-window/2) & bdf.units(unit).ts<(T(i)+window/2)));
                end
            % get binned directions for each target/reach
                for i=1:8
                    A=(pi/4)*i;
                    angleBin(:,i)=i*(angle>(A-pi/8) & angle<(A+pi/8));
                end
                angleBin=sum(angleBin,2);%angleBin should look like [0 0 0 4 0 0 0 0; 0 2 0 0 0 0 0 0; 0 0 0 0 0 0 7 0; ...] before this operation. the result will be a column vector which contains the sum of a single integer and 7 zeros
            % compose input for isTuned
            
                data=[[FRA;FRB],[zeros(size(FRA));ones(size(FRB))],[angleBin;angleBin]];
            % return tuning info
                [bdf.units(unit).tuned,bdf.units(unit).TuningStatData]=isTuned(data);

        end
end
    
    
    
    
    
    