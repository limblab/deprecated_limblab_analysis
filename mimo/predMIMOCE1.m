function Outputs = predMIMOCE1(Inputs,H,numlags)

[numpts,Nin]=size(Inputs);
[rowH]=size(H,1);

if Nin ~= rowH
    %Inputs have to be duplicated and shifted according to numlags
    Inputs = DuplicateAndShift(Inputs,numlags);
end

% Outputs = zeros(numpts,Nout);
% for out = 1:Nout
%     Outputs(:,out) = spikes_lag*H(:,out);
% end

Outputs = Inputs*H;
%discard the first numlags-1 points because they are garbage:
Outputs = Outputs(numlags:end,:);