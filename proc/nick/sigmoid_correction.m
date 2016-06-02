x = -40:0.1:40;



% standard sigmoid


a = 1.7; %0.65;
b = 23; %10;
c = -b/2;
d = 0;
lambda = .14; %.8;
% y = a*x + b*(exp(d+lambda.*x)./(1+exp(d+lambda.*x))) + c;
% y = a*x + b./(1+exp(-d-lambda.*x)) + c;










% for y versus x slope
a = 0.6;       % slope of asymptote
b = 5;         % slope of transition region  
c = 7;         % perpendicular line separation / 2

% for x versus y slope
a = 1.7;       % slope of asymptote
b = 0.2;         % slope of transition region  
c = 7;         % perpendicular line separation / 2


for z = 1:length(x)
%     y(z) = a*x(z) + b/2*lambda*x(z)/sqrt(1+((lambda*x(z))^2));
%     y(z) = a*x(z) - b/2*lambda*x(z)/sqrt(1+((lambda*x(z))^2));
%     y(z) = a*x(z) - b*x(z)/sqrt(1+(c*(x(z))^2));
%     y(z) = x(z)/a - (b^2/a)*x(z)/sqrt(1+((x(z)/(c/b^2))^2));


%     y(z) = a*x(z) - b*x(z)/sqrt(1+(c*(x(z))^2));


%    y(z) = x(z)/a - (1/a-1/b)*x(z)/sqrt(1+((x(z)/(c/(1-a/b)))^2));
    y(z) = a*x(z) - (a-b)*x(z)/sqrt(1+((1-b/a)*x(z)/c)^2);
end
figure
plot(x,y,'b',x,x,'r',x,a*x,'g',x,b*x,'m')
% axis([-20 20 -20 20])
axis([-40 40 -40 40])

figure
plot(y,x,'b',x,x,'r')
axis([-40 40 -40 40])