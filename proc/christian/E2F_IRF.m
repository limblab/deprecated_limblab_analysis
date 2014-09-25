E2F_irf = zeros(12,2);
EMG = zeros(100,1);
EMG(20,1) = 1;
EMG = DuplicateAndShift(EMG,10);

for i = 1:12
    F = EMG*E2F.H(2+(i-1)*10:11+(i-1)*10,:);
    for j = 1:2
        E2F_irf(i,j) = F(abs(F(:,j))==max(abs(F(:,j))),j);
    end
    plot(F);
    pause;
end
%-------------
%plot the filter:
n_lag = 10;
n_in  = size(filter.H,1)/n_lag;
n_out = size(filter.H,2);
tmp_w = nan(n_lag,n_out);
IRFm  = nan(n_in,n_out);


for i = 1:n_in
    figure;
    range = ((i-1)*n_lag +1) : i*n_lag;
    for o = 1:n_out
        tmp_w(:,o) = filter.H(range,o);
        IRFm(i,o)  = tmp_w(abs(tmp_w(:,o))==max(abs(tmp_w(:,o))),o);
    end
    plot(tmp_w);
    legend(sprintf('X: %.2f',IRFm(i,1)),sprintf('Y: %.2f',IRFm(i,2)));
    title(traindata.emgguide(i,:));
end

%---------------------
% plot the filter's spatial distribution
figure;
colors = ['b','g','r','c','m','y','k','b','g'];
n_emgs = size(E2F.H,1);

for i = 1:n_emgs
    hold on;
    plot([0 E2F.H(i,1)],[0 E2F.H(i,2)],colors(i));
end
legend({traindata.emgguide})
