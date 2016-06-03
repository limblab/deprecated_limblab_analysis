% Preferred direction distribution
function PD_distribution_plot(legend_text, table1, table2)

colors = {'b','r'};
figure;

for i=1:nargin-1
    eval(['pref_dirs = table' num2str(i) '(:,3);']);
    eval(['modulation = table' num2str(i) '(:,4);']);
    
    subplot(1,2,1)
    hold on
    plot(0,0,colors{1})
    plot(0,0,colors{2})
    legend(legend_text)
    compass(modulation.*cos(pref_dirs),modulation.*sin(pref_dirs),colors{i})
    
    subplot(1,2,2)
    hold on
    hist(180*pref_dirs/pi,18)
    if i==1
        h = findobj(gca,'Type','patch');
    else        
        h = setdiff(findobj(gca,'Type','patch'),h);
    end
    set(h,'FaceColor',colors{i},'EdgeColor','w')
    xlim([0 360])
    xlabel('Preferred directions (degrees)')
    ylabel('Count')
end