function [L_final, mdl, success] = fit_model(bdf, chan, unit, offset)

    offset = floor(1000 * offset);

    t = bdf.vel(:,1);
    s = train2bins(get_unit(bdf,chan,unit), t);
    
    if offset > 0
        s = [s(offset+1:end) s(1:offset)];
    elseif offset < 0
        offset = -offset;
        s = [s(end-offset:end) s(offset-1:end-offset-1)];
    end
    
    %a_norm = sqrt(bdf.acc(:,2).^2 + bdf.acc(:,3).^2);
    %kin = [ones(length(bdf.vel),1) bdf.pos(:,2:3) ...
    %       bdf.vel(:,2:3) v_norm bdf.acc(:,2:3) a_norm];
    %kin = [ones(length(bdf.vel),1) bdf.pos(:,2:3) bdf.vel(:,2:3) v_norm];
    
    v_norm = sqrt(bdf.vel(:,2).^2 + bdf.vel(:,3).^2);
    kin = [ones(length(bdf.vel),1) bdf.vel(:,2:3) v_norm];
    
    %x = bdf.pos(:,2:3);
    %x = x - repmat(mean(x), size(x,1), 1);
    %kin = [ones(length(bdf.vel),1) x];
    
    options.Display = 'off';
    options.TolFun = 1e-9;
    alpha_0 = [15 zeros(1,size(kin,2)-1)];
    [mdl, L_final, success] = fminsearch( @likelihood , alpha_0 , options );

    function L = likelihood(alpha)
       lambda = alpha * kin';
       lambda = lambda ./ 1000;
       L = sum(log(lambda(s ~= 0))) - sum(lambda);
       L = log(real(L));
    end

end