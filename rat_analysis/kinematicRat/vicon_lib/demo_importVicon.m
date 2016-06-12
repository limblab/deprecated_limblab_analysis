clear all
close all

filename      = '../data/rat1/bef_sp12_du2/bef_sp12_du2_01.csv';
ratName       = 'rat1';
treadmillName = 'New Subject';
ratMarkers    = {'knee','hip_bottom','hip_top','hip_center','toe','heel'};
treadMillMarkers = {'root1','root2','horizontal12','horizontal22'};

[ events, rat, treadmill ] = importViconData(filename, ...
                                              ratName,treadmillName, ...
                                              ratMarkers,treadMillMarkers)