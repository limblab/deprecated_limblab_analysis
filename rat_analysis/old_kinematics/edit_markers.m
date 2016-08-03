function [xnew,ynew,znew] = edit_markers(x,y,z)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

npoints = size(x,2);
nsamples = size(x,1);
xtemp = x; ytemp = y; ztemp = z;  % preserve the positions without zero meaning
xcent = x - repmat(mean(x,2),1,npoints);  % the centered positions for each point
ycent = y - repmat(mean(y,2),1,npoints);
zcent = z - repmat(mean(z,2),1,npoints);
new_ind = relabel_markers(xcent(1,:),ycent(1,:),zcent(1,:));
xref = xcent(1,new_ind);
yref = ycent(1,new_ind);
zref = zcent(1,new_ind);
xnew(1,:) = xref;
ynew(1,:) = yref;
znew(1,:) = zref;

plot([min(x(:)) max(x(:)) min(x(:)) max(x(:))],[min(y(:)) min(y(:)) max(y(:)) max(y(:))],'.');
% axis([min(x(:)) max(x(:)) min(y(:)) max(y(:))])
axis('equal')
ax = axis;

for jj = 2:nsamples    
    for ii = 1:npoints  % find all distances between points
        refpoint = [xref(ii) yref(ii) zref(ii)];
        for kk = (ii):npoints
            currpoint = [xcent(jj,new_ind(kk)) ycent(jj,new_ind(kk)) zcent(jj,new_ind(kk))];
            dist(ii,kk) = sqrt(sum((refpoint - currpoint).^2));
        end
    end
    
    plot(x(jj-1,new_ind),y(jj-1,new_ind),'r')
    for kk = 1:npoints
        text(x(jj-1,new_ind(kk)),y(jj-1,new_ind(kk)),z(jj-1,new_ind(kk)),num2str(kk))
    end

%     axis([min(x(:)) max(x(:)) min(y(:)) max(y(:))])
    hold on
    plot([min(x(:)) max(x(:)) min(x(:)) max(x(:))],[min(y(:)) min(y(:)) max(y(:)) max(y(:))],'.');
    hold off
    title(jj-1)
    axis('equal')
    drawnow
    
    allind = 1:npoints;
    dist2 = dist;
    tnew_ind = new_ind;
    if max(diag(dist)) > 500
        display(['large change ' num2str(jj) ' ' num2str(max(diag(dist)))])
        hold on
        tnew_ind = relabel_markers(x(jj,:),y(jj,:),z(jj,:));
        hold off
    end
    
    if isnan(tnew_ind(1))
        xnew(jj,:) = tnew_ind;
        ynew(jj,:) = tnew_ind;
        znew(jj,:) = tnew_ind;
    else
        new_ind = tnew_ind;
        xnew(jj,:) = xtemp(jj,new_ind);
        ynew(jj,:) = ytemp(jj,new_ind);
        znew(jj,:) = ztemp(jj,new_ind);
        
        xref = xnew(jj,:) - mean(xnew(jj,:));
        yref = ynew(jj,:) - mean(ynew(jj,:));
        zref = znew(jj,:) - mean(znew(jj,:));
    end
end


    %     for ii = 1:npoints
%         [mn,ind] = min(dist2(ii,:));  % find the nearest point
%         xnew(jj,ii) = xtemp(jj,allind(ind));  % assign that in the new array
%         ynew(jj,ii) = ytemp(jj,allind(ind));
%         znew(jj,ii) = ztemp(jj,allind(ind));
%         allind = setdiff(allind,allind(ind));
%         dist2 = dist(:,allind);
%     end

