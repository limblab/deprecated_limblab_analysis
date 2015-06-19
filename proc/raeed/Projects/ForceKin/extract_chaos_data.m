%%
clear
filename = 'mini_bumps_005-6';
load(['Y:\Mini_7H1\Center-out Bumps\bdfs\' filename '.mat'])
% load('Y:\archive\Retired_Monkeys\Arthur_5E1\S1 Array\Processed\Arthur_S1_016.mat')
plot(bdf.pos(:,2),bdf.pos(:,3))

%%
[fr,thv,thf] = obs_window_pds(bdf);

%%
close all
csvwrite(['C:\Users\Raeed\Box Sync\Research\ForceKin\ForceKin Paper\Data\' filename '.csv'],[thv thf fr])