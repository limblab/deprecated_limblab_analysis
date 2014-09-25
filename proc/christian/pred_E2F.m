function preds = pred_E2F(EMG,H,use_sigmoid)

[numpts,Nin]=size(EMG);
[rowH,Nout]=size(H);
numlags = floor(rowH/Nin);

preds = zeros(numpts,Nout);

tmp_in = zeros(numlags,Nin);

for o = 1:Nout
    for p = 1:numpts
        tmp_in = [EMG(p,:); tmp_in(1:end-1,:)];
        if use_sigmoid
            tmp_in = sigmoid(tmp_in,'direct');
        end
        
        if mod(rowH,Nin)
            preds(p,:) = [1 rowvec(tmp_in)']*H;
        else
            preds(p,:) = rowvec(tmp_in)'*H;
        end
    end
end