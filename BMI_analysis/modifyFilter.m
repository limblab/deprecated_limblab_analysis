%extract variable from filter structure
H = filter.H;
P = filter.P;
fillen = filter.fillen;
binsize = filter.binsize;
neuronIDs = filter.neuronIDs;

%original filter columns:
% 1- FDSr 2-FDSu 3-FDPr 4-FDPu 5-ECR1 6-FCR2 7-ECRb 8-FCU2 9-EDCu 10-OP 11-ECU2 12-EPL 

Notes = ['modified filter, prediction columns:'...
            '[1-FDSr 2-FDSu 3-FDPr 4-FDPu 5-FDSu]'];

%modify filter columns        
Hmod = H(:,1:5);
Hmod(:,5) = H(:,2);
H = Hmod;
clear Hmod;

%modify polynomial rows
Pmod = P(1:5,:);
Pmod(5,:) = P(2,:);
P = Pmod;
clear Pmod;

