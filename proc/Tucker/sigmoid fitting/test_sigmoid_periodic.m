%test sigmoid periodic

minimum=0;
maximum=1;
ctr=90;
steepness=5;
P1=.1;
params=[minimum,maximum,ctr,steepness,P1];
x=pi*[1:360]/180;
y=sigmoid_periodic(params,x);

plot(x,y)