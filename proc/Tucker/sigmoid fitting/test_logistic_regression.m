%testing matlab logistic regressions

%generate two perfect sigmoids:
sig1.min=0;sig1.max=1;sig1.center=90;sig1.steepness=.10;
sig2.min=0;sig2.max=.8;sig2.center=120;sig2.steepness=.1;
x=[1:180];
s1=sigmoid(x,sig1.min,sig1.max,sig1.center,sig1.steepness);
s2=sigmoid(x,sig2.min,sig2.max,sig2.center,sig2.steepness);

plot(s1,'b')
hold on
plot(s2,'r')

%generate a set of random observations around each sigmoid
stepsize=10;
num_obs=10;
x1=[];
x2=[];
y1=[];
y2=[];
for i=1:stepsize:length(x)
    %input vector [angle,case,angle*case]
    x1=[x1;[zeros(num_obs,1),ones(num_obs,1)*0]];%,zeros(num_obs,1)]];
    y1=[y1;1+(rand(num_obs,1)<s1(i))];
    x2=[x2;[ones(num_obs,1)*i,ones(num_obs,1)*1]];%,ones(num_obs,1)*i]];
    y2=[y2;1+(rand(num_obs,1)<s2(i))];

end


X=[x1;x2];
Y=[y1;y2];

[B,dev,stats] = mnrfit(X,Y);