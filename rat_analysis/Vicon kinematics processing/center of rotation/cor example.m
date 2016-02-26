clear
noise_mag = .2;   % error in mm
distance = 20;    % distance from COR in mm
inter_triad_dist = 20;
angles = -pi/3:.1:pi/3;
nframes = length(angles);
npoints = 5;
ndim = 3;

for ncond = 1
%      inter_triad_dist = ncond+1;
     for niter = 1:50
        disp(niter)
        
        step = 2*pi/npoints;
        triad_angles = (-pi+step/2):step:(pi-step/2);
        triad_x = inter_triad_dist*cos(triad_angles);
        triad_y = inter_triad_dist*sin(triad_angles);

        xoff = distance*cos(angles);
        yoff = distance*sin(angles);        
        allpoints = zeros(nframes,npoints,ndim);
        for frame = 1:nframes
            theta = angles(frame);
            R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
            new_triad = R*[triad_x; triad_y];
            new_triad(1,:) = new_triad(1,:) + xoff(frame);
            new_triad(2,:) = new_triad(2,:) + yoff(frame);
            allpoints(frame,:,1:2) = new_triad' + normrnd(0,noise_mag,size(new_triad'));
            allpoints(frame,:,3) = normrnd(0,noise_mag,npoints,1);
        end
        
        fx = @ (x)(knee_cor_err(x,allpoints));
        allknee(niter,:) = fminsearch(fx,[5,5,3]);
    end
    
    all_rms(ncond) = mean((sqrt(allknee(:,1)-0).^2 + (allknee(:,2)-0).^2));    
end
