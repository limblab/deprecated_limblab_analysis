%
%

function R2_across = comp_within_cross_W_task_comp( onp_dim, neural_to_EMG_lag, lags_best_fit, varargin )


if nargin == 4
    plot_yn                 = varargin{1};
else
    plot_yn                 = false;
end


comb_tasks                  = nchoosek(1:size(onp_dim,1),2);
V_task_dimens               = size(onp_dim{1,1}.data{1}.svdec.V_task,2);

R2_across                   = cell(size(comb_tasks,1),length(lags_best_fit));


for l = 1:length(lags_best_fit)
    % get indx for this lag
    indx_this_lag           = find(neural_to_EMG_lag==lags_best_fit(l));
    % do for the last target, which is the concatenation of all
    for c = 1:size(comb_tasks,1)
        % get the projection onto W_task for this comb of tasks and lag
        within_traj         = onp_dim{comb_tasks(c,1),indx_this_lag}.data{end}.svdec.S(1:V_task_dimens,1:V_task_dimens)*...
                                onp_dim{comb_tasks(c,1),indx_this_lag}.data{end}.svdec.V_task'*...
                                onp_dim{comb_tasks(c,1),indx_this_lag}.data{end}.neural_data;
        across_traj         = onp_dim{comb_tasks(c,2),indx_this_lag}.data{end}.svdec.S(1:V_task_dimens,1:V_task_dimens)*...
                                onp_dim{comb_tasks(c,2),indx_this_lag}.data{end}.svdec.V_task'*...
                                onp_dim{comb_tasks(c,1),indx_this_lag}.data{end}.neural_data;
                            
        
        R2_across{c,l}.data = CalculateR2(within_traj',across_traj');
        
        % temp plot
        if plot_yn
            if l == 3
                figure,
                subplot(121),plot(within_traj',across_traj');
                subplot(122),hold on,plot(within_traj(1,:)','c'),plot(within_traj(2,:)','color',[.5 .5 .5])
                subplot(122),plot(across_traj(1,:)','b'),plot(across_traj(2,:)','k')
                title(['task ' num2str(comb_tasks(c,1)) ' vs. task ' num2str(comb_tasks(c,2))]) 
            end
        end
    end
end