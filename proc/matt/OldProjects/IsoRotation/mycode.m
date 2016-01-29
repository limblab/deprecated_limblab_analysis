% Look at Emily's visuomotor rotation data
clear;
close all;
clc;

load('test.mat');

% Get trial table
%    1: Start time
%  2-5: Target              -- ULx ULy LRx LRy
%    6: Outer target (OT) 'on' time
%    7: Go cue
%    8: Trial End time
%    9: Trial result        -- R, A, I, or F 
%   10: Target ID           -- Target ID (based on location)
% tt = wf_trial_table(b);

% Fit tuning curves to each cell
[btc,bsg,bfr] = fitTuningCurve(b,0.5);
[r1tc,r1sg,r1fr] = fitTuningCurve(r1,0.5);
[r2tc,r2sg,r2fr] = fitTuningCurve(r2,0.5);
[wtc,wsg,wfr] = fitTuningCurve(w,0.5);

% Exclude cells whose modulation is not significant
%   first pass: threshold
thresh = 1;
temp = btc(:,2) >= thresh;
btc = btc(temp,:);
bsg = bsg(temp,:);
bfr = bfr(temp);

temp = r1tc(:,2)>thresh;
r1tc = r1tc(temp,:);
r1sg = r1sg(temp,:);
r1fr = r1fr(temp);

temp = r2tc(:,2)>thresh;
r2tc = r2tc(temp,:);
r2sg = r2sg(temp,:);
r2fr = r2fr(temp);

temp = wtc(:,2)>thresh;
wtc = wtc(temp,:);
wsg = wsg(temp,:);
wfr = wfr(temp);

% Find the units that are consistent across files... this hack works heh
sg = intersect(intersect(intersect(bsg,r1sg,'rows'),r2sg,'rows'),wsg,'rows');

[bsg,I] = intersect(sg,bsg,'rows');
btc = btc(I,:);
bfr = bfr(I);
[r1sg,I] = intersect(sg,r1sg,'rows');
r1tc = r1tc(I,:);
r1fr = r1fr(I);
[r2sg,I] = intersect(sg,r2sg,'rows');
r2tc = r2tc(I,:);
r2fr = r2fr(I);
[wsg,I] = intersect(sg,wsg,'rows');
wtc = wtc(I,:);
wfr = wfr(I);

% Finally! We have consistent cells.
% Look at PDs
nbins = 30;

figure;
subplot1(4,1);
subplot1(1);
hist(wrapAngle(wtc(:,3)),nbins);
title('PD by epoch');
ylabel('baseline');
axis('tight');
subplot1(2);
hist(wrapAngle(r1tc(:,3)),nbins);
ylabel('early adaptation');
axis('tight');
subplot1(3);
hist(wrapAngle(r2tc(:,3)),nbins);
ylabel('late adaptation');
axis('tight');
subplot1(4);
hist(wrapAngle(wtc(:,3)),nbins);
ylabel('washout');
axis('tight');

figure;
subplot1(3,1);
subplot1(1);
hist(wrapAngle(r1tc(:,3)-btc(:,3)),nbins);
title('Change in PDs relative to baseline');
ylabel('early adaptation');
axis('tight');
subplot1(2);
hist(wrapAngle(r2tc(:,3)-btc(:,3)),nbins);
ylabel('late adaptation');
axis('tight');
subplot1(3);
hist(wrapAngle(wtc(:,3)-btc(:,3)),nbins);
ylabel('washout');
axis('tight');

% pds = [btc(:,3) r1tc(:,3) r2tc(:,3) wtc(:,3)];
% figure;
% plot(pds');


% Look at depth of modulation for each target

figure;
subplot1(4,1);
subplot1(1);
hist(btc(:,2),nbins);
title('Modulation Depth by Epoch');
ylabel('baseline');
axis('tight');
subplot1(2);
hist(r1tc(:,2),nbins);
ylabel('early adaptation');
axis('tight');
subplot1(3);
hist(r2tc(:,2),nbins);
ylabel('late adaptation');
axis('tight');
subplot1(4);
hist(wtc(:,2),nbins);
ylabel('washout');
axis('tight');

figure;
subplot1(3,1);
subplot1(1);
hist(r1tc(:,2)-btc(:,2),nbins);
title('Change in Modulation Depth relative to baseline');
ylabel('early adaptation');
axis('tight');
subplot1(2);
hist(r2tc(:,2)-btc(:,2),nbins);
ylabel('late adaptation');
axis('tight');
subplot1(3);
hist(wtc(:,2)-btc(:,2),nbins);
ylabel('washout');
axis('tight');

% Look at overall activity

figure;
subplot1(4,1);
subplot1(1);
hist(bfr,nbins);
title('Mean Activity by epoch');
ylabel('baseline');
axis('tight');
subplot1(2);
hist(r1fr,nbins);
ylabel('early adaptation');
axis('tight');
subplot1(3);
hist(r2fr,nbins);
ylabel('late adaptation');
axis('tight');
subplot1(4);
hist(wfr,nbins);
ylabel('washout');
axis('tight');

figure;
subplot1(3,1);
subplot1(1);
hist(r1fr-bfr,nbins);
title('Change in mean activity relative to baseline');
ylabel('early adaptation');
axis('tight');
subplot1(2);
hist(r2fr-bfr,nbins);
ylabel('late adaptation');
axis('tight');
subplot1(3);
hist(wfr-bfr,nbins);
ylabel('washout');
axis('tight');



