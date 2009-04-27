%extract variable from filter structure
H = filter.H;
P = filter.P;
neuronIDs = filter.neuronIDs;

%original filter columns:
% 1- FDSu 2- 2-FDSm 3-FDPu 4-FDPm 5-FCR1 6-FCU 7-FPB 8-FDI 9-ECR 10-EDC 11-ECU 12-1/2IO

Notes = ['modified filter, prediction columns:'...
            '[1-FDSu 2-FDSm 3-FDPu 4-FDPu 5-FDPm 6-FDPm 7-FCR 8-1/2IO 9-FPB 10-ECR 11-ECR 12-ECR 13-EDC 14-FDI]'];

%modify filter columns        
Hmod = H;
Hmod(:,4) = H(:,3);
Hmod(:,5) = H(:,4);
Hmod(:,6) = H(:,4);
Hmod(:,7) = H(:,5);
Hmod(:,8) = H(:,12);
Hmod(:,9) = H(:,7);
Hmod(:,10) = H(:,9);
Hmod(:,11) = H(:,9);
Hmod(:,12) = H(:,9);
Hmod(:,13) = H(:,10);
Hmod(:,14) = H(:,8);
H = Hmod;
clear Hmod;

%modify polynomial rows
Pmod = P;
Pmod(4,:) = P(3,:);
Pmod(5,:) = P(4,:);
Pmod(6,:) = P(4,:);
Pmod(7,:) = P(5,:);
Pmod(8,:) = P(12,:);
Pmod(9,:) = P(7,:);
Pmod(10,:) = P(9,:);
Pmod(11,:) = P(9,:);
Pmod(12,:) = P(9,:);
Pmod(13,:) = P(10,:);
Pmod(14,:) = P(8,:);
P = Pmod;
clear Pmod;

