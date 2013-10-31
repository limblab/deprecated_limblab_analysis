%test selfintersect


x=[0:.1:10];
y=[sin(x)];

%plot(x,y)

%[x0,y0,segments]=selfintersect(x,y);
b=close_polygon([x; y]');
plot(b(:,1),b(:,2))