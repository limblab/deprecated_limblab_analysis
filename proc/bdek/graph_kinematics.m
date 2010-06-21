function graph_kinematics(bdf)

FirstPlot = cell(1,length(bdf.units));

for i = 1:length(bdf.units)
    [~, p] = KLdivergence(bdf,1000,4000,i,0.05);
    FirstPlot{1,i} = p;
end

listing = vertcat(FirstPlot{:,:});
nonzero = listing(find(listing(:,3)),:);
length_nonzero = length(nonzero(:,1));
unit_indx = nonzero(:,1);

coordinates = cell(length_nonzero, 1);

for k = 0:length_nonzero-1
    [d,~] = KLdivergence(bdf,1000,4000,unit_indx(k+1,1),0.05);
    coord = [ceil((k+1)/(ceil(sqrt(length_nonzero)))) 1 + mod(k,ceil(sqrt(length_nonzero))) unit_indx(k+1, 1)];
    subplot((ceil(sqrt(length_nonzero))), (ceil(sqrt(length_nonzero))), k+1);
    plot(d(:,1),d(:,2));
    coordinates{k+1, 1} = coord;
end

headings = {'coord.' 'unit index'};
display_coord = vertcat(coordinates{:,:});
disp(headings);
disp(display_coord);

end