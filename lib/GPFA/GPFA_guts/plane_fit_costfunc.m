function [d] = plane_fit_costfunc(dar,n,p0)

% Concatenate all trajectories
darcat = reshape(dar,size(dar,1)*size(dar,2),3);
% Create class tags for each point
tags = reshape(repmat(1:size(dar,1),size(dar,2),1),numel(dar(:,:,1)),1);
tagsrep = repmat(tags,1,2);

% Projection from point P to plane specified by orthogonal vector n and point p0
nrep = repmat(n,size(darcat,1),1);
p0rep = repmat(p0,size(darcat,1),1);
proj_func_all = @(P,nrep,p0rep) [P(:,1) - nrep(:,1).*(sum(nrep.*P,2)-sum(nrep.*p0rep,2))./(sum(nrep.^2,2)),...
                   P(:,2) - nrep(:,2).*(sum(nrep.*P,2)-sum(nrep.*p0rep,2))./(sum(nrep.^2,2)),...
                   P(:,3) - nrep(:,3).*(sum(nrep.*P,2)-sum(nrep.*p0rep,2))./(sum(nrep.^2,2))];

proj_points = proj_func_all(darcat,nrep,p0rep);

N = size(proj_points,1);
origin = proj_points(1,:);
localz = cross(proj_points(2,:)-origin, proj_points(3,:)-origin);
unitz = localz/norm(localz,2);
localx = proj_points(2,:)-origin;
unitx = localx/norm(localx,2);
localy = cross(localz, localx);
unity = localy/norm(localy,2);
T = [localx(:), localy(:), localz(:), origin(:); 0 0 0 1];
C = [proj_points, ones(N,1)];
proj_2d = T \ C';
proj_2d = proj_2d(1:2,:)';

%cust_dist_func = @(X,Y) sum((X(1:3)-Y(1:3)).^2).*(-1 + 2*(X(end)==Y(end)));

dists = pdist(proj_2d,'euclidean');
%dists = pdist(proj_points,'euclidean');
sqr_dists = dists.^2;

tagdists = pdist(tagsrep,'euclidean');
class_multiplier = -1 + (1)*(tagdists==0);

d = sum(sqr_dists.*class_multiplier);
