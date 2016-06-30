function [markers,X,paramOUT] = spherical_fit(dataset,numMarkers,markers,trueparam)

% Number of frames to use
N = size(markers,1);
switch lower(dataset)
    case {'vicon'}
        % Initial guess for joint center coordinates and radii to each marker -
        % Approximated from 3D plot of marker positions to improve speed of
        % algorithm.
        jntCtr = [-160; 100; 95];

    case {'simulated'}
        % Initial guess for joint center coordinates and radii to each marker -
        % Approximated from 3D plot of marker positions to improve speed of
        % algorithm.
        jntCtr = (50*(rand-0.5))+trueparam(1,:)';
        jntCtr = [-4.9994   35.8283  -11.4014]';
end

% Find COR use spherical fit method

% Randomly assign values to represent radii from COR to markers
radii = 100*rand(numMarkers,1); %[80; 50; 33; 27];

% Combine parameters into an initial guess for optimization
Xo = [jntCtr; radii];

% Initialize RMS errors and counter
rmserr_OLD = CORfun(Xo,markers,numMarkers);
rmserr_DIFF = 1; count = 1;

% Continue updating the parameter estimates until error falls below
% threshold
% while rmserr_DIFF > 0.1
    % Use fminsearch to optimze these 7 parameters
    options = optimset('MaxFunEvals',2e3);
    X = fminsearch(@(x)CORfun(x,markers,numMarkers),Xo,options);

    % Compute error
    err = CORfun(X,markers,numMarkers);
    rmserr = sqrt(err/numMarkers/N);
    fprintf('\nRMS error (Iter %g) between XYZ of %g markers and COR is %g\n\n',count,numMarkers,rmserr);
    
    % Update counter
    count = count + 1;
    
    % Assign solution from this iteration as the initial guess for the next
    % iteration of the spherical fit algorithm
    Xo = X;
    
    % Compute the difference in RMS error from this iteration and the last
    % iteration.  This is used to end the algorithm if it falls below a
    % threshold.
    rmserr_DIFF = abs(rmserr - rmserr_OLD);
    
    % Assign current RMS error to OLD RMS error
    rmserr_OLD = rmserr;
% end


% Plot data again with COR labeled
plot_data_3d(markers,[],numMarkers);
plot3(X(1),X(2),X(3),'kx','MarkerSize',32)
hold off;
title('3D data with COR labeled (RED = predicted, BLK = actual)')

% Compare the predicted radii and VICON radii
xyzCOR = repmat(X(1:3),1,N)';

% Initialize variables to computer VICON radii
framebyframeR = zeros(N,numMarkers);
for hh = 1:numMarkers
    % Compute frame-by-frame radii to each marker from VICON data using COR
    % estimate from above
    framebyframeR(:,hh) = sqrt(sum((markers(:,(hh-1)*3+1:hh*3) - xyzCOR).^2,2));
end

switch lower(dataset)
    case {'vicon'}
        % Measured XYZ data from metal grid
        measXYZ = [0.25   1.5    0;
                   0.25   2.3125 0;
                   1.0625 1.6250 0;
                   2.0625 2.0625 0;
                   3.75   1.5625 0;
                   2.1875 0.5625 0;
                   2.1875 0.5625 0;
                   2.1875 0.5625 0;
                   2.1875 0.5625 0;
                   2.1875 0.5625 0;
                   ];
       
        % Compute measured radii
        measCOR = [0 0 -4.22/2.54];
        measR = 25.4*sqrt(sum((measXYZ(1:numMarkers,:)-repmat(measCOR,numMarkers,1)).^2,2));

    case {'simulated'}
        measXYZ = trueparam(2:end,:);
        measCOR = trueparam(1,:);

        % Compute measured radii
        measR = sqrt(sum((measXYZ(1:numMarkers,:)-repmat(measCOR,numMarkers,1)).^2,2));
end
paramOUT.measXYZ = measXYZ;
paramOUT.measCOR = measCOR;
paramOUT.measRAD = measR;

% Plot results
time = (1:N)/100;
colors = {'b','r','g','k','m','c','y','b','r','g','k'};
figure;
for jj = 1:numMarkers
    % Plot radii
    plot(time,framebyframeR(:,jj),colors{jj},'LineWidth',2)
    hold on;
    plot(time,repmat(X(jj+3),N,1),colors{length(colors)-jj+1},'LineStyle','-.','LineWidth',2)
%     plot(time,repmat(measR(jj),N,1),colors{jj},'LineWidth',3)
    title('Comparison of frame-by-frame radii (solid) and predicted radii (square)')
end
paramOUT.frameR = framebyframeR;



