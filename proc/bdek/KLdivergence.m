function[data, peak] = KLdivergence(bdf, samples, window, unit, block_param, graph, varargin)

if isempty(bdf.units(1,unit).ts)==1
    data = [0 0];
    peak = [0 0 0];
else

if nargin > 4
   bp = block_param;          %fraction of parameter variance. Dictates width of empty set around axes
else
   bp = 0.05;
end
tot_Q = cell(8,2);           %cell array containing all blocks. (Quadrant, direction)
Q_ind = cell(8,2);
init_p_array = cell(8,2);
p_array = cell(8,2);
D = cell(8,2);

if nargin > 2
    t_win = window;
else
    t_win = 400;        %window width of KL divergence plot (ms)
end

if nargin > 3
    u = unit;
else
    u = 1;
end

posvel = [(bdf.pos(:, 2) - mean(bdf.pos(:,2))) (bdf.pos(:, 3) - mean(bdf.pos(:,3))) bdf.vel(:,2:3)];
unit = bdf.units(1,u).ts;

%exp_spikes = (length(unit)/(bdf.meta.duration))*samples/1000;

% separate data into blocks
for i = 1:2
    tot_Q{1,i} = find((posvel(:,i)) >bp*(var(posvel(:,i))) & (posvel(:,i+2)) >bp*(var(posvel(:,i+2))));   
    tot_Q{2,i} = find((posvel(:,i)) <-bp*(var(posvel(:,i))) & (posvel(:,i+2)) >bp*(var(posvel(:,i+2))));  
    tot_Q{3,i} = find((posvel(:,i)) <-bp*(var(posvel(:,i))) & (posvel(:,i+2)) <-bp*(var(posvel(:,i+2))));   
    tot_Q{4,i} = find((posvel(:,i)) >bp*(var(posvel(:,i))) & (posvel(:,i+2)) <-bp*(var(posvel(:,i+2)))); 
    tot_Q{5,i} = find((posvel(:,i)) >bp*(var(posvel(:,i))) & (posvel(:,5-i)) >bp*(var(posvel(:,5-i))));   
    tot_Q{6,i} = find((posvel(:,i)) <-bp*(var(posvel(:,i))) & (posvel(:,5-i)) >bp*(var(posvel(:,5-i))));  
    tot_Q{7,i} = find((posvel(:,i)) <-bp*(var(posvel(:,i))) & (posvel(:,5-i)) <-bp*(var(posvel(:,5-i))));   
    tot_Q{8,i} = find((posvel(:,i)) >bp*(var(posvel(:,i))) & (posvel(:,5-i)) <-bp*(var(posvel(:,5-i))));
end

[binned_spikes] = train2bins(unit,0.001);
binned_spikes(:,1:1000) = [];

for i = 1:8
    for j = 1:2
        Q_ind{i,j} = tot_Q{i,j}(t_win/2 + ceil((length(tot_Q{i,j})-(t_win))*rand(samples,1)));
    end
end


%%%%%%%%%%%%%%%%   KL divergence  %%%%%%%%%%%%%%%%%%%%%%%

Q = 1/16;


for i = 1:8
    for k = 1:2
        init_p_array{j,k} = [];
    end
end

for j = 1:8
    for k = 1:2
        for i = -(t_win/2):(t_win/2)
            init_p_array{j,k} = [init_p_array{j,k} sum(binned_spikes(Q_ind{j,k}+i))];
        end
    end
end

tot_spikes = sum(vertcat(init_p_array{:,:}));
if length(tot_spikes) > length(find(tot_spikes))
    peak = [0 0 0];
    data = [0 0];
else

for i = 1:8
    for j = 1:2
        p_array{i,j} = init_p_array{i,j}./(tot_spikes);     
        D{i,j} = p_array{i,j} .* log2(p_array{i,j}./Q);
        D{i,j}(isnan(D{i,j})) = 0;
    end
end

K = sum(vertcat(D{:,:}));
smoothK = smooth(K,200); smoothK(1:200,:) = []; smoothK((end-200):end,:) = [];

if nargin > 5
    subplot(2,1,1); plot((-t_win/2+201:t_win/2-200),smoothK);
    subplot(2,1,2); plot((-t_win/2:t_win/2),K);
else
    coord = [(-t_win/2+201:t_win/2-200)' smoothK];
    x = coord(coord(:,2) == max(smoothK),1);
    ind = [x max(smoothK)];
    
    if ind(1,2) == 0
        peak = [0 x max(smoothK)];
        data = [0 0];
    else
        peak = [u x max(smoothK)];
        data = [(-t_win/2+201:t_win/2-200)' smoothK];
    end
   
end
end
end
end
