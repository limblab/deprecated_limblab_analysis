function [tt, x_offset, y_offset, tgt_size] = ff_trial_table(taskType,bdf)

switch taskType
    case 'CO'
        tt = ff_trial_table_co(bdf);
        x_offset = 0;
        y_offset = 0;
        tgt_size = 0;
    case 'RT'
        [tt, x_offset, y_offset, tgt_size] = ff_trial_table_rt(bdf);
end