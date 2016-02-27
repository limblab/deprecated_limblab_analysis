function new_ind = relabel_markers(x,y,z)

    %     axis([min(x(:)) max(x(:)) min(y(:)) max(y(:))])
    npoints = length(x);
    plot(x,y)
    for kk = 1:npoints
        h(kk) = text(x(kk),y(kk),z(kk),num2str(kk));
    end
    
    jj = 0; bad_frame = 0; ok_as_is = 0;
    while (~bad_frame) & (jj < npoints) & (~ok_as_is)
        jj = jj+1;
%         disp(['choose point # ' num2str(jj)])
        [mx,my,button] = ginput(1);
        if button > 1
            bad_frame = 1;
            new_ind = NaN*(1:npoints);
        elseif isempty(button)
            ok_as_is = 1;
            new_ind = 1:npoints;
        else
            for ii = 1:npoints
                dist(ii) = sqrt(sum(([mx my] - [x(ii) y(ii)]).^2));
            end
            [mn,ind] = min(dist);
            h2 = text(x(ind),y(ind),z(ind),num2str(jj));
            set(h2,'Color',[1 0 0])
            delete(h(ind))
            new_ind(jj) = ind;
        end 
    end

    if ~bad_frame
        plot(x(new_ind),y(new_ind))
        for jj = 1:npoints
            text(x(new_ind(jj)),y(new_ind(jj)),z(new_ind(jj)),num2str(jj))
        end
    end