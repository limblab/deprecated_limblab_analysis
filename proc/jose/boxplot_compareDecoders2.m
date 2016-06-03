function boxplot_compareDecoders2(v_HC,v_N2E2P,v_N2P,title_name,m_units)

% Boxplot to compare a feature (time to reach a target, length to reach a target,...)   
% for 3 different Decoders in this case: hand control, FES decoder and Neuron
% to force decoder.
% v_HC is a nxt vector: n is number of trials, could contain zeros
%                       t is the number of targets that should be the same
%                       for all 3 decoders
% title_name: title of the box_plot figure.
% m_units : measure units of the analized variable, e.g. : time (sec)
% Updated 11-08-12 ...  by Jose

if(size(v_HC,2)==size(v_N2E2P,2) && size(v_HC,2)==size(v_N2P,2))
    class1 = [];
    class2 = [];
    data = [];
    p = zeros(size(v_HC,2)+1,1);
    for i=1:size(v_HC,2)
        a = v_HC(v_HC(:,i)~=0,i);
        b = v_N2E2P(v_N2E2P(:,i)~=0,i);
        c = v_N2P(v_N2P(:,i)~=0,i);

        aux_data = [a;b;c];
        g1 = [repmat('D1',length(a),1);repmat('D4',length(b),1);repmat('D5',length(c),1)];
        g2 = [repmat(['            Target',char(48+i)],size(g1,1),1)];

        class1 = [class1;g1];
        class2 = [class2;g2];
        data = [data;aux_data];      
        
        p(i) = anova1(aux_data,g1,'off');
%         [D P] = manova1(aux_data,g1,0.05)   
    end    

    % Get average for all trials per decoder
    % sum(double(class1),2) ... converting to get double values of
    % HC (171) , CD (167) ,N2F(198)
    D1_d = sum(double('D1'));
    D2_d = sum(double('D4'));
    D3_d = sum(double('D5'));
    all_HC  = data(sum(double(class1),2)==D1_d); % get all trials for HC
    all_FES = data(sum(double(class1),2)==D2_d); % get all trials for FES
    all_N2F = data(sum(double(class1),2)==D3_d); % get all trials for N2F
    data = [data;all_HC;all_FES;all_N2F];

    g1 = [repmat('D1',length(all_HC),1);repmat('D4',length(all_FES),1);...
            repmat('D5',length(all_N2F),1)];
    g2 = [repmat('            Average',size(g1,1),1)];
    class1 = [class1;g1];
    class2 = [class2;g2];

    data_anova = [all_HC;all_FES;all_N2F];
    p(end) = anova1(data_anova,g1,'off');
    
%     [D P] = manova1(data_anova,g1,0.05);
    
    figure
    boxplot(data,{class2,class1},'colors',repmat('kmg',1,8),'factorgap',[15 5],...
        'labelverbosity','minor','factorseparator',[1])
    title(sprintf(title_name));
    ylabel(m_units);
    
%     % text p-values in boxplot
%     text(0.5,0.3,['p = ',num2str(p(1),'%.3e')],'FontSize',10);
%     text(9.4,0.3,['p = ',num2str(p(2),'%.3e')],'FontSize',10);
%     text(19,0.3,['p = ',num2str(p(3),'%.3e')],'FontSize',10);
%     text(28.5,0.3,['p = ',num2str(p(4),'%.3e')],'FontSize',10);
%     text(38,0.3,['p = ',num2str(p(5),'%.3e')],'FontSize',10);
%     text(48,0.3,['p = ',num2str(p(6),'%.3e')],'FontSize',10);
%     text(57,0.3,['p = ',num2str(p(7),'%.3e')],'FontSize',10);
%     text(66,0.3,['p = ',num2str(p(8),'%.3e')],'FontSize',10);
%     text(75,0.3,['p = ',num2str(p(9),'%.3e')],'FontSize',10);
    
else
    disp('features of the decoders should be for the same number of targets');
end
