% multiplot

figure;
for row = 1:5
    n = row+50;    
    % ith neuron unc.
    subplot(5,4,(row-1)*4+1);
    m = reshape(activity_unc(n,:), 5, 5);
    surf(asg,rsg,m)
    title(sprintf('Neuron %d (unc)',n));

    % ith neuron con.
    subplot(5,4,(row-1)*4+2);
    m = reshape(activity_con(n,:), 5, 5);
    surf(asg,rsg,m)
    title(sprintf('Neuron %d (con)',n));
    
    
    n = row+55;
    % (i+5)th neuron unc.
    subplot(5,4,(row-1)*4+3);
    m = reshape(activity_unc(n,:), 5, 5);
    surf(asg,rsg,m)
    title(sprintf('Neuron %d (unc)',n));

    % (i+5)th neuron con.
    subplot(5,4,(row-1)*4+4);
    m = reshape(activity_con(n,:), 5, 5);
    surf(asg,rsg,m)
    title(sprintf('Neuron %d (con)',n));

end

