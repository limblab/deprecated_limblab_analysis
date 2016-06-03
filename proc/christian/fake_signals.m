function outputs = fake_signals()

    dim = 2;
    binsize = 0.05;
    
    sec = round(1/binsize);

    Cx8  = cross(8,8,binsize,dim,1);
    Cx4  = cross(4,2,binsize,dim,4);
    Sp8f = spiral(8,8,8,binsize,dim,1);
    Sp8s = spiral(8,4,8,binsize,dim,1);
    Sp4f = spiral(4,8,8,binsize,dim,1);
    paus1 = zeros(sec,dim);
    paus2 = zeros(2*sec,dim);
    paus3 = zeros(3*sec,dim);

    outputs = [Cx8;paus1;...
               Sp8f;paus2;...
               Cx4;paus3;
               Sp4f;paus2;
               Sp8s;paus1;
               Cx4+Sp8s;paus2;
               Cx8;paus2
               Cx8+Sp4f;paus2];
        
    outputs = repmat(outputs,100,1);
    
end
    
function outs = cross(branch_size, duration, binsize, dim, numRep)
    
    numpts         = round(duration / binsize) - mod(round(duration/binsize),2*dim);
    num_branch_pts = floor(numpts/dim);
    outs           = zeros(numpts,dim);
    
    pts_spacing = sin(0:(4/(num_branch_pts-1))*pi():pi());
    pts_spacing = pts_spacing*branch_size/sum(pts_spacing);
    
    branch_pts  = cumsum(pts_spacing);
    branch_pts  = [branch_pts branch_pts(end:-1:1)];
    branch_pts  = [branch_pts -branch_pts];
    
    %for each dim
    for i = 1:dim
        start = 1+ (i-1)*num_branch_pts;
        stop  = start + num_branch_pts -1;
        outs(start:stop,i) = branch_pts;
    end

    outs = repmat(outs,numRep,1);
    
end

function outs = spiral(radius_max, num_spins, duration, binsize, dim, numRep)

    if dim ~= 2
        error('Spiral only implemented in 2D');
    end
    
    numpts = round(duration / binsize) - mod(round(duration/binsize),2); %even number of points
    outs   = zeros(numpts,dim);

    %radius increases and decreases linearly
    rho_step = 2*radius_max/(numpts -1); 
    rho = 0:rho_step:radius_max; %first half
    rho = [rho rho(end:-1:1)];
    
    %angular speed is also constant
    theta_step = 2*pi()*num_spins/(numpts -1);
    theta = 0:theta_step:2*pi()*num_spins;
    
    outs(:,1) = rho.*cos(theta);
    outs(:,2) = rho.*sin(theta);
    
    outs = repmat(outs,numRep,1);
    
end
