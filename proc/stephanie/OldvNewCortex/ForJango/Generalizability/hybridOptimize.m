%%
tic
options = optimset('GradObj','on');
w_best = (TotalX'*TotalX)\TotalX'*Yvector;
[H,val,~,~,graditt] = fminunc(@(x) hybrid_cost(x,flag,scale,Yvector,TotalX),w_best,options);
time_run = toc

