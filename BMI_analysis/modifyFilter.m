%extract variable from filter structure
H = filter.H;
P = filter.P;
outnames = filter.outnames;        
fillen = filter.fillen;
binsize = filter.binsize;
neuronIDs = filter.neuronIDs;

%original filter columns:
% 1- FDSr 2-FDSu 3-FDPr 4-FDPu 5-FCR1 6-ECU1 7-ECU2 8-ECR1 9-ECR2 10-EPL 11-EDC2 12-FCU1 

Notes = ['modified filter, prediction columns:'...
            '[1-FDSr 2-FDSu 3-FDPr 4-FDPu 5-FCR1]'];

mod_idx = [1 2 3 4 5];
        
        
%modify output labels        
outnames = outnames(mod_idx,:);
        
%modify filter columns        
H = H(:,mod_idx);

%modify polynomial rows
P = P(mod_idx,:);

