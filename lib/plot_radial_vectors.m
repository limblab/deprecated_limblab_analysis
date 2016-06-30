function plot_radial_vectors(V)
% returns a figure with vectors in a cartesian plan, originating at (0,0),
% and pointing to the (x,y) coordinates provided in each column of V.
% each row in V should thus contain the x and y coordinate of a different
% vector

num_v = size(V,1);

figure;
hold on;
for v = 1:num_v
    plotLM([0 V(v,1)],[0 V(v,2)],'o-');
end