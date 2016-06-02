% function moveonsetfromBDF.m finds movement onset for monkey files from BDF
% file for spikes 8/6/09 MWS
function [movetimes,rewardind,rewardtimes]=moveonsetfromBDF(vel,gotimes,rewardtimes,rewardind,words,windowStart,windowEnd)
%% Alon's code to determine movement onset (adapted from movement_onset_v1.m)
fs=1000;    %sample rate of position signals is 1 kHz for robot in lab 1
[b,a]=butter(4,200/(fs/2));          %LPF at 200Hz 

t2=vel(:,1);        %time vector
% x=filtfilt(b,a,pos(:,2));       %x position
% y=filtfilt(b,a,pos(:,3));       %y position
% if (var(y)<1e-4)
%     y=zeros(1,length(y));       %If we're not recording y dir, set equal to zero
% end
%Now take derivative
% velx=smooth(diff(x),15);             %x velocity, smooth with LPF
% vely=smooth(diff(y),15);         %for y vel

cartVelocity = (vel(:,2).^2 + vel(:,3).^2).^.5;

% with cartesian velocity calculated we will designate 2 thresholds
thr1 = (max(cartVelocity)) / 20;% more restrictive threshold
thr2 = (max(cartVelocity)) / 10; % first pass threshold


% nne=1:64;         %number of "non-noise" electrodes, i.e., number of electrodes used to determine noise threshold (useful if one of the electrodes is bad,

% windowStart=2000/fs;                     %normalized window around reward to look
% windowEnd=0;

if (t2(end)-rewardtimes(end))<= windowEnd    %if too close to end of window
    rewardtimes=rewardtimes(1:(end-1));
    rewardind=rewardind(1:(end-1));
    gotimes=gotimes(1:(end-1));
end
if (rewardtimes(1)-gotimes(1))<=0           %if 1st signal is a reward and not a go, need to delete it
    rewardtimes=rewardtimes(2:end);
    rewardind=rewardind(2:end);
    gotimes=gotimes(2:end);
end

alignMentVector=gotimes;            %Vector of times to align search window around
%preallocate arrays
snipletArray=cell(size(alignMentVector,1),3);
start=zeros(1,size(alignMentVector,1));
stop=start;
startTemp=start;
stopTemp=start;

%for each reward do this loop
for i = 1:size(alignMentVector,1)

    snipletIndex = find(t2-alignMentVector(i) >= -windowStart & t2-alignMentVector(i) <= windowEnd);

    sniplet = cartVelocity(snipletIndex); %is the vector of data to look at
    snipletArray{i,1} = sniplet;
%        cross_thr2 = find((abs(sniplet) > thr2) &
%        (t2(snipletIndex)-gotimes(i)>0.4)', 1 ); %for rat
    cross_thr2= find(abs(sniplet) > thr2,1);
%     cross_thr2 = find((abs(sniplet) > thr1) & (t2(snipletIndex)-gotimes(i)>0.32)', 1 );
    if isempty(cross_thr2) == 1

        start(i) = 0;
        stop(i) = 0;
    else
        if (~isempty(cross_thr2))
            cross_thr1 = min([length(sniplet(cross_thr2-1:-1:1)) find(abs(sniplet(cross_thr2-1:-1:1)) < thr1, 1 )]);
            possible_minima = find(diff(abs(sniplet(cross_thr2:-1:1))) >=0, 1 );
            startTemp(i) = max(1,cross_thr2-min([cross_thr1 possible_minima]));
            %
            if i==1 || i==2
%                 if (startTemp(i)<fsround)       %if too close to start of file, don't use this one
                  if (startTemp(i)<gotimes(1))    %if first movement onset is before first gotime,
                    continue
                end %if starttemp
            end %if i==1

                start(i) = t2(snipletIndex(startTemp(i)));
                snipletArray{i,2} = startTemp(i);
                % cross_thr1 = min([length(sniplet(cross_thr2+1:end)) min(find(abs(sniplet(cross_thr2+1:end)) < thr1))]);
                cross_thr2a = min([length(sniplet(cross_thr2+1:end)) min(find(abs(sniplet(cross_thr2+1:end)) < thr2))]);
                cross_thr1 = min([length(sniplet(cross_thr2+1:end)) min(find(abs(sniplet(cross_thr2+1:end)) < thr1))]);
                possible_minima = min(find(diff(abs(sniplet(cross_thr2+cross_thr2a:cross_thr2+cross_thr1))) >=0));
                if (~isempty(possible_minima))
                    stopTemp(i) = cross_thr2 + cross_thr2a + possible_minima;
                else
                    stopTemp(i)  = cross_thr2 + cross_thr1;
                end
                stop(i) = t2(snipletIndex(stopTemp(i)));
                snipletArray{i,3} = stopTemp(i);
%             end  %if any
        end
    end
end

[cleanindx,cleanindy,movetimes]=find(start);    %take only nonzero values (i.e. artifact-free trials)
nmove=length(movetimes);
rewardind=rewardind(cleanindy);                    %Only use rewards of artifact-free trials
sind=max(find(t2<movetimes(nmove)));      %find last index in order to check how close to the end it is
if ((sind+1000)>length(t2))
    nmove=nmove-1;                      %Don't use the last stimulus if too close to the end of the file.
    rewardind=rewardind(1:(end-1));
    movetimes=movetimes(1:(end-1));
end
rewardtimes=words(rewardind,1);         %reassign rewardtimes since we adjusted number of rewards

