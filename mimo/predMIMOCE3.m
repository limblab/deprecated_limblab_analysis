function preds = predMIMOCE3(inputs,H,varargin)

[numpts,Nin]=size(inputs);
[rowH,Nout]=size(H);
numlags = floor(rowH/Nin);

preds = zeros(numpts,Nout);

tmp_in = zeros(numlags,Nin);

for o = 1:Nout
    for p = 1:numpts
        tmp_in = [inputs(p,:); tmp_in(1:end-1,:)];
        if mod(rowH,Nin)
            preds(p,:) = [1 tmp_in(:)']*H;
        else
            preds(p,:) = tmp_in(:)'*H;
        end
    end
end