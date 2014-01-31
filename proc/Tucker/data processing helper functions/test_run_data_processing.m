%test run data processing
    main_function_name='quickscript_20only_function';
    target_directory='E:\processing\CO_bump\BD efficacy checking\37degstim\psychometrics2014\';
    indata.matrix=rand(10);
    indata.string='this is a test';
    run_data_processing(main_function_name,target_directory,indata)