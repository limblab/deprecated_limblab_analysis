%extract variable from filter structure
H = filter.H;
P = filter.P;
outnames = filter.outnames;        
fillen = filter.fillen;
binsize = filter.binsize;
neuronIDs = filter.neuronIDs;

%original filter columns:
% 1- FDS1 2-FDS2 3-FDP1 4-FDP2 5-FCR1 6-FCR2 7-FCU1 8-FCU2 9-ECRl 10-ECRb 11-ECU1 12-ECU2 13-EDCu 14-EDCr 

Notes = ['modified filter, prediction columns:'...
            '[1-FDS1 2-FDS1 3-FDS1 4-FDS1 5-FDP1 6-FDP1 7-FDP1 8-FDP1 ]'];

mod_idx = [1 1 1 1 3 3 3 3];
        
        
%modify output labels        
outnames = outnames(mod_idx,:);
        
%modify filter columns        
H = H(:,mod_idx);

%modify polynomial rows
P = P(mod_idx,:);

