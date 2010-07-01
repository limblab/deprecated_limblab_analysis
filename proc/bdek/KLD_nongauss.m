function[data, peak] = KLD_nongauss(bdf, param_list,unit, samples, block_param, varargin)

% KLdivergence calculates the Kullback-Leibler divergence for a unit 
% regarding a particular set of parameters, dictated by the struct
% param_list.

p_v_a_f = [(bdf.pos(:,2)-mean(bdf.pos(:,2))), ...           % x position
           (bdf.vel(:,2)), ...                              % x velocity
           (bdf.acc(:,2)), ...                              % x accel
           (bdf.force(:,2)-mean(bdf.force(:,2))), ...       % x force
           (bdf.pos(:,3)-mean(bdf.pos(:,3))), ...           % y position
           (bdf.vel(:,3)), ...                              % y velocity
           (bdf.acc(:,3)), ...                              % y accel
           (bdf.force(:,3)-mean(bdf.force(:,3)))];          % y force
       
if nargin > 2
    u = unit;
else
    u = param_list.unit;
end

if nargin > 3
    perc_quad = samples;
else
    perc_quad = param_list.samples;
end

if nargin > 4
    bp = block_param;
else
    bp = param_list.block_param;  %fraction of parameter variance. Dictates width of empty set around axes
end

unit = bdf.units(1,u).ts;
t_win = param_list.window;    %window width of KL divergence plot (ms)


if isempty(bdf.units(1,u).ts)==1
    data = [0 0];
    peak = [0 0 0];
    disp(sprintf('unit &d is empty',u));
return
end

%%%%%%%%%%%%%%%%%%%%%%%%% check parameter list %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%sets each parameter variable (x_pos, y_pos, ...) to either 0, 1, or 2
%depending on its value in the param_list struct ('omit', 'include', 'respect')

x_pos = isequal(param_list.x_pos, 'include') + 2*isequal(param_list.x_pos, 'respect');
y_pos = isequal(param_list.y_pos, 'include') + 2*isequal(param_list.y_pos, 'respect');
x_vel = isequal(param_list.x_vel, 'include') + 2*isequal(param_list.x_vel, 'respect');
y_vel = isequal(param_list.y_vel, 'include') + 2*isequal(param_list.y_vel, 'respect');
x_acc = isequal(param_list.x_acc, 'include') + 2*isequal(param_list.x_acc, 'respect');
y_acc = isequal(param_list.y_acc, 'include') + 2*isequal(param_list.y_acc, 'respect');
x_force = isequal(param_list.x_force, 'include') + 2*isequal(param_list.x_force, 'respect');
y_force = isequal(param_list.y_force, 'include') + 2*isequal(param_list.y_force, 'respect');

tot_params = [x_pos, x_vel, x_acc, x_force y_pos, y_vel, y_acc, y_force];
        %tot_params gives a vector of 0's, 1's, and 2's defining the analysis
inc_par = find(tot_params == 1);
resp_par = find(tot_params == 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% separate data into blocks %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tot_Q = cell(8,2);            %cell array (Parameter,sign)
block_Q = cell(1,(2^length(inc_par)));
Q_ts = cell(1,(2^length(inc_par)));

for i = 1:2^length(inc_par)
    block_Q{i} = zeros(length(p_v_a_f),1);
end

for i = 1:8
    tot_Q{i,1} = p_v_a_f(:,i) > bp*var(p_v_a_f(:,i));
    tot_Q{i,2} = p_v_a_f(:,i) < bp*var(p_v_a_f(:,i));
end

[binned_spikes] = train2bins(unit,0.001);
binned_spikes(:,1:1000) = []; binned_spikes = [binned_spikes zeros(1,ceil((bdf.pos(end,1)+2-unit(end)).*1000))];

poss = [];
for a1 = 1:2
    for a2 = 1:2
        for a3 = 1:2
            for a4 = 1:2
                for a5 = 1:2
                    for a6 = 1:2
                        for a7 = 1:2
                            for a8 = 1:2
                                poss = vertcat(poss, [a1 a2 a3 a4 a5 a6 a7 a8]);
                            end
                        end
                    end
                end
            end
        end
    end
end

poss(:,1:(8-length(inc_par))) = [];
poss((2^length(inc_par))+1:256,:) = [];

for i = 1:2^length(inc_par)
    for j = 1:length(inc_par)
        block_Q{i} = block_Q{i} + tot_Q{inc_par(j),poss(i,j)};
    end
    Q_ts{i} = find(block_Q{i} == length(inc_par));
end

Q_ind = cell(1,2^length(inc_par));            %cell array containing random indices for each block

total_block = 0;
for i = 1:(2^length(inc_par))
    total_block = total_block + length(Q_ts{i});
end

sample_sum = 0;
for i = 1:(2^length(inc_par))
    num_rand = ceil(perc_quad*length(Q_ts{i}));  
    Q_ind{i} = Q_ts{i}(t_win/2 + ceil((length(Q_ts{i})-(t_win))*rand(num_rand,1)));
    sample_sum = sample_sum + length(Q_ind{i});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%   KL divergence  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Q = cell(1,2^length(inc_par));
init_p_array = cell(1,2^length(inc_par));
p_array = cell(1,2^length(inc_par));
D = cell(1,2^length(inc_par));


for i = 1:(2^length(inc_par))
    init_p_array{i} = [];
end

for j = 1:(2^length(inc_par))
    for i = -(t_win/2):(t_win/2)
        init_p_array{j} = [init_p_array{j} sum(binned_spikes(Q_ind{j}+i))];
    end
end

tot_spikes = sum(vertcat(init_p_array{:,:}));
% if length(tot_spikes) > length(find(tot_spikes))
%     peak = [0 0 0];
%     data = [0 0];
%     disp('empty time point(s)');
% return
% end



for i = 1:(2^length(inc_par))
    Q{i} = length(Q_ts{i})/total_block;
end
    
for i = 1:(2^length(inc_par))
    p_array{i} = init_p_array{i}./(tot_spikes);     
    D{i} = p_array{i} .* log2(p_array{i}./Q{i});
    D{i}(isnan(D{i})) = 0;
end

K = sum(vertcat(D{:,:}));
smoothK = smooth(K,100); 
smoothK(1:100,:) = []; 
smoothK((end-100):end,:) = [];

if isequal(param_list.graph,'yes') == 1
    subplot(2,1,1); plot((-t_win/2+101:t_win/2-100),smoothK);
    title(sprintf('Unit: %d     Samples: %d  (relative)',u,sample_sum));
    subplot(2,1,2); plot((-t_win/2:t_win/2),K);
return
end

coord = [(-t_win/2+101:t_win/2-100)' smoothK];
x = coord(coord(:,2) == max(smoothK),1);
    
if length(x) ~= 1;
    x = find(x,1,'first');
    disp('multiple peaks');
    disp(u);
end
  
      
ind = [x max(smoothK)];
    
if ind(1,2) == 0
    peak = [0 0 0];
    data = [0 0];
    disp('peak is zero');
else
    peak = [u x max(smoothK)];
    data = [(-t_win/2+101:t_win/2-100)' smoothK];
end
   
   
   
end

