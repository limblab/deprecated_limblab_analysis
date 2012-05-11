function out = plot_staircase(bdf)

tt = bc_trial_table(bdf);
tt = tt(tt(:,7) == double('R') | tt(:,7)==double('F'),:);


left = find(tt(:,2)==1);
right = find(tt(:,2)==0);

ly = zeros(size(left));
ry = zeros(size(right));

for i = 1:length(left)
    ly(i) = tt(left(i),3);
end

for i = 1:length(right)
    ry(i) = tt(right(i),3);
end

plot(left,ly,'b-',right,ry,'r-');

figure;
x = [left ly;right ry];
x = sortrows(x,1);
plot(x(:,1), x(:,2), 'k-')

