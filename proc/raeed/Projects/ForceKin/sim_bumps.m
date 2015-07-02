%% sim_bumps.m

ncell = 50;
ntrials = 20;
rec_len = .25; % length of sampling window in seconds

colors = {'ro','go','bo','ko','r*','g*','b*','k*'};

th = 0:pi/2:3*pi/2;
targets = [th th; th mod(th+pi,2*pi)];
ntarg = length(targets);

% Define different models to test
outer_minus = @(a,b) repmat(a,size(b,1),1) - repmat(b,1,size(a,2));
rectify = @(x) x.*(sign(x) == 1);

aligned_pd_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), cp(:,2)) );

independent_pd_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), cp(:,5)) );

PK_pd_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(2,:), cp(:,6)) );

power_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( repmat(targ(2,:) - targ(1,:), ncell , 1) );

shape1_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ).*cos( outer_minus(targ(2,:), cp(:,2)) );

shape2_mdl = @(cp, targ) repmat(cp(:,1),1,ntarg) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ) + ...
    repmat(cp(:,3),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,5)) ) + ...
    repmat(cp(:,4),1,ntarg).*cos( outer_minus(targ(1,:), cp(:,2)) ).*cos( outer_minus(targ(2,:), cp(:,5)) );

mdls = { aligned_pd_mdl, independent_pd_mdl, PK_pd_mdl, power_mdl, shape1_mdl, shape2_mdl };
mdl_names = { 'Aligned', 'Unaligned','PK', 'Power', 'CP Aligned', 'CP Unaligned' };

%% Simulate
% Generate cell parameters
% format is: [baseline pd vel_amp force_amp alt_pd PK_load_PD]
cell_params = [ 20+5*randn(ncell,1) , ...
                2*pi*rand(ncell,1)  , ... 
                10*rand(ncell,1)    , ...
                5*rand(ncell,1)     , ...
                2*pi*rand(ncell,1)  ];
            
% add load PD that is offset from velocity PD according to Prud'homme and
% Kalaska
PK_load_PD = mod(cell_params(:,2)+pi/3*randn(ncell,1),2*pi);
cell_params = [cell_params PK_load_PD];

for mdl = 1:length(mdls)
    % Get average firing rates for all cells in all targets
    % (f is ncell x ntarg matrix)
    f = mdls{mdl}(cell_params, targets);     
    % Get average spike counts
    f = f*rec_len;
    % half rectify to remove spike counts < 0
    f(f<0) = 0;

    % Generate actual spike counts for number of trials
    % s is ncell x (ntarg*ntrials) matrix
    s = poissrnd(repmat(f,1,ntrials));   

    % rearrange columns of s to be arranged at the highest level by target
    % i.e. all trials from target 1 come before all trials from target 2,
    % etc.
    % s is ncell x (ntarg*ntrials)
    p = reshape(repmat(1:ntarg,ntrials,1) + ntarg*repmat((1:ntrials)'-1,1,ntarg),1,[]);
    s = s(:,p);

    % Use factor analysis to get factor loadings and scores
    [lambda,~,~,~,F] = factoran(s'+.01*randn(size(s')),3);
    proj = lambda' * s;
    F = F';
    
    % plot factor scores for different trials, coded by target
%     figure; hold on;
%     for i = 1:ntarg
%         cur = (1:ntrials) + ntrials*(i-1);
%         plot3(F(1,cur), F(2,cur), F(3,cur), colors{i});
%         title([mdl_names{mdl}]);
%     end
    
    % cross-validate separability (num trials needs to be multiple of 10)
    rand_idx = randperm(length(p));
    slices = reshape(rand_idx,10,[]);
    
    % class is 1 for active and 0 for passive
    class = (1:length(p))<=(length(p)/2);
    for i = 1:10
        test_idx = slices(i,:);
        train_idx = reshape(slices((1:10)~=i,:),1,[]);
        
        class_train = class(train_idx);
        class_test = class(test_idx);
        
        % Use LDA to determine separability in low-D
        F_train = F(:,train_idx);
        F_test = F(:,test_idx);
        mu0 = mean(F_train(:,~class_train),2);
        mu1 = mean(F_train(:,class_train),2);
        sig0 = cov(F_train(:,~class_train)');
        sig1 = cov(F_train(:,class_train)');
        
        sig = 1/2*(sig0+sig1);
        w = sig\(mu1-mu0);
        c = 1/2*w'*(mu0+mu1);

        lda_out = (w'*F_test>c);
        sep_FA(mdl,i) = sum(lda_out==class_test)/length(class_test);

        % Use LDA to determine separability in high-D
        s_train = s(:,train_idx);
        s_test = s(:,test_idx);
        mu0 = mean(s_train(:,~class_train),2);
        mu1 = mean(s_train(:,class_train),2);
        sig0 = cov(s_train(:,~class_train)');
        sig1 = cov(s_train(:,class_train)');
        
        sig = 1/2*(sig0+sig1);
        w = sig\(mu1-mu0);
        c = 1/2*w'*(mu0+mu1);

        lda_out = (w'*s_test>c);
        sep_high(mdl,i) = sum(lda_out==class_test)/length(class_test);
    end
end

% Bar plot of separability
figure
subplot(211)
bar((1:length(mdls))',mean(sep_FA,2),0.4)
hold on
plot([0 length(mdls)+1],[0.5 0.5],'--')
% plot error bars
for i = 1:length(mdls)
    % 95% confidence intervals calculated using normal approximation to
    % binomial proportion confidence interval
    n=ntrials*ntarg;
    p=mean(sep_FA(i,:));
    if n*p>5 && n*(1-p)>5
        err = 1.96*sqrt(p*(1-p)/n);
        errorbar(i,p,err,'k')
    elseif n>30
        if p>1-p % p is approx. 1
            errorbar(i,p,3/n,1,'k')
        else % p is approx. 0
            errorbar(i,p,0,3/n,'k')
        end
    end
end
set(gca,'xtick',1:length(mdls),'xticklabel',mdl_names,'xlim',[0.6 length(mdls)+0.4],'ytick',[0 0.5 1],'ylim',[0 1],'tickdir','out','box','off')
title 'Separability in factor space'
ylabel 'Fraction Linearly Separated'

subplot(212)
bar((1:length(mdls))',mean(sep_high,2),0.4)
hold on
plot([0 length(mdls)+1],[0.5 0.5],'--')
% plot error bars
for i = 1:length(mdls)
    % 95% confidence intervals calculated using normal approximation to
    % binomial proportion confidence interval
    n=ntrials*ntarg;
    p=mean(sep_high(i,:));
    if n*p>5 && n*(1-p)>5
        err = 1.96*sqrt(p*(1-p)/n);
        errorbar(i,p,err,'k')
    elseif n>30
        if p>1-p % p is approx. 1
            errorbar(i,p,3/n,1,'k')
        else % p is approx. 0
            errorbar(i,p,0,3/n,'k')
        end
    end
end
set(gca,'xtick',1:length(mdls),'xticklabel',mdl_names,'xlim',[0.6 length(mdls)+0.4],'ytick',[0 0.5 1],'ylim',[0 1],'tickdir','out','box','off')
title 'Separability in full-dimensional space'
ylabel 'Fraction Linearly Separated'