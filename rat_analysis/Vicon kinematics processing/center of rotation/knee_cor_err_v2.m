function E = knee_cor_err_v2(cor,pts)

nframes = size(pts,1);
npts = size(pts,2);
ndim = size(pts,3);

% go through each combination of points at each separate frame

for ii = 1:nframes
    points_in_frame = squeeze(pts(ii,:,:));
    nn = 1;
    for jj = 1:npts
        jjth_point = points_in_frame(jj,:);
        v1 = cor-jjth_point;
        mag1 = norm(v1);
        for kk= (jj+1):npts
            kkth_point = points_in_frame(kk,:);
            v2 = cor-kkth_point;
            mag2 = norm(v2);
            proj(nn) = v1*v2'/(mag1*mag2);
            nn = nn+1;
        end
    end
    allproj(ii,:) = proj;    
end
       
E = sum(var(allproj))*100000;




