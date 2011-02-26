%extract variable from filter structure
H = filter.H;
P = filter.P;
outnames = filter.outnames;        
fillen = filter.fillen;
binsize = filter.binsize;
neuronIDs = filter.neuronIDs;

%original filter columns:
% 1- FDSr 2-FDSu 3-FDPr 4-FDPu 5-ECR1 6-FCR2 7-ECRb 8-FCU2 9-EDCu 10-OP 11-ECU2 12-EPL 

Notes = ['modified filter, prediction columns:'...
            '[1-FDSr 2-FDSu 3-FDSu 4-FDSu 5-FDSu]'];

mod_idx = [1 2 2 2 2];
        
        
%modify output labels        
outnames = outnames(mod_idx,:);
        
%modify filter columns        
H = H(:,mod_idx);

%modify polynomial rows
Pmod = P(mod_idx,:);

