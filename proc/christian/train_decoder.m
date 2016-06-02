
function W_final = train_decoder(inputs,outputs,num_lags,lambda)
tstart = tic;
inputs = DuplicateAndShift(inputs,num_lags);
num_out = size(outputs,2);

mx = mean(inputs); my = mean(outputs);
inputs = detrend(inputs,'constant'); outputs = detrend(outputs,'constant');
W_init = inputs\outputs;

% W_init_nul = zeros(size(inputs,2),num_out);
TolW     = mean(abs(W_init(2:end))/100); %function search tolerance at 1% of average weight value
TypicalW = mean(abs(W_init),2);
TolFun   = TolW; %tolerance on cost function? not exactly sure what this should be

fmin_options = optimoptions('fminunc','GradObj','on','Display','final-detailed',...
                    'TolX',TolW,'TolFun',TolFun,'TypicalX',TypicalW);
W_final = nan(size(W_init)+[1,0]);

for out = 1:num_out
    fprintf('training decoder for output %d of %d\n',out,num_out);
    tic;
    [W_final(2:end,out),fmin_val,exit_flag,fmin_output,final_grad] = fminunc(@(W) min_weights(inputs,outputs(:,out),W,lambda),W_init(:,out),fmin_options);

    %first weight for offsets to account for detrending
    W_final(1,out) = -sum(mx'.*W_final(2:end,out)) + my(out);   
    fprintf('decoder training time output %d: %.1f\n',out,toc);    
end
fprintf('total decoder training time: %.1f\n',toc(tstart));
end