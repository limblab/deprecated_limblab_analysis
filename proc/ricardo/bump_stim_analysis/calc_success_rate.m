% Success rate

filelist = {'D:\Data\bump_stim_forces_test_015',...
            'D:\Data\bump_stim_forces_test_016',...
            'D:\Data\bump_stim_forces_test_017',...
            'D:\Data\bump_stim_forces_test_018',...
            'D:\Data\bump_stim_forces_test_019',...
            'D:\Data\bump_stim_forces_test_020',...
            'D:\Data\bump_stim_forces_test_021'};
        
cursor_displacement = [0.5,1,1.5,2,1,1.5,2]';
        
clear success_rate;

for iFileNo = 1:length(filelist)
    clear trial_table
    trial_table = build_trial_table(filelist{iFileNo});
    for iTrialType = 0:2
        success_rate(iFileNo,iTrialType+1) = ...
            sum(trial_table(:,5)==iTrialType & trial_table(:,4)==reward_code)/sum(trial_table(:,5)==iTrialType);
    end
end

success_rate = [cursor_displacement success_rate] %#ok<NOPTS>

clear succ_bump_chunk
for iDirection=2:trial_table(end,12)-1
%     trial_table(trial_table(:,12)==iDirection & trial_table(:,5)==0,4)
    bump_trials = trial_table(trial_table(:,12)==iDirection & trial_table(:,5)==1,4);
%     trial_table(trial_table(:,12)==iDirection & trial_table(:,5)==2,4)
    chunk_length = floor(length(bump_trials)/3);
    for iChunk = 1:3
        succ_bump_chunk(iDirection,iChunk) = sum(bump_trials((iChunk-1)*chunk_length+1:(iChunk)*chunk_length)==32)/chunk_length;
    end
end
        