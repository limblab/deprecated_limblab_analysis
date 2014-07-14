function [cost_out, cost_grad] = min_weights(inputs, outputs, W, lambda)

    cost_out = (outputs-inputs*W)'*(outputs-inputs*W) ... %minimize pred error
                + lambda*(W'*W);   %minimize weights (L2 regularization)
    cost_grad = -2*outputs'*inputs + 2*W'*(inputs'*inputs) + 2*lambda*W'; %cost gradient

end