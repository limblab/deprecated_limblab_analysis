for i = 1:length(S)
            
    lambda1(i) = S{i}(1,1);
    lambda2(i) = S{i}(2,2);
    
end

figure
plot(lambda1)
hold on
plot(lambda2,'r')

legend('Lambda 1','Lambda 2')
title('Lambda over Time')
xlabel('Delay')

figure
for i = 1:length(alpha1)
    
    subplot(5,2,i)
    plot(alpha1{i})
    hold on
    plot(alpha2{i},'r')
    plot(alpha1{i}+alpha2{i},'g')
    
    xlabel('Time (50 ms bins)')
    
end

legend('Alpha 1','Alpha 2','Alpha 1 + Alpha 2')

figure
for i = 1:length(U)
    
    subplot(2,5,i)
    plot([0 U{i}(1,1)],[0 U{i}(2,1)],'--')
    hold on
    plot([0 U{i}(1,2)],[0 U{i}(2,2)],'r--')
    
    title(['Delay ',num2str(i)])
    xlabel('Vx')
    ylabel('Vy')
    xlim([-1 1])
    ylim([-1 1])
    axis square
end

legend('U1','U2')

