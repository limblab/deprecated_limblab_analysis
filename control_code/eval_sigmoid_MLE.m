function force = eval_sigmoid_MLE(params,xIN)

force = params(1)*[params(2) + (1-params(2))./(1 + exp(-params(3)*xIN + params(4)))];
force(xIN==0) = 0;