function [allx, ally, allz] = recalculate_knee(allx,ally,allz,real_links)


HIP = 3;
KNEE = 4;
ANKLE = 5;
new_knee = [0 0 0];
warning('off')
for ii = 1:length(allx)
    disp(['frame: ' num2str(ii)])
    points = [allx(ii,[HIP KNEE ANKLE]); ally(ii,[HIP KNEE ANKLE]); allz(ii,[HIP KNEE ANKLE])]';

    % the anonymous functions for the objective and constraints
    obj_fun = @(k_pos) knee_from_plane(k_pos,points);
    constr_fun = @(k_pos) link_constr(k_pos,points,real_links);
        
    optimopts = optimset(@fmincon);
    optimopts.MaxFunEvals = 10000;
    optimopts.TolX = 1e-8;
    optimopts.TolFun = 1e-8;
    optimopts.TolCon = 1e-6;
%     optimopts.DerivativeCheck = 'on';
    optimopts.Display = 'off';
    [para,fval,exitflag,output] = fmincon(obj_fun,.1*unifrnd(-.1,.1,1,3)+points(2,:),[],[],[],[],[],[],constr_fun,optimopts);
    new_knee(ii,:) = para;    
    allflag(ii) = exitflag;
    alloutput{ii} = output;
end
warning('on')

new_knee = real(new_knee);
allx(:,KNEE) = new_knee(:,1);
ally(:,KNEE) = new_knee(:,2);
allz(:,KNEE) = new_knee(:,3);

