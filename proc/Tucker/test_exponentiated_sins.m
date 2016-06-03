ang=[0:359]*pi/180;
G=1;
x=exp(G*cosh(ang));
y=exp(G*sinh(ang));
figure
plot(x,y)
axis equal
figure
plot(x.^2+y.^2)