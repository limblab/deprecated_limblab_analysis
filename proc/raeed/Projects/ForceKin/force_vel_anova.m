%% read csv files
reaches_mat = csvread('C:\Users\rhc307\Documents\Data\ForceKin\Data\Arthur_S1_012-s.csv');
thv = reaches_mat(:,1);
thf = reaches_mat(:,2);
fr = reaches_mat(:,3:end);

%% center reaches on PDs
vel_PD = atan2(sin(thv)'*fr,cos(thv)'*fr);
force_PD = atan2(sin(thf)'*fr,cos(thf)'*fr);
