function h = BC_newsome_sigmoids_plot(bump_table,stim_table,bootstrapping_iter,filename)

fit_func = 'a+b/(1+exp(-x*c+d))';
f_sigmoid = fittype(fit_func,'independent','x');

bump_magnitudes = unique(bump_table(:,7));
bump_directions = unique(bump_table(:,6));

bumps_ordered = unique(2*[-bump_magnitudes(end:-1:1);bump_magnitudes]); %convert bumps to forces

bump_table_summary = BC_table_summary(bump_table);
stim_table_summary = BC_table_summary(stim_table);

bump_ratios = bump_table_summary(:,2)./(bump_table_summary(:,1)+bump_table_summary(:,2));
stim_ratios = stim_table_summary(:,2)./(stim_table_summary(:,1)+stim_table_summary(:,2));

 %bootstrapping
if bootstrapping_iter
    num_iter = bootstrapping_iter;    

    mean_resamp_stim = zeros(size(stim_table_summary,1),num_iter);
    mean_resamp_bump = zeros(size(bump_table_summary,1),num_iter);

    for i = 1:size(stim_table_summary,1)
        stim_results_i = [ones(stim_table_summary(i,1),1);zeros(stim_table_summary(i,2),1)];
        resamp_stim_i = stim_results_i(ceil(length(stim_results_i)*rand(length(stim_results_i),num_iter)));
        mean_resamp_stim(i,:) = mean(resamp_stim_i);
        bump_results_i = [ones(bump_table_summary(i,1),1);zeros(bump_table_summary(i,2),1)];
        resamp_bump_i = bump_results_i(ceil(length(bump_results_i)*rand(length(bump_results_i),num_iter)));
        mean_resamp_bump(i,:) = mean(resamp_bump_i);         
    end

    sigmoid_fit_bumps_boot = cell(num_iter,1);
    sigmoid_fit_stim_boot = cell(num_iter,1);
    bump_zero_crossing = zeros(num_iter,1);
    stim_zero_crossing = zeros(num_iter,1);
    bump_50_percent = zeros(num_iter,1);
    stim_50_percent = zeros(num_iter,1);
    
    for i=1:num_iter
        if i==11
            tic
        end
        if i==21
            time_10 = toc;           
        end
        if mod(i,100)==0 && i>20
            eta = ((num_iter-i)*time_10/10)/60;
            disp(['Iteration: ' num2str(i) ' of ' num2str(num_iter) '. ETA: ' num2str(eta,3) 'min'])
        end
        sigmoid_fit_bumps_boot{i} = fit(bumps_ordered,mean_resamp_bump(:,i),f_sigmoid,...
            'StartPoint',[1 -1 100 0]);
        bump_zero_crossing(i) = feval(sigmoid_fit_bumps_boot{i},0);
        bump_50_percent(i) = sigmoid_fit_bumps_boot{i}.d/sigmoid_fit_bumps_boot{i}.c;
        sigmoid_fit_stim_boot{i} = fit(bumps_ordered,mean_resamp_stim(:,i),f_sigmoid,...
            'StartPoint',[1 -1 100 0]);
        stim_zero_crossing(i) = feval(sigmoid_fit_stim_boot{i},0);
        stim_50_percent(i) = sigmoid_fit_stim_boot{i}.d/sigmoid_fit_stim_boot{i}.c;
    end

    bump_zero_crossing = sort(bump_zero_crossing);
    stim_zero_crossing = sort(stim_zero_crossing);        
    bump_zero_crossing = bump_zero_crossing(1+round(num_iter*.01):round(num_iter*.99));
    stim_zero_crossing = stim_zero_crossing(1+round(num_iter*.01):round(num_iter*.99));

    bump_50_percent = sort(bump_50_percent);
    stim_50_percent = sort(stim_50_percent);        
    bump_50_percent = bump_50_percent(1+round(num_iter*.01):round(num_iter*.99));
    stim_50_percent = stim_50_percent(1+round(num_iter*.01):round(num_iter*.99));        

    zero_crossing_bins = [min(mean(bump_zero_crossing)-3*std(bump_zero_crossing),...
        mean(stim_zero_crossing)-3*std(stim_zero_crossing)),...
        max(mean(bump_zero_crossing)+3*std(bump_zero_crossing),...
        mean(stim_zero_crossing)+3*std(stim_zero_crossing))];        
    bump_zero_crossing = bump_zero_crossing(bump_zero_crossing>zero_crossing_bins(1) &...
        bump_zero_crossing<zero_crossing_bins(2));
    stim_zero_crossing = stim_zero_crossing(stim_zero_crossing>zero_crossing_bins(1) &...
        stim_zero_crossing<zero_crossing_bins(2));
    zero_crossing_bins = linspace(zero_crossing_bins(1),zero_crossing_bins(2),50);

    fifty_percent_bins = [min(mean(bump_50_percent)-3*std(bump_50_percent),...
        mean(stim_50_percent)-3*std(stim_50_percent)),...
        max(mean(bump_50_percent)+3*std(bump_50_percent),...
        mean(stim_50_percent)+3*std(stim_50_percent))];
    bump_50_percent = bump_50_percent(bump_50_percent>fifty_percent_bins(1) &...
        bump_50_percent<fifty_percent_bins(2));
    stim_50_percent = stim_50_percent(stim_50_percent>fifty_percent_bins(1) &...
        stim_50_percent<fifty_percent_bins(2));
    fifty_percent_bins = linspace(fifty_percent_bins(1),fifty_percent_bins(2),50);
    h = figure;
    
    if num_iter>1

        subplot(4,1,1)
        hold on
        target_distance = 10;
        target_size = 3;

        xlim([-target_distance-target_size target_distance+target_size])
        ylim([-target_distance-target_size target_distance+target_size])
        set(gca,'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Visible','off')

        target_coord = [-target_size/2 -target_size/2 target_size/2 target_size/2 -target_size/2;...
            -target_size/2 target_size/2 target_size/2 -target_size/2 -target_size/2];
        area(target_coord(1,:),target_coord(2,:),'FaceColor','r','LineStyle','none')

        area(cos(bump_directions(1))*target_distance+target_coord(1,:),...
            sin(bump_directions(1))*target_distance+target_coord(2,:),'FaceColor','r','LineStyle','none')
        text(cos(bump_directions(1))*target_distance,...
            sin(bump_directions(1))*target_distance+target_size,1,'T1','Color','k','HorizontalAlignment','center')

        area(cos(bump_directions(2))*target_distance+target_coord(1,:),...
            sin(bump_directions(2))*target_distance+target_coord(2,:),'FaceColor','r','LineStyle','none')
        text(cos(bump_directions(2))*target_distance,...
            sin(bump_directions(2))*target_distance+target_size,1,'T2','Color','k','HorizontalAlignment','center')

        area(target_size/4*cos(0:.1:2*pi),target_size/4*sin(0:.1:2*pi),'FaceColor','y','LineStyle','none')
        vectarrow([0 0],[target_distance/2*cos(bump_directions(1)) target_distance/2*sin(bump_directions(1))],.1,.1,'k')
        hold on
        text(target_distance/2*cos(bump_directions(1)),target_distance/2*sin(bump_directions(1))+target_distance/5,1,...
            'Bump','HorizontalAlignment','center')

        vectarrow([-.6*target_distance target_distance],...
            [-.6*target_distance+target_distance/2*cos(bump_directions(2)) target_distance+target_distance/2*sin(bump_directions(2))],...
            .1,.1,'k')
        text(-target_distance*.8, target_distance+target_distance/5,1,'PD','HorizontalAlignment','center')

        subplot(4,1,2)
        hold on
        plot(bumps_ordered, bump_ratios,'r.','MarkerSize',10)
        plot(bumps_ordered, stim_ratios,'b.','MarkerSize',10)

        sigmoid_fit_bumps = fit(bumps_ordered,bump_ratios,f_sigmoid,...
                    'StartPoint',[1 -1 100 0]);
        sigmoid_fit_stim = fit(bumps_ordered,stim_ratios,f_sigmoid,...
                    'StartPoint',[1 -1 100 0]);

        h_temp = plot(sigmoid_fit_bumps,'r');
        set(h_temp,'LineWidth',2)

        h_temp = plot(sigmoid_fit_stim,'b');
        set(h_temp,'LineWidth',2)

        text(-.09,.85,'Bump','Color','r')
        text(-.09,.7,'Bump + ICMS','Color','b')
        legend off

        xlabel('Bump magnitude [N]')
        ylabel('P(moving to T1)')
        title(filename)

        subplot(4,2,5)          
        hold on; 
        hist(1-bump_zero_crossing,sort(1-zero_crossing_bins));
        h1 = findobj(gca,'Type','patch');
        hist(1-stim_zero_crossing,sort(1-zero_crossing_bins));        
        h2 = findobj(gca,'Type','patch');
        h2 = h2(h2~=h1);
        set(h1,'FaceColor','r','EdgeColor','r'); 
        set(h2,'FaceColor','b','EdgeColor','b'); 
    %         set(h1,'FaceColor','r','FaceAlpha',.7,'EdgeColor','r'); 
    %         set(h2,'FaceColor','b','FaceAlpha',.7,'EdgeColor','b'); 
        xlim([0.25 0.75])
        ylabel('Count'); xlabel('Null bias');
        
        subplot(4,2,6)
        hold on;
        num_samples = min(length(bump_zero_crossing),length(stim_zero_crossing));
        stim_samples = randperm(num_samples);
        bump_samples = randperm(num_samples);
        
        [temp_hist hist_bins]= hist(bump_zero_crossing(bump_samples)-...
            stim_zero_crossing(stim_samples),100);
        hist(bump_zero_crossing(bump_samples)-...
            stim_zero_crossing(stim_samples),100)
        h1 = findobj(gca,'Type','patch');
        set(h1,'FaceColor','r','EdgeColor','r'); 
        p_value = min(sum(temp_hist(hist_bins<0))/sum(temp_hist),1-sum(temp_hist(hist_bins<0))/sum(temp_hist));
        text(hist_bins(round(.75*length(hist_bins))),1.1*max(temp_hist),['p = ' num2str(p_value)])

        subplot(4,2,7)        
        hold on;        
        hist(bump_50_percent,fifty_percent_bins);
        h1 = findobj(gca,'Type','patch');
        hist(stim_50_percent,fifty_percent_bins);  
        ylabel('Count'); xlabel('PSE [N]');
        h2 = findobj(gca,'Type','patch');
        h2 = h2(h2~=h1);
        set(h1,'FaceColor','r','EdgeColor','r'); 
        set(h2,'FaceColor','b','EdgeColor','b'); 
    %         set(h1,'FaceColor','r','FaceAlpha',.7,'LineStyle','none'); 
    %         set(h2,'FaceColor','b','FaceAlpha',.7,'LineStyle','none'); 
            
        subplot(4,2,8)
        hold on;
        num_samples = min(length(bump_50_percent),length(stim_50_percent));
        stim_samples = randperm(num_samples);
        bump_samples = randperm(num_samples);
        [temp_hist hist_bins]= hist(bump_50_percent(bump_samples)-...
            stim_50_percent(stim_samples),100);
        hist(bump_50_percent(bump_samples)-...
            stim_50_percent(stim_samples),100);
        h1 = findobj(gca,'Type','patch');
        set(h1,'FaceColor','r','EdgeColor','r'); 
        p_value = min(sum(temp_hist(hist_bins<0))/sum(temp_hist),1-sum(temp_hist(hist_bins<0))/sum(temp_hist));
        text(hist_bins(round(.75*length(hist_bins))),1.1*max(temp_hist),['p = ' num2str(p_value)])
    
    else 
        subplot(2,1,1)
        hold on
        target_distance = 10;
        target_size = 3;

        xlim([-target_distance-target_size target_distance+target_size])
        ylim([-target_distance-target_size target_distance+target_size])
        set(gca,'DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Visible','off')

        target_coord = [-target_size/2 -target_size/2 target_size/2 target_size/2 -target_size/2;...
            -target_size/2 target_size/2 target_size/2 -target_size/2 -target_size/2];
        area(target_coord(1,:),target_coord(2,:),'FaceColor','r','LineStyle','none')

        area(cos(bump_directions(1))*target_distance+target_coord(1,:),...
            sin(bump_directions(1))*target_distance+target_coord(2,:),'FaceColor','r','LineStyle','none')
        text(cos(bump_directions(1))*target_distance,...
            sin(bump_directions(1))*target_distance+target_size,1,'T1','Color','k','HorizontalAlignment','center')

        area(cos(bump_directions(2))*target_distance+target_coord(1,:),...
            sin(bump_directions(2))*target_distance+target_coord(2,:),'FaceColor','r','LineStyle','none')
        text(cos(bump_directions(2))*target_distance,...
            sin(bump_directions(2))*target_distance+target_size,1,'T2','Color','k','HorizontalAlignment','center')

        area(target_size/4*cos(0:.1:2*pi),target_size/4*sin(0:.1:2*pi),'FaceColor','y','LineStyle','none')
        vectarrow([0 0],[target_distance/2*cos(bump_directions(1)) target_distance/2*sin(bump_directions(1))],.1,.1,'k')
        hold on
        text(target_distance/2*cos(bump_directions(1)),target_distance/2*sin(bump_directions(1))+target_distance/5,1,...
            'Bump','HorizontalAlignment','center')

        vectarrow([-.6*target_distance target_distance],...
            [-.6*target_distance+target_distance/2*cos(bump_directions(2)) target_distance+target_distance/2*sin(bump_directions(2))],...
            .1,.1,'k')
        text(-target_distance*.8, target_distance+target_distance/5,1,'PD','HorizontalAlignment','center')

        subplot(2,1,2)
        hold on
        plot(bumps_ordered, bump_ratios,'r.','MarkerSize',10)
        plot(bumps_ordered, stim_ratios,'b.','MarkerSize',10)

        sigmoid_fit_bumps = fit(bumps_ordered,bump_ratios,f_sigmoid,...
                    'StartPoint',[1 -1 100 0]);
        sigmoid_fit_stim = fit(bumps_ordered,stim_ratios,f_sigmoid,...
                    'StartPoint',[1 -1 100 0]);

        h_temp = plot(sigmoid_fit_bumps,'r');
        set(h_temp,'LineWidth',2)

        h_temp = plot(sigmoid_fit_stim,'b');
        set(h_temp,'LineWidth',2)

        text(-.09,.85,'Bump','Color','r')
        text(-.09,.7,'Bump + ICMS','Color','b')
        legend off

        xlabel('Bump magnitude [N]')
        ylabel('P(moving to T1)')
        title(filename)
    end
end
