clear all
close all
location1 = 'C:\Users\wrest_000\Desktop\Local CO\Output_Data\';
location2 ='C:\Users\wrest_000\Desktop\Local Chaos Force\Output_Data\';
location3 ='C:\Users\wrest_000\Desktop\Local Chaos Vel\Output_Data\';
location4 ='C:\Users\wrest_000\Desktop\Local Iso\Output_Data\';
%{
for i = 1:92
    for j = 1:3
        figName{i,j} = sprintf('channel_%d_unit_%d_tuning_plot.fig', i,j);
        if exist([location1,  figName{i,j}])
            coVelData = openfig([location1,figName{i,j}]);
            coChaosVelData = openfig([location2, figName{i,j}]);
            coChaosForceData = openfig([location3, figName{i,j}]);
            coIsoForceData = openfig([location4, figName{i,j}]);
            
            
            %{
            a = findobj(coVelFig, 'type', 'line');
            b = findobj(coChaosVelFig, 'type', 'line');
            c = findobj(coChaosForceFig, 'type','line');
            
            copyobj(a, findobj(coIsoForceFig, 'type', 'axes'));
            copyobj(b, findobj(coIsoForceFig, 'type', 'axes'));
            copyobj(c, findobj(coIsoForceFig, 'type', 'axes'));
            ax = gca;
            %set(ax, 'XLim',[0,10]);
            %}
        end
    end
end

%}
load([location1, 'unit_ids.mat']);
for i = 1:52;
        figure(i);
        bins1 = cell2mat(struct2cell(load([location1, 'bins.mat'])));
        binned_FR1 = cell2mat(struct2cell(load([location1, 'binned_FR.mat'])));
        binned_CI_high1 = cell2mat(struct2cell(load([location1, 'binned_CI_high.mat'])));
        binned_CI_low1 = cell2mat(struct2cell(load([location1, 'binned_CI_low.mat'])));
        
        bins2 = cell2mat(struct2cell(load([location2, 'bins.mat'])));
        binned_FR2 = cell2mat(struct2cell(load([location2, 'binned_FR.mat'])));
        binned_CI_high2 = cell2mat(struct2cell(load([location2, 'binned_CI_high.mat'])));
        binned_CI_low2 = cell2mat(struct2cell(load([location2, 'binned_CI_low.mat'])));
        
        bins3 = cell2mat(struct2cell(load([location3, 'bins.mat'])));
        binned_FR3 = cell2mat(struct2cell(load([location3, 'binned_FR.mat'])));
        binned_CI_high3 = cell2mat(struct2cell(load([location3, 'binned_CI_high.mat'])));
        binned_CI_low3 = cell2mat(struct2cell(load([location3, 'binned_CI_low.mat'])));
        
        bins4 = cell2mat(struct2cell(load([location4, 'bins.mat'])));
        binned_FR4 = cell2mat(struct2cell(load([location4, 'binned_FR.mat'])));
        binned_CI_high4 = cell2mat(struct2cell(load([location4, 'binned_CI_high.mat'])));
        binned_CI_low4 = cell2mat(struct2cell(load([location4, 'binned_CI_low.mat'])));
        maxval = max(abs([binned_CI_high1(:,i); binned_CI_high2(:,i);binned_CI_high3(:,i);binned_CI_high4(:,i)]));
        %% Polar Tuning curves
        %{ 
        p = polar(repmat(bins1,2,1), maxval*ones(length(repmat(bins1,2,1)),1));
        set(p, 'Visible', 'off');
        hold on
        
        % plot tuning curve
        leg1 = plot(repmat(bins1,2,1),repmat(binned_FR1(:,i),2,1), 'b');
        % plot confidence intervals 
        th_fill = [flipud(bins1); bins1(end); bins1(end); bins1];
        r_fill = [flipud(binned_CI_high1(:,i)); binned_CI_high1(end,i); binned_CI_low1(end,i); binned_CI_low1(:,i)];
        [x_fill,y_fill] = pol2cart(th_fill,r_fill);
        patch(x_fill,y_fill,[0 0 1],'facealpha',0.3,'edgealpha',0, 'facecolor', 'b');
        
        % plot tuning curve
        leg2 = plot(repmat(bins2,2,1),repmat(binned_FR2(:,i),2,1), 'r');
        % plot confidence intervals 
        th_fill = [flipud(bins2); bins2(end); bins2(end); bins2];
        r_fill = [flipud(binned_CI_high2(:,i)); binned_CI_high2(end,i); binned_CI_low2(end,i); binned_CI_low2(:,i)];
        [x_fill,y_fill] = pol2cart(th_fill,r_fill);
        patch(x_fill,y_fill,[0 0 1],'facealpha',0.3,'edgealpha',0, 'facecolor', 'r');
        
        % plot tuning curve
        leg3 = plot(repmat(bins3,2,1),repmat(binned_FR3(:,i),2,1), 'g');
        % plot confidence intervals 
        th_fill = [flipud(bins3); bins3(end); bins3(end); bins3];
        r_fill = [flipud(binned_CI_high3(:,i)); binned_CI_high3(end,i); binned_CI_low3(end,i); binned_CI_low3(:,i)];
        [x_fill,y_fill] = pol2cart(th_fill,r_fill);
        patch(x_fill,y_fill,[0 0 1],'facealpha',0.3,'edgealpha',0, 'facecolor','g');
        
        % plot tuning curve
        leg4 = plot(repmat(bins4,2,1),repmat(binned_FR4(:,i),2,1), 'k');
        % plot confidence intervals 
        th_fill = [flipud(bins4); bins4(end); bins4(end); bins4];
        r_fill = [flipud(binned_CI_high4(:,i)); binned_CI_high4(end,i); binned_CI_low4(end,i); binned_CI_low4(:,i)];
        [x_fill,y_fill] = pol2cart(th_fill,r_fill);
        patch(x_fill,y_fill,[0 0 1],'facealpha',0.3,'edgealpha',0, 'facecolor', 'k');
        

        
        %}
        %% Cartesian Tuning curves
                % plot tuning curve
                hold on
        leg1 = plot(linspace(-3/4*pi, pi, 8),binned_FR1(:,i), 'b');
        % plot confidence intervals 
        th_fill = [flipud(bins1); bins1(end); bins1(end); bins1];
        r_fill = [flipud(binned_CI_high1(:,i)); binned_CI_high1(end,i); binned_CI_low1(end,i); binned_CI_low1(:,i)];
        x_bar = [flipud(th_fill(1:8));th_fill(1:8) ];
        y_bar = [binned_CI_low1(1,i);binned_CI_low1(2,i);binned_CI_low1(3,i);binned_CI_low1(4,i);binned_CI_low1(5,i);binned_CI_low1(6,i);binned_CI_low1(7,i);binned_CI_low1(8,i);binned_CI_high1(8,i);binned_CI_high1(7,i);binned_CI_high1(6,i);binned_CI_high1(5,i);binned_CI_high1(4,i);binned_CI_high1(3,i);binned_CI_high1(2,i);binned_CI_high1(1,i)];
        [x_fill,y_fill] = pol2cart(th_fill,r_fill);
        patch(x_bar ,y_bar,[0 0 1],'facealpha',0.3,'edgealpha',0, 'facecolor', 'b');
        
        
                % plot tuning curve
        leg2 = plot(linspace(-3/4*pi, pi, 8),binned_FR2(:,i), 'r');
        % plot confidence intervals 
        th_fill = [flipud(bins2); bins2(end); bins2(end); bins2];
        r_fill = [flipud(binned_CI_high2(:,i)); binned_CI_high2(end,i); binned_CI_low2(end,i); binned_CI_low2(:,i)];
        x_bar = [flipud(th_fill(1:8));th_fill(1:8) ];
        y_bar = [binned_CI_low2(1,i);binned_CI_low2(2,i);binned_CI_low2(3,i);binned_CI_low2(4,i);binned_CI_low2(5,i);binned_CI_low2(6,i);binned_CI_low2(7,i);binned_CI_low2(8,i);binned_CI_high2(8,i);binned_CI_high2(7,i);binned_CI_high2(6,i);binned_CI_high2(5,i);binned_CI_high2(4,i);binned_CI_high2(3,i);binned_CI_high2(2,i);binned_CI_high2(1,i)];
        [x_fill,y_fill] = pol2cart(th_fill,r_fill);
        patch(x_bar ,y_bar,[0 0 1],'facealpha',0.3,'edgealpha',0, 'facecolor', 'r');
        
        
                % plot tuning curve
        leg3 = plot(linspace(-3/4*pi, pi, 8),binned_FR3(:,i), 'g');
        % plot confidence intervals 
        th_fill = [flipud(bins3); bins3(end); bins3(end); bins3];
        r_fill = [flipud(binned_CI_high3(:,i)); binned_CI_high3(end,i); binned_CI_low3(end,i); binned_CI_low3(:,i)];
        x_bar = [flipud(th_fill(1:8));th_fill(1:8) ];
        y_bar = [binned_CI_low3(1,i);binned_CI_low3(2,i);binned_CI_low3(3,i);binned_CI_low3(4,i);binned_CI_low3(5,i);binned_CI_low3(6,i);binned_CI_low3(7,i);binned_CI_low3(8,i);binned_CI_high3(8,i);binned_CI_high3(7,i);binned_CI_high3(6,i);binned_CI_high3(5,i);binned_CI_high3(4,i);binned_CI_high3(3,i);binned_CI_high3(2,i);binned_CI_high3(1,i)];
        [x_fill,y_fill] = pol2cart(th_fill,r_fill);
        patch(x_bar ,y_bar,[0 0 1],'facealpha',0.3,'edgealpha',0, 'facecolor', 'g');
        
        leg4 = plot(linspace(-3/4*pi, pi, 8),binned_FR4(:,i), 'k');
        % plot confidence intervals 
        th_fill = [flipud(bins4); bins4(end); bins4(end); bins4];
        r_fill = [flipud(binned_CI_high4(:,i)); binned_CI_high4(end,i); binned_CI_low4(end,i); binned_CI_low4(:,i)];
        x_bar = [flipud(th_fill(1:8));th_fill(1:8) ];
        y_bar = [binned_CI_low4(1,i);binned_CI_low4(2,i);binned_CI_low4(3,i);binned_CI_low4(4,i);binned_CI_low4(5,i);binned_CI_low4(6,i);binned_CI_low4(7,i);binned_CI_low4(8,i);binned_CI_high4(8,i);binned_CI_high4(7,i);binned_CI_high4(6,i);binned_CI_high4(5,i);binned_CI_high4(4,i);binned_CI_high4(3,i);binned_CI_high4(2,i);binned_CI_high4(1,i)];
        [x_fill,y_fill] = pol2cart(th_fill,r_fill);
        patch(x_bar ,y_bar,[0 0 1],'facealpha',0.3,'edgealpha',0, 'facecolor', 'k');
        xlabel('Direction (radians)');
        
        legend([leg1, leg2, leg3,leg4],'Center Out Vel PD','Chaotic Force PDs', 'Chaotic Vel PDs', 'Isometric Force Pds', 'Location', 'northoutside');
        title(sprintf('channel %d unit %d tuning plot', unit_ids(i, 1),unit_ids(i, 2)));
        s=sprintf('channel_%d_unit_%d_tuning_plot.png', unit_ids(i, 1),unit_ids(i, 2));
        saveas(figure(i),s);
        
end
