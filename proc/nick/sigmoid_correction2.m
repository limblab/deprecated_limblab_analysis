x = -40:0.1:40;

% standard sigmoid
a = 5;
b = 20;
c = 1;

for z = 1:length(x)
    
    y(z) = a*x(z) + a*b / (1 + exp(.2236 * x(z))) - a*b/2;

%     y(z) = a*x(z) - b / (1 + exp(-c * x(z))) - b/2;

    
end
figure
plot(x,y,'b',x,x,'r',x,2*x,'g',x,c*x,'m')
% axis([-20 20 -20 20])
axis([-40 40 -40 40])

% figure
% plot(y,x,'b',x,x,'r')
% axis([-40 40 -40 40])