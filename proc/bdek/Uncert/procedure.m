%%% FILE WITH NEURONS OF INTEREST %%%
Date = '9/24/2012';
index = 13; %Index of neuron
load bdf_Sorted_MrT_PMd_09242012_UN1D_001-02.mat

    units = bdf;
    clear bdf;
    trains = spiketrains(units,0);
    
%%% FILE WITH BEHAVIOR DATA OF INTEREST %%%
load bdf_MrT_M1_09242012_UN1D_001.mat

    tt = getTT(bdf);
    MAKE_PLOTS = 0;
    NATURE_PLOT = 1;
    
trials;

%procedure2;

spike_trig;
   
    
    



