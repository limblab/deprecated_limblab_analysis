function mask=is_inside(boundary,points)
    %returns a boolean mask determining whether each point in the row
    %matrix 'points' is inside the arbitrary region bounded by 'boundry'
    %works only for 2d data. Requires a closed curve, so the last point
    %should be equivalent to the first
    
    %uses a raycasting algorythm with rays cast along the y direction.
    mask=zeros(length(points(:,1)),1);
    
    %find points that have the possibility of residing inside our boundary
    p_list=find(points(:,1)>min(boundary(:,1)) & points(:,1)<max(boundary(:,1)) & points(:,2)>min(boundary(:,2)) & points(:,2)<max(boundary(:,2)));
    %loop across the points of interest and run the raycasting algorithem
    %for each
    for i=1:length(p_list)
        b_right=boundary(:,1)>points(p_list(i),1);
        b_right_diff=abs(diff(b_right));
        b_right_ind=find(b_right_diff);
        b_below=boundary(:,2)<points(p_list(i),2);
        %edge of polygon may pass above or below point only want to count
        %those cases of above, so find the below points and zero them
        for j=1:length(b_right_ind)
            if (b_below(b_right_ind(j))==1 && b_below(b_right_ind(j)+1)==1)

                %if both ends of the edge are above the point, zero it in
                %the diff vector
                b_right_diff(b_right_ind(j))=0;
            elseif mod(b_below(b_right_ind(j))+b_below(b_right_ind(j)+1),2)

                % if one point is above and one is below, figure out
                % whether the edge passes below the point and zero it
                m=(boundary(b_right_ind(j)+1,2)-boundary(b_right_ind(j),2))/(boundary(b_right_ind(j)+1,1)-boundary(b_right_ind(j),1));
                boundary_y=(boundary(b_right_ind(j),2)+(points(i,1)-boundary(b_right_ind(j),1))*m);
                if boundary_y<points(p_list(i),2)
                    b_right_diff(b_right_ind(j))=0
                end
            end
        end
        mask(p_list(i))=mod(sum(b_right_diff),2);
    end
    
end