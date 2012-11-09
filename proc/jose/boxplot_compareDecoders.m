function boxplot_compareDecoders(v_HC,v_N2E2P,v_N2P,title_name)

% Boxplot to compare a feature (time to reach a target, length to reach a target,...)   
% for 3 different Decoders in this case: hand control, FES decoder and Neuron
% to force decoder.
% v_HC is a nxt vector: n is number of trials, could contain zeros
%                       t is the number of targets that should be the same
%                       for all 3 decoders
% title_name: title of the box_plot figure.
% Updated 11-08-12 ...  by Jose

if(size(v_HC,2)==size(v_N2E2P,2) && size(v_HC,2)==size(v_N2P,2))
    class1 = [];
    class2 = [];
    data = [];
    for i=1:size(v_HC,2)
        a = v_HC(v_HC(:,i)~=0,i);
        b = v_N2E2P(v_N2E2P(:,i)~=0,i);
        c = v_N2P(v_N2P(:,i)~=0,i);

        aux_data = [a;b;c];
        g1 = [repmat('HC ',length(a),1);repmat('CD ',length(b),1);repmat('N2F',length(c),1)];
        g2 = [repmat(['            Target',char(48+i)],size(g1,1),1)];

        class1 = [class1;g1];
        class2 = [class2;g2];
        data = [data;aux_data];        
    end    

    % Get average for all trials per decoder
    % sum(double(class1),2) ... converting to get double values of
    % HC (171) , CD (167) ,N2F(198)

    all_HC  = data(sum(double(class1),2)==171); % get all trials for HC
    all_FES = data(sum(double(class1),2)==167); % get all trials for FES
    all_N2F = data(sum(double(class1),2)==198); % get all trials for N2F
    data = [data;all_HC;all_FES;all_N2F];

    g1 = [repmat('HC ',length(all_HC),1);repmat('CD ',length(all_FES),1);...
            repmat('N2F',length(all_N2F),1)];
    g2 = [repmat('            Average',size(g1,1),1)];
    class1 = [class1;g1];
    class2 = [class2;g2];

    figure
    boxplot(data,{class2,class1},'colors',repmat('rbg',1,8),'factorgap',[15 5],...
        'labelverbosity','minor','factorseparator',[1])
    title(sprintf(title_name));
    ylabel('time (sec)');
else
    disp('features of the decoders should be for the same number of targets');
end
