clear all; close all;clc;

CLOUDON = 4;
ALIGN_GO = 0;
ALIGN_FBON = 1;
ALIGN_ENDPT = 2;
BINSIZE=0.1;
load('sortedunits/sortedunits_MrT_M1sorted_09252012_UN1D_001.mat');
load('kin/kin_MrT_M1sorted_09252012_UN1D_001.mat');

numMoves = size(kin.pos_x,1);
    figure;
numtrials=size(kin.ts,1);
sm_trials=find(kin.cloudVar==0.5);
lg_trials=find(kin.cloudVar==3.5);

for mi=1:numMoves
   prange = [1:find(isnan(kin.pos_x(mi,:))==1,1,'first')];
   [pks2, locs2] = findpeaks(-kin.speed(mi,prange),'MINPEAKHEIGHT',-15);
   minl = locs2(find(kin.pos_y(mi,locs2)>=kin.cloudPosition,1,'first'));
   if isempty(minl)
        minloc_idx(mi) =NaN;
         minloc_pos_x(mi) =NaN;
         minloc_pos_y(mi) =NaN;
   else
        minloc_idx(mi) = minl;
         minloc_pos_x(mi) = kin.pos_x(mi,   minloc_idx(mi));
         minloc_pos_y(mi) =kin.pos_y(mi,   minloc_idx(mi));
   end
end

figure;
plot(minloc_pos_x,minloc_pos_y,'bo');

return;