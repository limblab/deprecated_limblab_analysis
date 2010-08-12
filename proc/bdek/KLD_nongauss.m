function[data, peak, param_points, ts] = KLD_nongauss(bdf, param_list,unit,...
                                                        samples, block_param, varargin)

% KLD_nongauss calculates the Kullback-Leibler divergence for a unit 
% regarding a particular set of parameters, dictated by the struct
% param_list.  See parameter_list_KLD for input parameter struct.


p_v_a_f = [(bdf.pos(:,2)-mean(bdf.pos(:,2))), ...           % x position
           (bdf.vel(:,2)), ...                              % x velocity
           (bdf.acc(:,2)), ...                              % x accel
           (bdf.force(:,2)-mean(bdf.force(:,2))), ...       % x force
           (bdf.pos(:,3)-mean(bdf.pos(:,3))), ...           % y position
           (bdf.vel(:,3)), ...                              % y velocity
           (bdf.acc(:,3)), ...                              % y accel
           (bdf.force(:,3)-mean(bdf.force(:,3)))];          % y force
       
       % p_v_a_f creates a (#time_stamps) x (8) array containing position,
       % velocity, acceleration, and force data for x and y directions
       
%%%%%%%%%%%%%%%%%%%%%%%  Function parameter input  %%%%%%%%%%%%%%%%%%%%%%%%
if nargin > 2
    u = unit;
else
    u = param_list.unit;
end

if nargin > 3
    perc_quad = samples;            
    % Input parameters 'perc_quad' and 'samples' 
    % refer to percentage of kinematic
    % block samples included in analysis
else
    perc_quad = param_list.samples;
end

if nargin > 4
    bp = block_param;
else
    bp = param_list.block_param;  %fraction of parameter standard deviation. 
                                  %Dictates width of empty set around axes
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

unit = bdf.units(1,u).ts;     % neuron
t_win = param_list.window;    % window width of KL divergence plot (ms)
exclusion_type = param_list.exclusion_type;
rp = param_list.resp_param;
    % rp refers to the exclusion window for the respected parameters. An rp
    % of 0.05 will result in inclusion or exclusion (depending on rpa) of
    % data points within 0.05*standard deviation(parameter)
rpa = param_list.resp_axes;
    % rpa refers to the inclusion or exclusion of the points within 
    % rp*standard deviation(parameter).
        %If rpa = 'include', include points s/t abs(data) < rp*std(data)
        %If rpa = 'omit', include points s/t abs(data) > rp*std(data)
if isempty(bdf.units(1,u).ts)==1
    data = [0 0];
    peak = [0 0 0];
    disp(sprintf('unit %d is empty',u)); %#ok<DSPS>
return
    % If unit chosen contains no spikes, zeros are returned
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info = sprintf(['x pos: %s\ny pos: %s\nx vel: %s\ny vel: %s'...
    '\nx acc: %s\ny acc: %s'...
    '\nx force: %s\ny force: %s\nsamples: %.3f\nwindow: %d\nunit: %d'...
    '\ninc param: %.3f\nex type: %s\nresp param: %.3f\nresp axes: %s'],...
    param_list.x_pos,param_list.y_pos,param_list.x_vel,param_list.y_vel,...
    param_list.x_acc,param_list.y_acc,param_list.x_force,param_list.y_force,...
    perc_quad,param_list.window,u,...
    bp,param_list.exclusion_type,param_list.resp_param,param_list.resp_axes);
        %The information from the input_param struct is converted to a
        %string for inclusion in resulting plot
        
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

all_params = [x_pos, x_vel, x_acc, x_force y_pos, y_vel, y_acc, y_force];
    %all_params gives a vector of 0's, 1's, and 2's defining the analysis
    %Ex: If all_params=[1 1 2 0 1 1 2 0]
    %    Then position and velocity are included, acceleration is respected
inc_par = find(all_params == 1);    % all_param indeces of included params
resp_par = find(all_params == 2);   % all_param indeces of respected params 
tot_par = horzcat(inc_par,resp_par);% all_param indeces of inc and resp params

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% separate data into kinematic blocks %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initialize variables
tot_Q = cell(8,2);
block_Q = cell(1,(2^length(inc_par)));  
Q_ts = cell(1,(2^length(inc_par)));
respected = zeros(length(bdf.pos),1);

for i = 1:2^length(inc_par)
    block_Q{i} = zeros(length(p_v_a_f),1);
    %initialize block_Q:
end


%%%%%%%%%%%%%%%%%%% address respected parameter option %%%%%%%%%%%%%%%%%%%%

% Sets additional restrictions on data according to the respected
% parameters selected.

if isempty(resp_par)
    respected = zeros(length(bdf.pos),1);
    % No parameter selected to 'respect' results in no added restrictions
    
elseif strcmp(rpa,'omit') == 1
    for i = resp_par
        respected = respected + (abs(p_v_a_f(:,i)) > rp*std(p_v_a_f(:,i)));
        % If resp_axes are 'omitted', then the vector "respected" contains
        % 0's, 1's and 2's corresponding to whether the expression:
        %   abs(data) > rp*std(data) 
        % is satisfied for zero, one, or ALL respected parameters.
    end
elseif strcmp(rpa, 'include') == 1
    for i = resp_par
        respected = respected + (abs(p_v_a_f(:,i)) < rp*std(p_v_a_f(:,i)));
        % If resp_axes are 'included', then the vector "respected" contains
        % 2's and 0's corresponding to the data points that satisfy (2) and
        % don't satisfy (0) the expression:
        % abs(data) < rp*std(data) for ANY respected parameters.
    end
    respected(respected == 1) = 2;
else
    respected = zeros(length(bdf.pos),1);
    % In default case, no parameters are respected
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ex = bp;
if isequal(exclusion_type,'origin')
    ex = 0;
end

for i = inc_par
    if i == 1 || i== 5
        tot_Q{i,1} = p_v_a_f(:,i) > 0;
        tot_Q{i,2} = p_v_a_f(:,i) < 0;
    else
        tot_Q{i,1} = p_v_a_f(:,i) > ex*std(p_v_a_f(:,i));
        tot_Q{i,2} = p_v_a_f(:,i) <-ex*std(p_v_a_f(:,i));
    %for each included parameter create two kinematic blocks, one for 
    %positive and one for negative values (excluding the block_parameter 
    %exclusion window).  
    
    %tot_Q is a cell array size 8x2, each cell a vector of logicals, length
    %length(bdf.pos) that represents every time stamp's inclusion in (1) or
    %exclusion from (0) the given parameter.  The rows of tot_Q represent
    %parameters (position, velocity, etc) and the columns represent
    %positive and negative, respectively.
    end
end

if isequal(exclusion_type,'origin')
    inc = inc_par;
    inc(inc==1|inc==5)=[];
    origin_ex_ind = (p_v_a_f(:,inc(1))).^2 + (p_v_a_f(:,inc(2))).^2 > bp*var(p_v_a_f(:,inc(1)));
    for i = inc
        tot_Q{i,1} = tot_Q{i,1} + origin_ex_ind;
        tot_Q{i,2} = tot_Q{i,2} + origin_ex_ind;
        tot_Q{i,1}(tot_Q{i,1}==1)=0;
        tot_Q{i,2}(tot_Q{i,2}==1)=0;
        tot_Q{i,1}(tot_Q{i,1}==2)=1;
        tot_Q{i,2}(tot_Q{i,2}==2)=1;
    end
end
    
    

[binned_spikes] = train2bins(unit,bdf.pos(:,1));
% binned_spikes(:,1:1002) = []; 
% binned_spikes = [binned_spikes zeros(1,ceil((bdf.pos(end,1)+5-unit(end)).*1000))];
    %binned_spikes contains all of the spike information, separated into
    %1ms bins. The first second is discarded in order to align the spike
    %timestamps with the kinematic timestamps.

poss = zeros(2^(length(inc_par)),(length(inc_par)));
for i = 1:(length(inc_par))
    poss(:,i) = abs(mod(ceil((1:(2^(length(inc_par))))./((2^(length(inc_par)))/(2^i))),2) - 2);
    %poss creates an array such that the rows represent every combination of
    %the included parameters (1 = positive, 2 = negative)
end

total_block = 0;
sample_sum = 0;
Q_ind = cell(1,2^length(inc_par));
param_points = zeros(1,2^length(inc_par));
for i = 1:2^length(inc_par)
    for j = 1:length(inc_par)
        block_Q{i} = block_Q{i} + tot_Q{inc_par(j),poss(i,j)};
        %block Q{i} creates a cell array containing all 2^length(inc_par)
        %possible parameter combinations.
    end
    block_Q{i} = block_Q{i} + respected;
        %add points satisfying respected parameters
    Q_ts{i} = find(block_Q{i} == (length(tot_par)));
        %Time stamps for kinematic state (i). 
    Q_ts{i}(Q_ts{i} <= t_win/2 | Q_ts{i} >= (length(bdf.pos)-t_win/2))=[];
        %Delete points t_win/2 from the beginning and end of trial. This
        %ensures that the time window can be constructed. 
    total_block = total_block + length(Q_ts{i}); %total timestamp counter
    num_rand = ceil(perc_quad*length(Q_ts{i}));  
    Q_ind{i} = Q_ts{i}(ceil((length(Q_ts{i}))*rand(num_rand,1)));
        %Q_ind converts a random number of time stamps (dictated by input
        %"samples" or param_list.samples) from Q_ts into array indices.
    param_points(i) = length(Q_ind{i}); %Values set for output argument 'param_points'
    sample_sum = sample_sum + param_points(i);  %selected kin point counter
end

Q_ind_lengths = zeros(2^length(inc_par),1);
for i = 1:2^length(inc_par)
    Q_ind_lengths(i) = length(Q_ind{i});
end

ts = Q_ts;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%   KL divergence  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Q = cell(1,2^length(inc_par));
% init_p_array = cell(1,2^length(inc_par));
p_array = cell(1,2^length(inc_par));
D = cell(1,2^length(inc_par));

t_points = -(t_win/2):(t_win/2);
init_p_array = zeros(2^length(inc_par), length(t_points));

for j = 1:(2^length(inc_par))
    for i = 1:length(t_points)
        init_p_array(j,i) = sum(binned_spikes(Q_ind{j}+t_points(i)));
        %init_p_array sums the spikes for each kinematic state over all
        %time lags defined by the window (param_list.window)
    end
end

tot_spikes = sum(init_p_array);

% if length(tot_spikes) > length(find(tot_spikes))
%     peak = [0 0 0];
%     data = [0 0];
%     disp('empty time point(s)');
% return
% end

for i = 1:(2^length(inc_par))
    Q{i} = length(Q_ts{i})/total_block;
        %Q is a cell array containing the Q values for the KL divergence
        %equation. For each kinematic state i, Q{i} is equal to the 
        %fraction of all kinematic points that are contained in that state.
    p_array{i} = init_p_array(i,:)./(tot_spikes); 
        %p_array is the normalized array of P values.  For each kinematic
        %state i, p_array{i} is equal to the fraction of all spikes that 
        %occured in that state. Each cell of p_array also includes all time 
        %lags
    D{i} = p_array{i} .* log2(p_array{i}./Q{i});
        %D{i} calculates the 1st through (2^length(inc_par))th iteration of
        %the Dkl equation. The calculations for each kinematic state (all
        %lags) are contained in the cells.
    D{i}(isnan(D{i})) = 0;
        %Calculations which are undefined (ex: p_array{i}(k) = 0) are set
        %to zero
end

% d = cell(1,2^length(inc_par));
% for i = 1:2^length(inc_par)
%     d{i} = find(D{i}==max([D{1};D{2};D{3};D{4}]));
%     d{i}(d{i}<=100|d{i}>=2900)=[];
%     d{i} = d{i}-(t_win/2);
% end

if isequal(param_list.show_components,'yes') ==1
    par_names = cell(8,1);
    keyheads = cell(length(inc_par),1);
    keybody = cell(2^length(inc_par),length(inc_par));
    par_names{1} = 'x pos';par_names{2}='x vel';par_names{3}='x acc';
    par_names{4} = 'x force';par_names{5}= 'y pos';par_names{6}='y vel';
    par_names{7} = 'y acc'; par_names{8}= 'y force';
    for i = 1:length(inc_par)
        keyheads{i} = par_names{inc_par(i)};
    end
    d = cell(1,2^length(inc_par));
    sumD = vertcat(D{:,:});
    for i = 1:2^length(inc_par)
        d{i} = i*(D{i}==max(sumD));
        for j = 1:length(inc_par)
            keybody{i,j} = num2str(poss(i,j));
            keybody{i,j}(keybody{i,j}=='1')='+';
            keybody{i,j}(keybody{i,j}=='2')='-';
        end
    end
    col = sum(vertcat(d{:,:}));
    col(:,1:101) = []; col(:,(end-101):end) = [];
end

K = sum(vertcat(D{:,:}));
    %The kinematic state interations (for all lags) are summed, giving the
    %KL divergence for each lag. 


smoothK = smooth(K,100);
smoothK(1:100,:) = []; 
smoothK((end-100):end,:) = [];
    %Smoothed for peak detection

if isequal(param_list.graph,'yes') == 1
    figure;
    subplot('position',[0.1,0.55,.60,0.35]); 
    if isequal(param_list.show_components,'yes') == 1
        m = [1 0 0;0 0 1;0 1 0;1 1 0;0 1 1;1 0 1; .5 0 0;0 0 .5;0 .5 0;...
            .5 .5 0;0 .5 .5;.5 0 .5;.5 .5 .5;.25 1 0;0 1 .25;1 .25 0];
        image([-t_win/2+102 t_win/2-101],[1.2*max(smoothK) 0],col); colormap(m); 
        hold on;
        area((-t_win/2+101:t_win/2-100),smoothK,1.2*max(smoothK),'FaceColor','white');
        hold off;
    else
        plot((-t_win/2+101:t_win/2-100),smoothK,'Color','b'); 
    end
        text(-t_win/3,0.5*max(smoothK),'Motor','FontSize',12,'HorizontalAlignment','center');
        text(t_win/3,0.5*max(smoothK),'Sensory','FontSize',12,'HorizontalAlignment','center');
        title(sprintf('Unit: %d     Samples: %d  (%.2f%s)',u,...
            sample_sum,(sample_sum/length(bdf.pos))*100,'%'));
        subplot('position',[0.1,0.1,0.60,0.35]); plot((-t_win/2:t_win/2),K);
        subplot('position',[0.75,0.1,0.2,0.8]); text(0,1,info,'VerticalAlignment','top');
        title('Parameters','Fontweight','bold'); axis off;
    if isequal(param_list.show_components,'yes') == 1
        for i = 1:2^length(inc_par)
            text(0,0.26-(i-1)/(2^length(inc_par)-1)*(0.0125*2^length(inc_par)+0.1),...
                '-','FontSize',40,'color',m(i,:),'FontWeight','bold');
            for j = 1:length(inc_par)
                if i==1
                    text(0.3+(j-1)*(0.245*length(inc_par)-0.2)/(length(inc_par)-1),...
                        0.30,keyheads{j},'HorizontalAlignment','center');
                end
                text(0.3+(j-1)*(0.245*length(inc_par)-0.2)/(length(inc_par)-1),...
                    0.25-(i-1)/(2^length(inc_par)-1)*(0.0125*2^length(inc_par)+0.1),...
                    keybody{i,j},'FontSize',15,'HorizontalAlignment','center');
            end
        end
    end  
    return
    %if the graph = 'yes' option is included in param_list input, a plot
    %is displayed containing raw and smoothed KL divergence plots over all
    %lags, the param_list values, as well as the total number of samples
    %remaining after 'samples' and 'block_param'/'resp_param'/etc parameters.
end

coord = [(-t_win/2+101:t_win/2-100)' smoothK];
x = coord(coord(:,2) == max(smoothK),1);
    %X finds the coordinate of the peak
    
if length(x) ~= 1;
    x = find(x,1,'first');
    disp(fprintf('multiple peaks in unit: %u',u));
    %If there are multiple peaks, a message is displayed to the user,
    %including the unit for which multiple peaks were observed. 
end
  
      
ind = [x max(smoothK)];
    %ind = [time lag of peak, amplitude of peak]
    
if ind(1,2) == 0
    peak = [0 0 0];
    data = [0 0];
    param_points = 0;
    disp('peak is zero');
    %output parameters are set to zero and message is displayed to user 
    %if the peak is zero
else
    peak = [u x max(smoothK)];
    data = [(-t_win/2+101:t_win/2-100)' smoothK]; 
    %Values set for output arguments 'peak' and 'data'.
end
