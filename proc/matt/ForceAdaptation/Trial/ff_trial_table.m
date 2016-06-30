function [tt, x_offset, y_offset, tgt_size] = ff_trial_table(taskType,bdf)
trial_table_reward_flag = 0; % if 1, trial table only has successful trials

switch taskType
    case 'CO'
        tt = ff_trial_table_co(bdf,trial_table_reward_flag);
        x_offset = 0;
        y_offset = 0;
        tgt_size = 0;
    case 'RT'
        [tt, x_offset, y_offset, tgt_size] = ff_trial_table_rt(bdf);
end