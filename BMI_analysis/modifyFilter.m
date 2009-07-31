%extract variable from filter structure
H = filter.H;
P = filter.P;
fillen = filter.fillen;
binsize = filter.binsize;
neuronIDs = filter.neuronIDs;

%original filter columns:
% 1- FDSu 2- 2-FDSm 3-FDPu 4-FDPm 5-FCR1 6-FCR2 7-PaL 8-FCU1 9-ECR 10-EDC 11-EDC2 12-FDI


Notes = ['modified filter, prediction columns:'...
            '[1-FDSu 2-FDSm 3-FDPu 4-FDPu 5-FDPm 6-FDPm 7-ECR 8-ECR 9-EDC1 10-EDC1 11-EDC1 12-EDC2 13-EDC2 14-EDC2 15-FDI]'];

%modify filter columns        
Hmod = H;
Hmod(:,4) = H(:,3);
Hmod(:,5) = H(:,4);
Hmod(:,6) = H(:,4);
Hmod(:,7) = H(:,9);
Hmod(:,8) = H(:,9);
Hmod(:,9) = H(:,10);
Hmod(:,10) = H(:,10);
Hmod(:,11) = H(:,10);
Hmod(:,12) = H(:,11);
Hmod(:,13) = H(:,11);
Hmod(:,14) = H(:,11);
Hmod(:,15) = H(:,12);
H = Hmod;
clear Hmod;

%modify polynomial rows
Pmod = P;
Pmod(4,:) = P(3,:);
Pmod(5,:) = P(4,:);
Pmod(6,:) = P(4,:);
Pmod(7,:) = P(9,:);
Pmod(8,:) = P(9,:);
Pmod(9,:) = P(10,:);
Pmod(10,:) = P(10,:);
Pmod(11,:) = P(10,:);
Pmod(12,:) = P(11,:);
Pmod(13,:) = P(11,:);
Pmod(14,:) = P(11,:);
Pmod(15,:) = P(12,:);
P = Pmod;
clear Pmod;

