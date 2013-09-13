function tt = ff_trial_table(taskType,bdf)

switch taskType
    case 'CO'
        tt = ff_trial_table_co(bdf);
    case 'RT'
        tt = ff_trial_table_rt(bdf);
end