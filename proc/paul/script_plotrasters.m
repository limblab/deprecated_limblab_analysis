load('sortedunits/sortedunits_MrT_M1sorted_09252012_UN1D_001.mat');
load('kin/kin_MrT_M1sorted_09252012_UN1D_001.mat');

ALIGN_GO = 0;
ALIGN_FBON = 1;
ALIGN_ENDPT = 2;
ALIGN_SPEEDMIN = 3;
BINSIZE=0.200;

close all;
% rasters = un1d_plotRasters(sortedunits,kin,ALIGN_FBON);
psth = un1d_plotPSTH_sem(sortedunits,kin,BINSIZE,ALIGN_FBON);

