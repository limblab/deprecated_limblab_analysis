function fr_plot(summary, monkey, unit_id)
% fr_plot.m

% Plots the firing rate of a neuron both from the model and the observed
% fring rate in a limbstate (speed/direction) space

[rho theta] = meshgrid(0:1:50, 0:pi/16:2*pi);
x = rho .* cos(theta);
y = rho .* sin(theta);


b = summary{unit_id}.b;
p_glm = zeros(size(rho));
for x = 1:size(p_glm,1)
    for y = 1:size(p_glm,2)
        state = [0 0 rho(x,y)*cos(theta(x,y)) rho(x,y)*sin(theta(x,y)) rho(x,y)];
        p_glm(x,y) = glmval(b, state, 'log').*20;
    end
end
figure
h=pcolor(theta, rho, p_glm );
axis square;
suptitle(sprintf('%s-%d-%d', monkey, summary{unit_id}.id(1), summary{unit_id}.id(2)));
xlabel('Direction');
ylabel('Speed (cm/s)');
set(gca,'XTick',0:pi:2*pi)
set(gca,'XTickLabel',{'0','pi','2*pi'})
set(h, 'EdgeColor', 'none');
      



