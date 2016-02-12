function opt_emgs = opt_emgs_from_traj(E2F,curs_traj,lambda)

traj     = curs_traj.mean_paths;
n_emgs = size(E2F.H,1);
[n_pts,~,n_tgts] = size(traj);

opt_emgs = nan(n_pts,n_emgs,n_tgts);

%Optimization Parameters:
TolX     = 1e-4; %function search tolerance for EMG
TypicalX = 0.1*ones(1,n_emgs);
TolFun   = 1e-4; %tolerance on cost function? not exactly sure what this should be

fmin_options = optimoptions('fmincon','GradObj','on','Display','notify-detailed',...
                            'TolX',TolX,'TolFun',TolFun,'TypicalX',TypicalX,'MaxIter',10000);

%emg bound:
emg_min = zeros(1,n_emgs);
emg_max = ones(1,n_emgs);
init_emg_val = TypicalX;

for t = 1:n_tgts
    for b = 1:n_pts
        [opt_emgs(b,:,t),~,exitflag] = fmincon(@(EMG) Force2EMG_costfun_sig(EMG,traj(b,:,t),E2F,lambda),init_emg_val,[],[],[],[],emg_min,emg_max,[],fmin_options);
        if ~exitflag
            warning('optimization failed');
            continue;
        end
    end
end