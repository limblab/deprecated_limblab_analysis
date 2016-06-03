function boundary=close_polygon(boundary)
    %takes pairings of x-y points defining a line and converts into a
    %closed polygon. If self intersections in the line exist the first
    %self-intersection will defind the closure point, otherwise, the first
    %and last points will be joined.
    
    %get self intersections
    [x0,y0,segments]=selfintersect(boundary(:,1),boundary(:,2));
    if ~isempty(segments) %if we have intersections:
        %use number of points in the segment as a proxy for area enclosed
        %and select the loop with the graetest area
        ind=[1;segments(:,1); segments(1,2)];%we know th intersection is with the last segment because we added that segment to create the intersection
        [Y,ind2]=max(diff(ind));
        boundary=[boundary(ind(ind2):ind(ind2+1),:);boundary(ind(ind2),:)];
    else %if we have no intersections
        %append the closing point and re-check for intersections
        boundary=[boundary;boundary(1,:)];
        [x0,y0,segments]=selfintersect(boundary(:,1),boundary(:,2));
        if isempty(segments)%our closing segment did not generate intersections
            return
        else
            %use number of points in the segment as a proxy for area enclosed
            %and select the loop with the graetest area
            ind=[1;segments(:,1); segments(1,2)];%we know th intersection is with the last segment because we added that segment to create the intersection
            [Y,ind2]=max(diff(ind));
            boundary=[boundary(ind(ind2):ind(ind2+1),:);boundary(ind(ind2),:)];
        end
    end
end