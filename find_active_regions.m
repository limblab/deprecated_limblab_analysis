function out = find_active_regions(bdf)

hits = bdf.words( bdf.words(:,2)==49 | bdf.words(:,2)==32 , 1);
hits = [0; hits];

breaks = find( diff(hits) > 5 );
break_starts = hits(breaks, 1);
break_ends   = hits(breaks + 1, 1);

idx = ones(1,length(bdf.vel));
break_starts = floor(1000 * break_starts + 1000);
break_ends = floor(1000 * break_ends + 1000);
for i = 1:length(break_ends)
    idx(break_starts(i):break_ends(i)) = 0;
end

out = idx==1;