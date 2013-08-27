function tt = ff_trial_table(taskType,bdf,holdTime)
% holdTime only needed for CO case

switch taskType
    case 'CO'
        tt = ff_trial_table_co(bdf,holdTime);
    case 'RT'
        tt = ff_trial_table_rt(bdf);
end