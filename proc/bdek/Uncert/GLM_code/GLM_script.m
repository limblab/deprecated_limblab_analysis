Monkey = 'MrT';

month = '09';
day   = '25';
year  = '2012';

curdir = cd;

fprintf('Preparing data...\n');
[bdf,tt,trials2,trains,ts_low,pva] = prepare_vars4GLM(Monkey,[month day year]);

cd(curdir);
clc; fprintf('Constructing GLM...\n');
[X,y,feed,trialinds,min_inds,ids] = construct_GLM(trains,trials2,pva,ts_low);

clc; fprintf('Running GLM...\n');
[X2_p MODEL_1 MODEL_2 preds] = run_GLM(X,y,ids);

aligntype = 1;

clc; fprintf('Plotting GLM output...\n');
plot_GLM(X,y,MODEL_1,MODEL_2,trials2,feed,min_inds,trialinds,aligntype,X2_p);