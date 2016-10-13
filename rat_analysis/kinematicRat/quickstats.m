%to run: load a trial with the correct time interval to catch a set of
%steps and check that the steps are separated correctly, then go.
% filedate = 'tdm'; 
% filenum = 1; 

rat.toe = rat.phalanx

xvals = rat.toe(:, 1)-rat.hip_bottom(:, 1);
yvals = rat.toe(:, 2)-rat.hip_bottom(:, 2);

steps = {};
angles = {};
if length(swing_times)>0
    for i=2:length(swing_times)-1
        steps{i-1} = rat.toe(swing_times{i}:swing_times{i+1}, 1:2);
        angles{i-1} = [rat.angles.hip(swing_times{i}:swing_times{i+1}), ...
            rat.angles.knee(swing_times{i}:swing_times{i+1}), ...
            rat.angles.ankle(swing_times{i}:swing_times{i+1})];
    end
else
    steps{1} = rat.toe(:, 1:2);
    angles{1} = [rat.angles.hip(:), ...
        rat.angles.knee(:), ...
        rat.angles.ankle(:)];
end

stepry = [];
steprx = [];
for i=1:length(steps)
    %find range of each step
    stepry(i) = range(steps{i}(:, 2));
    steprx(i) = range(steps{i}(:, 1));
    rhip(i) = range(angles{i}(:, 1));
    rknee(i) = range(angles{i}(:, 2));
    rankle(i) = range(angles{i}(:, 3));
end


% disp('X range');
% disp(['Min val: ' num2str(min(xvals))]);
% disp(['Max val: ' num2str(max(xvals))]);
% disp(['Avg range: ' num2str(mean(steprx))]);
% disp(['Max range: ' num2str(max(steprx))]);
% %disp(sprintf([num2str(min(xvals)) '\t' num2str(max(xvals)) '\t' num2str(mean(steprx)) '\t' num2str(max(steprx))]));
%
% disp(sprintf('\nY range'));
% disp(['Min val: ' num2str(min(yvals))]);
% disp(['Max val: ' num2str(max(yvals))]);
% disp(['Avg range: ' num2str(mean(stepry))]);
% disp(['Max range: ' num2str(max(stepry))]);
% %disp(sprintf([num2str(min(yvals)) '\t' num2str(max(yvals)) '\t' num2str(mean(stepry)) '\t' num2str(max(stepry))]));
%
% disp(sprintf('\nAngles'));
% disp(['Hip min: ' num2str(min(rat.angles.hip))]);
% disp(['Hip max: ' num2str(max(rat.angles.hip))]);
% disp(['Hip range: ' num2str(mean(rhip))]);
% disp(['Knee min: ' num2str(min(rat.angles.knee))]);
% disp(['Knee max: ' num2str(max(rat.angles.knee))]);
% disp(['Knee range: ' num2str(mean(rknee))]);
% disp(['Ankle min: ' num2str(min(rat.angles.ankle))]);
% disp(['Ankle max: ' num2str(max(rat.angles.ankle))]);
% disp(['Ankle range: ' num2str(mean(rankle))]);

%make a structure of the data acquired
s1 = struct('min_x', min(xvals), 'max_x', max(xvals), 'avg_xrange', mean(steprx), 'max_xrange', max(steprx),...
    'min_y', min(yvals), 'max_y', max(yvals), 'avg_yrange', mean(stepry), 'max_yrange', max(stepry), ...
    'hip_min', min(rat.angles.hip), 'hip_max', max(rat.angles.hip), 'hip_range', mean(rhip), ...
    'knee_min', min(rat.angles.knee), 'knee_max', max(rat.angles.knee), 'knee_range', mean(rknee), ...
    'ankle_min', min(rat.angles.ankle), 'ankle_max', max(rat.angles.ankle), 'ankle_range', mean(rankle));
%save this struct
%TODO: test that this saving protocol actually works to save multiple
%variables to the same file.
a = genvarname(['s' filedate num2str(filenum, '%02d')]);
eval([a '= s1;']);
%save('quickdata', genvarname(['s' filedate num2str(filenum, '%02d')]));

disp(sprintf([num2str(min(xvals)) '\t' num2str(max(xvals)) '\t' num2str(mean(steprx)) '\t' num2str(max(steprx)) '\t' num2str(min(yvals)) '\t' num2str(max(yvals)) '\t' num2str(mean(stepry)) '\t' num2str(max(stepry)) '\t' num2str(min(rat.angles.hip)) '\t' num2str(max(rat.angles.hip))...
    '\t' num2str(mean(rhip)) '\t' num2str(min(rat.angles.knee)) '\t' num2str(max(rat.angles.knee)) '\t' ...
    num2str(mean(rknee)) '\t' num2str(min(rat.angles.ankle)) '\t' num2str(max(rat.angles.ankle)) '\t' num2str(mean(rankle))]));

%save xvals, steprx, yvals, stepry, rat.angles.hip, rat.angles.knee,
%rat.angles.ankle, rhip, rknee, rankle, and file date and trial num

%save calculated statistics
data_path = ['/Users/mariajantz/Documents/Work/data/kinematics/processed/']; 
filename = 'collate_stats.mat'; 
if exist([data_path filename], 'file')
    load([data_path filename]); 
    disp(['Adding to statistics file named ' filename]); 
    %define vars as something appended to a cell
    trialname{end+1} = [filedate '_' num2str(filenum(fileind), '%02d')]; 
    endpoint_xvals{end+1} = xvals; 
    endpoint_xval_stepranges{end+1} = steprx; 
    endpoint_yvals{end+1} = yvals; 
    endpoint_yval_stepranges{end+1} = stepry; 
    hip_angle_ranges{end+1} = rhip; 
    knee_angle_ranges{end+1} = rknee; 
    ankle_angle_ranges{end+1} = rankle; 
    swing_time_idx{end+1} = swing_times; 
else
    disp(['Making a new statistics file named ' filename]); 
    %define vars 
    trialname = {[filedate '_' num2str(filenum(fileind), '%02d')]}; 
    endpoint_xvals = {xvals}; 
    endpoint_xval_stepranges = {steprx}; 
    endpoint_yvals = {yvals}; 
    endpoint_yval_stepranges = {stepry}; 
    hip_angle_ranges = {rhip}; 
    knee_angle_ranges = {rknee}; 
    ankle_angle_ranges = {rankle}; 
    swing_time_idx = {swing_times}; 
end
%save the values defined above
save([data_path filename], 'trialname', 'endpoint_xvals', 'endpoint_xval_stepranges', 'endpoint_yvals', 'endpoint_yval_stepranges', ...
    'hip_angle_ranges', 'knee_angle_ranges', 'ankle_angle_ranges', 'swing_time_idx'); 

%save the location of the rat markers in its own file for further processing if
%desired. 
save([data_path filedate '_' num2str(filenum(fileind), '%02d') '_rat.mat'], 'rat'); 






