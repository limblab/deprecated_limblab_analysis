function frs = co_bump_rasters(bdf, res, tt)
% Draw rasters for the different bump/reach directions sorted by active PD

% get cells sorted by PD
res = batch_co_bump(bdf);
keys = sortrows(res(:,[1 2 4]),3);

% get events
tt = co_trial_table(bdf);
onsets = cell(4,2);
for dir = 0:3
    onsets{dir+1,1} = tt( tt(:,10)==double('R') & tt(:,5)==dir & tt(:,2) == -1 , 7) + .25;
    onsets{dir+1,2} = tt( tt(:,3)==double('H') & tt(:,2)==dir, 4);
end

% Build data table
frs = cell(4,2); % (4 directions x 2(active/passive))

t = -.25:.01:.5;
for dir = 1:4
    frs{dir,1} = zeros(length(keys), length(t));
    frs{dir,2} = zeros(length(keys), length(t));
    for key = 1:length(keys)
        [table{dir}, allactive] = raster(get_unit(bdf,keys(key,1), keys(key,2)), ...
            onsets{dir,1}, -.25, .5, -1);
        frs{dir,1}(key,:) = smooth(hist(allactive,t)/length(table)*100, 5);
        [table{dir}, allpassive] = raster(get_unit(bdf,keys(key,1), keys(key,2)), ...
            onsets{dir,2}, -.25, .5, -1);
        frs{dir,2}(key,:) = smooth(hist(allpassive,t)/length(table)*100, 5);        
    end
end

figure;
for dir = 1:4
    for type = 1:2
        id = 2*(dir-1) + type;
        subplot(4,2,id), pcolor(frs{dir,type});
        caxis([0 75]);
        colormap hot;
    end
end

