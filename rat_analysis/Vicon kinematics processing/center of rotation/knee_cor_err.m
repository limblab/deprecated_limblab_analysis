function E = knee_cor_err(cor,pts)

nframes = size(pts,1);
npts = size(pts,2);

ntotal = prod(1:npts)/(2*prod(1:(npts-2)));
allproj = zeros(ntotal,nframes);
n = 1;
for nn = 1:(npts-1)
        v1 = repmat(cor,nframes,1)-squeeze(pts(:,nn,:));  % from the cor to the nnth point
    for mm = (nn+1):npts
        v2 = squeeze(pts(:,nn,:))-squeeze(pts(:,mm,:));  % from the nnth to the mmth point
        for ii = 1:nframes
%             mag1 = sqrt(v1(ii,:)*v1(ii,:)');
%             mag2 = sqrt(v2(ii,:)*v2(ii,:)');
            mag1 = 1; mag2 = 1;
            proj(ii) = v1(ii,:)*v2(ii,:)'/(mag1*mag2);   % the projection from the center of rotation
        end
        allproj(n,:) = proj;
        n = n+1;
    end
end
       
E = sum(var(allproj'))*100000;




