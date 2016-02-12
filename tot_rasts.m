function tot_rasts(bdf)

pd_array = zeros(length(bdf.units),2);

for i = 1:length(bdf.units)
    chan = bdf.units(i).id(1);
    unit = bdf.units(i).id(2);
    b = glm_kin(bdf,chan,unit,0);
    prefd = atan2(b(5),b(4));
    pd_array(i,1) = prefd;
    pd_array(i,2) = i;
    clear chan; clear unit; clear b; clear prefd;
end

pd_array = sortrows(pd_array,1);

cotable = co_trial_table(bdf);

reaches = cell(4,1);
bumps = cell(4,1);
hists = cell(length(bdf.units),8);
tot_hists = cell(8,1);

for i = 1:4
    reaches{i} = cotable(cotable(:,5)==(i-1),8);
    bumps{i} = cotable(cotable(:,2)==(i-1),4);
end

reach_rasters = cell(4,1);
bump_rasters = cell(4,1);

for i = 1:length(bdf.units)
    for j = 1:4
        [~,reach_rasters{i,j}] = raster(bdf.units(i).ts,reaches{j},-0.125,0.25,-1);
        [~,bump_rasters{i,j}] = raster(bdf.units(i).ts,bumps{j},-0.125,0.25,-1);
    end
end

for i = 1:length(bdf.units)
    for j = 1:4
        hists{i,j} = hist(reach_rasters{pd_array(i,2),j},(250+125)/5);
        if size(hists{i,j},2) == 1
            hists{i,j} = hists{i,j}';
        end
        hists{i,j+4} = hist(bump_rasters{pd_array(i,2),j},(250+125)/5);
        if size(hists{i,j+4},2) == 1
            hists{i,j+4} = hists{i,j+4}';
        end
    end
end


for i = 1:8
    tot_hists{i} = vertcat(hists{:,i});
    figure; pcolor(tot_hists{i});
end
