function [adaptC,adaptR]=adapt_kf(y,init_x,init_V,A,C,Q,R,targets,binsize,words)

% syntax [adaptC,adaptR]=adapt_kf(y,init_x,init_V,A,C,Q,R,targets,binsize,words);
%
%               INPUTS
%                       y       - neural signals
%                       init_x  - cursor position/velocity data from a BC
%                                 file (1 step of data).
%                       init_V  - initial state covariance (Q, right?)
%                       A,C,Q,R - kalman params
%                       targets - the target information from the BC file.
%                       binsize - in seconds
%                       words   - from the bdf struct
%               OUTPUTS
%                       adaptC  - modified kalman params
%                       adaptR
%
% This function processes the entire file; compare it to kalman_filter.m
% with the necessary modifications to allow it to adapt.

% 
% from predictionsfromfp6_KF.m the line of code is
%
%               [y_pred,~,~ ,~]=kalman_filter(x',A,C,Q,R,y(1,:)',Q);
%
% then T=12000 approximately.  Remember, in the kalman filter code the
% convention is that y are the observations (neural data) and x is the
% state (kinematic data).  The neural data should be passed in so that 
% it is #feat X #bins
[Nsig,T]=size(y);  % #bins, #signals
ss = size(A,1); % size of state space

% set default params
model = ones(1,T);
u = [];
B = [];
ndx = [];

% args = varargin;
% nargs = length(args);
% for i=1:2:nargs
%   switch args{i}
%    case 'model', model = args{i+1};
%    case 'u', u = args{i+1};
%    case 'B', B = args{i+1};
%    case 'ndx', ndx = args{i+1};
%    otherwise, error(['unrecognized argument ' args{i}])
%   end
% end

x = zeros(ss, T);
V = zeros(ss, ss, T);
VV = zeros(ss, ss, T);

loglik = 0;
% to accomdate Amy O's code
batch_ctr=1;
% updateFlag=0;
batch_time=80; % in seconds
C_halflife = 2; % in minutes
R_halflife = 2; % in minutes

batch_size = batch_time/(binsize);
Y_batch = nan(Nsig,batch_size);
X_batch = nan(ss,batch_size);
C_rho=exp(log(0.5)/(C_halflife*10*60/batch_size));
R_rho=exp(log(0.5)/(R_halflife*10*60/batch_size));

% time vector
binTimes=(1:T)*binsize;
% main loop from kalman_filter.m
for t=1:T
  m = model(t);
  if t==1
    %prevx = init_x(:,m);
    %prevV = init_V(:,:,m);
    prevx = init_x;
    prevV = init_V;
    initial = 1;
  else
    prevx = x(:,t-1);
    prevV = V(:,:,t-1);
    initial = 0;
  end
  if isempty(u)     % so far, we're only going to implement the adaptive version of the
                    % kalman filter for cases were there is no forcing function (input) u.

    % Amy O does the target information here, but doesn't do anything with
    % it until after calculating new kin values in the kalman update step.
    % Arguably the most important info to get is whether the cursor is in
    % the target (and therefore should be trying to hold).  Look for target
    % entry word (160 in the random walk).

    [x(:,t), V(:,:,t), LL, VV(:,:,t)] = ...
	kalman_update(A(:,:,m), C(:,:,m), Q(:,:,m), R(:,:,m), y(:,t), prevx, prevV, 'initial', initial);

    % re-aim, for adaptation.  Recall that x is the predicted pos/vel for
    % this step.
    most_recent_word=find(words(:,1)<=binTimes(t),1,'last');
    X_batch([1:2 5],batch_ctr)=x([1:2 5],t); % intended position always = actual position
    Y_batch(:,batch_ctr)=y(:,t);     % neural data is just the neural data
    if ~isempty(most_recent_word) && ...    % most_recent_word must exist.  Then,
            ((words(most_recent_word,2)==160 && words(most_recent_word-1,2)==49) || ...
            (most_recent_word >= size(words,1))) % if between 49<->160 OR if past last word...
        % intended holding.  intended velocity is zero.
        X_batch(3:4,batch_ctr)=[0 0]';
    else
        % aiming at the next target (i.e. not holding).  Currently only
        % valid for single target retraining.
        aimPos=targets(find(targets(:,1)>=binTimes(t),1,'first'),3:4);
        X_batch(3:4,batch_ctr)=bmiReaimVelHold_singleTime(x(:,t)',aimPos,0)';
    end
    
    % if we've collected enough data for a new batch update, then retrain
    % the C,R matrices.
    if batch_ctr >= batch_size
        %         updateFlag=1;
        batch_ctr=1;
        
        % adapt C
        C_hat = Y_batch*X_batch' / (X_batch*X_batch'); %MaxLikelihood-estimate of H
        C     = C_rho*C + (1-C_rho)*C_hat;             %sliding window average of H
        % adapt R
        R_hat = (Y_batch - C*X_batch)*(Y_batch - C*X_batch)' / batch_size; %MaxLikelihood-estimate of Q
        R     = R_rho*R + (1-R_rho)*R_hat;                                 %sliding window average of Q
        
        %         % store X and Y data
        %         track_X(updCnt,:,:) = X_batch;
        %         track_Y(updCnt,:,:) = Y_batch;
        
        % updCnt is only for tracking X_batch and Y_batch
        %         updCnt = updCnt+1;
        %     else
        %         updateFlag=0;
    end
  else
    if isempty(ndx)
      [x(:,t), V(:,:,t), LL, VV(:,:,t)] = ...
	  kalman_update(A(:,:,m), C(:,:,m), R(:,:,m), R(:,:,m), y(:,t), prevx, prevV, ... 
			'initial', initial, 'u', u(:,t), 'B', B(:,:,m));
    else
      i = ndx{t};
      % copy over all elements; only some will get updated
      x(:,t) = prevx;
      prevP = inv(prevV);
      prevPsmall = prevP(i,i);
      prevVsmall = inv(prevPsmall);
      [x(i,t), smallV, LL, VV(i,i,t)] = ...
	  kalman_update(A(i,i,m), C(:,i,m), R(i,i,m), R(:,:,m), y(:,t), prevx(i), prevVsmall, ...
			'initial', initial, 'u', u(:,t), 'B', B(i,:,m));
      smallP = inv(smallV);
      prevP(i,i) = smallP;
      V(:,:,t) = inv(prevP);
    end    
  end
  loglik = loglik + LL;
  % this is a departure from Amy's code.  She only advances batch_ctr "when
  % the subject is aiming somewhere".  We're going to assume, in the RW
  % task, that the subject is always aiming.  (????)
  batch_ctr=batch_ctr+1;
end

adaptC=C;
adaptR=R;