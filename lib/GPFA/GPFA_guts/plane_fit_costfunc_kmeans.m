function [d] = plane_fit_costfunc_kmeans(dar,n,p0)

% Concatenate all trajectories
darcat = vertcat(dar{:});
% Create class tags for each point
tags = cell(length(dar),1);
for i = 1:length(dar); tags{i} = i*ones(size(dar{i},1),1); end
tagscat = vertcat(tags{:});

% Projection from point P to plane specified by orthogonal vector n and point p0
nrep = repmat(n,size(darcat,1),1);
p0rep = repmat(p0,size(darcat,1),1);
proj_func_all = @(P,nrep,p0rep) [P(:,1) - nrep(:,1).*((sum(nrep.*P,2)-sum(nrep.*p0rep,2))./(sum(nrep.^2,2))),...
                   P(:,2) - nrep(:,2).*((sum(nrep.*P,2)-sum(nrep.*p0rep,2))./(sum(nrep.^2,2))),...
                   P(:,3) - nrep(:,3).*((sum(nrep.*P,2)-sum(nrep.*p0rep,2))./(sum(nrep.^2,2)))];

proj_points = proj_func_all(darcat,nrep,p0rep);

N = size(proj_points,1);
origin = proj_points(1,:);
localz = cross(proj_points(2,:)-origin, proj_points(3,:)-origin);
%unitz = localz/norm(localz,2);
localx = proj_points(2,:)-origin;
%unitx = localx/norm(localx,2);
localy = cross(localz, localx);
%unity = localy/norm(localy,2);
T = [localx(:), localy(:), localz(:), origin(:); 0 0 0 1];
C = [proj_points, ones(N,1)];
proj_2d = T \ C';
proj_2d = proj_2d(1:2,:)';

%cust_dist_func = @(X,Y) sum((X(1:3)-Y(1:3)).^2).*(-1 + 2*(X(end)==Y(end)));

tagrep = repmat(tagscat,1,length(dar));
tagsclust = nan(size(tagrep));
for i = 1:length(dar)
    tagsclust(:,i) = tagrep(:,i)==i;
end
%tagsclust(tagsclust==0)= -1;
%tagsclust(tagsclust==1)= 0;

nb = NaiveBayes.fit(proj_2d,tagscat);

post = nb.posterior(proj_2d);
classifs = nb.predict(proj_2d);

av_corr_post = mean(max(post(classifs==tagscat,:),[],2));
av_incorr_post = mean(max(post(classifs~=tagscat,:),[],2));

%d = -av_corr_post./av_incorr_post;


% 
% [classif,C,sumd,D] = kmeans(proj_2d,length(dar));
% 
% classif_rep = repmat(classif,1,length(dar));
% 
ind_classmat = repmat([1:length(dar)],length(darcat),1);

%outputs = (classif_rep==ind_classmat)';
targets = (tagrep == ind_classmat)';
outputs = post';

[tpr,fpr] = roc(targets,outputs);

d = -sum(diff(fpr{1}).*mean([tpr{1}(1:(end-1));tpr{1}(2:end)],1)).^2;

% 
% [tpr,fpr] = roc(targets,outputs);
% 
% d = -mean((classif==tagscat)); %+ mean(mean(D.*tagsclust));
% %d = sum(sum(D.*tagsclust));
% %d = -pdist(C);

