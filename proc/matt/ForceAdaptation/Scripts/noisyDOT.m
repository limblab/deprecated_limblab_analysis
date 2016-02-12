% Have cosine with varying amounts of noise
clear;
close all;
clc;

theta = (0:0.01:2*pi)';

nIter = 20000;
randScale = 0.001;

figure;
hold all;

for i = 1:nIter    
    st = sin(theta) + i*randScale*(-0.5 + rand( size(theta) ) );
    ct = cos(theta) + i*randScale*(-0.5 + rand( size(theta) ) );
    X = [ones(size(ct)) st ct];
    
    % model is b0+b1*cos(theta)+b2*sin(theta)
    [b,~,~,~,temp] = regress(cos(theta),X);
    
    %plot(theta,b(1)+b(2)*sin(theta) + b(3)*cos(theta),'b');
    
    % convert to model b0 + b1*cos(theta+b2)
    b  = [b(1); sqrt(b(2).^2 + b(3).^2); atan2(b(2),b(3))];
    plot(theta,b(1)+b(2)*cos(theta-b(3)),'b');
    
    out(i) = b(2);
end

plot(theta,cos(theta),'k','LineWidth',3);
set(gca,'TickDir','out','Box','off','FontSize',14,'XLim',[0 2*pi],'YLim',[-1.1, 1.1]);
xlabel('theta (rad)','FontSize',14);
ylabel('cos(theta)','FontSize',14);

figure;
plot(1:nIter,out)
set(gca,'TickDir','out','Box','off','FontSize',14,'YLim',[0 1.1],'XTick',[]);
xlabel('Amount of Noise','FontSize',14);
ylabel('Depth of Tuning Parameter Value','FontSize',14);