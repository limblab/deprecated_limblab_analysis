data_location = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-04-09\';
BC_file = 'Chewie_Spike_RW_04092014004';
log_file = dir([data_location BC_file '*.txt']);
log_file = log_file(1).name;
[~,log_file,~] = fileparts(log_file);

out_struct = get_plexon_data([data_location BC_file '.plx'],'verbose');
% Remove all data before 'startup' and save in new file
FID = fopen([data_location log_file '.txt'], 'r');
str = fread(FID, [1, inf], '*char');
fclose(FID);
FID_new = fopen([data_location log_file '_correctPos.txt'],'w');
fwrite(FID_new,str(strfind(str,'startup')+7:end));
fclose(FID_new);

trial_log = load([data_location log_file '_correctPos.txt']);

columns = strfind(str(1:strfind(str(1:1000),'TimeDifference')),'----------------Predictions----------------');
columns = columns+44;
columns = str(columns:strfind(str(1:1000),'TimeDifference'));
X_pos_column = length(strfind(columns(1:strfind(columns,'X_Position')),' '))+1;
Y_pos_column = length(strfind(columns(1:strfind(columns,'Y_Position')),' '))+1;
timestamp_column = length(strfind(columns(1:strfind(columns,'TimeStamp')),' '))+1;

trial_log(:,timestamp_column) = (trial_log(:,timestamp_column)-trial_log(1,timestamp_column))/10^9;
trial_log = trial_log(find(trial_log(:,timestamp_column)>=out_struct.pos(1,1),1,'first'):...
    find(trial_log(:,timestamp_column)<=out_struct.pos(end,1),1,'last'),:);
dt = diff(out_struct.pos(1:2,1));
out_struct.pos(1:100,2:3) = repmat(trial_log(1,X_pos_column:Y_pos_column),100,1);
for i = 1:size(trial_log,1)-1
    idx = round(1+1/dt*[trial_log(i,timestamp_column) trial_log(i+1,timestamp_column)])-1000;
    idx = idx(1):idx(2)-1;
    out_struct.pos(idx,2:3) = repmat(trial_log(i,X_pos_column:Y_pos_column),length(idx),1);
end
out_struct.pos(idx(end):end,2:3) = repmat(trial_log(i,X_pos_column:Y_pos_column),size(out_struct.pos(idx(end):end,2:3),1),1);

save([data_location BC_file '_correctPos'],'out_struct');