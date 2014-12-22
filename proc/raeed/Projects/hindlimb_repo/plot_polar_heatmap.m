function plot_polar_heatmap(act,r,a)
% plots polar heatmap given activity vector, radius and angle
act_grid = reshape(act,length(a),length(r));

hm = HeatMap(act_grid'-mean(act),'RowLabels',r,'ColumnLabels',a,'Colormap','jet');