norm_side = 50; % pixels?

% % test_side_ratio_1 = .8;
% test_side_ratio_1 = 0.5+rand;
% % test_side_ratio_2 = 1.2;
% test_side_ratio_2 = 0.5+rand;
% step_size = .5;
% trial = 0;
% response_vector = ones(1,20);
% response_vector(1:10) = 0;
% response_vector(randperm(20)) = response_vector;
% ratio_vector = 0.5+rand(1,20);
% % ratio_vector(1:2:end) = test_side_ratio_1;
% % ratio_vector(2:2:end) = test_side_ratio_2;
% response_l_or_r = 0.5*ones(1,20);
% correct_l_or_r = zeros(1,20);

fit_func = 'Pmin + (Pmax - Pmin)/(1+exp(beta*(xthr-x)))';
f_sigmoid = fittype(fit_func,'independent','x');
f_opts = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1 0 0.1 1],...
    'MaxFunEvals',10000,'MaxIter',1000,'Lower',[0.9 0 0 0],'Upper',[1 0.1 1000 2]);
trial = 0;
for i=1:20
    figure(1)
    trial = trial+1;
%     if mod(trial,2)== 1
        test_side_ratio = test_side_ratio_1;
%     else
%         test_side_ratio = test_side_ratio_2;
%     end
    test_side_ratio = max(min(test_side_ratio,2),.5);
    big_square_side = 2*(rand>0.5)-1;
    if test_side_ratio > 1
        big_square_size = norm_side*test_side_ratio;
        small_square_size = norm_side;
    else
        big_square_size = norm_side;
        small_square_size = norm_side*test_side_ratio;
    end
    clf    
    xlim([-3*norm_side 3*norm_side])
    axis square
    axis equal
    set(gca,'XTick',[],'YTick',[],'Box','off')
    drawnow
    pause(.5)
    
    %Big square
    rectangle('Position',[(-(big_square_side==-1)*2+(big_square_side==1))*big_square_size...
        -big_square_size/2 big_square_size big_square_size],'FaceColor','b');
    
    %Small square
    rectangle('Position',[(-(big_square_side==1)*2+(big_square_side==-1))*small_square_size...
        -small_square_size/2 small_square_size small_square_size],'FaceColor','b');
    response = '';
    while ~(strncmp('q',response,1) || strncmp('w',response,1))
        response = input('Bigger? Left(q) or Right(w)? ','s');
    end

    response_vector(trial) = (response=='q' && big_square_side == -1) || ...
        (response=='w' && big_square_side == 1);
    response_l_or_r(trial) = 2*(response=='w')-1;
    correct_l_or_r(trial) = big_square_side;
    
    ratio_vector(trial) = test_side_ratio;

%     if length(response_vector)>10
        
%         nshift = sum(abs(diff(response_vector~=0)));
        response_sigmoid_data = response_vector & ratio_vector>1 | ~response_vector & ratio_vector<1;
        figure(2); 
        clf
        plot(ratio_vector,response_sigmoid_data,'.')
        sigmoid = fit(ratio_vector',response_sigmoid_data',f_sigmoid,f_opts);
        hold on
        plot(sigmoid)
        legend off
%         xlim([0.8 1.2])
        sigmoid
        jnd = [(sigmoid.beta*sigmoid.xthr+log(2-sqrt(3)))/sigmoid.beta (sigmoid.beta*sigmoid.xthr+log(2+sqrt(3)))/sigmoid.beta];
        plot(jnd,[.5 .5],'-')
%     else
%         nshift = 2;
%     end
%     if mod(trial,2)==1
        if test_side_ratio > 1
            nshift = max(sum((diff(response_vector(ratio_vector>1)~=0))),2);
            nshift = sum(abs(diff(response_vector(ratio_vector>1))));
            test_side_ratio_1 = test_side_ratio - (step_size)/(1+nshift)*(response_vector(trial)-0.5) +rand*.1*step_size-.05*step_size;
        else
            nshift = max(sum((diff(response_vector(ratio_vector<1)~=0))),2);
            nshift = sum(abs(diff(response_vector(ratio_vector<1))));
            test_side_ratio_1 = test_side_ratio + (step_size)/(1+nshift)*(response_vector(trial)-0.5) +rand*.1*step_size-.05*step_size;
        end
%         nshift = max(sum((diff(response_vector~=0))),2);
        
%     else
%         test_side_ratio_2 = test_side_ratio - (2*(test_side_ratio<1)-1)*(step_size+0.02*rand)/(nshift-1)*(2*response_vector(trial)-1);
%     end
end

response_sigmoid_data = response_vector & ratio_vector>1 | ~response_vector & ratio_vector<1;
figure(2); 
plot(ratio_vector,response_sigmoid_data,'.')
sigmoid = fit(ratio_vector',response_sigmoid_data',f_sigmoid,f_opts);
hold on
plot(sigmoid)
legend off
xlim([0.8 1.2])
sigmoid
jnd = [(sigmoid.beta*sigmoid.xthr+log(2-sqrt(3)))/sigmoid.beta (sigmoid.beta*sigmoid.xthr+log(2+sqrt(3)))/sigmoid.beta];
plot(jnd,[.5 .5],'-')

