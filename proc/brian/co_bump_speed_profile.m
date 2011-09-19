function [mp,vp,ma,va] = co_bump_speed_profile(bdf,tt)

if isempty(tt)
    tt = co_trial_table(bdf);
end

nTargets = max(tt(:,5)) + 1;

active_onsets = cell(nTargets,1);
passive_onsets = cell(nTargets,1);
for dir = 0:nTargets-1
    active_onsets{dir+1} = tt( tt(:,10)==double('R') & tt(:,5)==dir & tt(:,2) == -1 , 8);
    passive_onsets{dir+1} = tt( tt(:,3)==double('H') & tt(:,2)==dir, 4);
end

speed = [bdf.vel(:,1) sqrt(bdf.vel(:,2).^2 + bdf.vel(:,3).^2)];
speed = downsample(speed,5);

t = -.5:0.005:1;
out = zeros(4,length(t));

%[sta,stv] = STA(cell2mat(passive_onsets), speed, -.5, 1);
[mp,vp] = STA2(cell2mat(passive_onsets), speed, .5, 1);
%speed(1,:) = sta;
%speed(2,:) = sqrt(stv);


%[sta,stv] = STA(cell2mat(active_onsets), speed, -.5, 1);
[ma,va] = STA2(cell2mat(active_onsets), speed, .5, 1);
%speed(3,:) = sta;
%speed(4,:) = sqrt(stv);


