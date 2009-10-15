% Stimulator commands:
% 11 pulse
% 12 start
% 13 stop
% 14 update
% 15 close
function binnedPW = PWdistrib(ch,binsize, stim_array)

%ChanUpdates = [ts freq PW]
ChanUpdates = stim_array(stim_array(:,2)==14 & stim_array(:,3)==ch,[1 4 6]);
numUpdates = size(ChanUpdates,1);

% bin1: PW=0:[binsize], bin2: PW=[1*binsize+1:2*binsize], etc...
% i.e. bin1 is larger than the others by 1.
binnedPW = zeros(200/binsize,1); 

for i=1:numUpdates-1 %skip the last update cause we don't know when it ends
    
    start= ChanUpdates(i,1); 
    freq = ChanUpdates(i,2);
    PW   = ChanUpdates(i,3);
    stop = ChanUpdates(i+1,1);

    %I assume a pulse is emmited at beginning of the update even though I
    %have no way of knowing when the first pulse occured after an update.
    %This is true with FNS stimulator anyways
    NP = 1+ floor(stop-start)*freq;
    
    if PW < 1
        bin = 1;
    else
        bin = ceil(PW/binsize);
    end
    binnedPW(bin) = binnedPW(bin)+NP;
end
