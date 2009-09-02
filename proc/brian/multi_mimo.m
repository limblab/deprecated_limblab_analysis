% runs mimo on all possible variables

addpath ../../mimo
addpath ../../bdf
addpath ../../lib
addpath ../../spike
addpath ../..

if isfield(bdf, 'force')
    list = {'vel', 'acc', 'force'};
else
    list = {'pos', 'vel', 'acc'};
end

units = out( ~isnan(out(:,3)) , 1:2 );

means = zeros(length(list), 2);
devs = zeros(length(list), 2);
for i = 1:length(list)
    vaf = predictions(bdf, list{i}, unit_list(bdf), 10);
    means(i, :) = mean(vaf(1:end-1,:));
    devs(i,:) = sqrt(var(vaf(1:end-1,:)));
end

rmpath ../../mimo
rmpath ../../bdf
rmpath ../../lib
rmpath ../../spike
rmpath ../..