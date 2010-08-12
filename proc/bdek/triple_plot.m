function triple_plot(bdf,unit)

if strcmp(unit,'all') == 1
    
p_list = struct('x_pos', 'include','y_pos', 'include', ... 
                    'x_vel', 'include', 'y_vel','include', ...
                    'x_acc', 'omit', 'y_acc', 'omit', ...
                    'x_force', 'omit', 'y_force', 'omit', ...
                    'samples', 0.2,'window', 3000,...
                   'unit', 9,'block_param', 0.00, 'resp_param', ...
                    0.05, 'resp_axes', 'omit','graph', 'no');
                
FirstPlot = cell(1,length(bdf.units));
for i = 1:length(bdf.units)
    [tmp,p,tmp] = KLD_nongauss(bdf,p_list,i);
    FirstPlot{1,i} = p;
end
listing = vertcat(FirstPlot{:,:});
nonzero = listing(find(listing(:,3)),:); %#ok<FNDSB>
length_nonzero = length(nonzero(:,1));
unit_indx = nonzero(:,1);



for k = 0:length_nonzero-1
    
    p_list = struct('x_pos', 'include','y_pos', 'include', ... 
                    'x_vel', 'include', 'y_vel','include', ...
                    'x_acc', 'omit', 'y_acc', 'omit', ...
                    'x_force', 'omit', 'y_force', 'omit', ...
                    'samples', 0.2,'window', 3000,...
                   'unit', 9,'block_param', 0.00, 'resp_param', ...
                    0.05, 'resp_axes', 'omit','graph', 'no');
                
    [dboth,tmp,tmp] = KLD_nongauss(bdf,p_list,unit_indx(k+1,1));

    p_list.x_pos = 'omit';
    p_list.y_pos = 'omit';

    [dvel,tmp,tmp] = KLD_nongauss(bdf,p_list,unit_indx(k+1,1));

    p_list.x_pos = 'include';
    p_list.y_pos = 'include';
    p_list.x_vel = 'omit';
    p_list.y_vel = 'omit';

    [dpos,tmp,tmp] = KLD_nongauss(bdf,p_list,unit_indx(k+1,1));

    dpos_plus_vel = dpos(:,2) + dvel(:,2);

    subplot((ceil(sqrt(length_nonzero))), (ceil(sqrt(length_nonzero))), k+1);
    plot(dboth(:,1),dboth(:,2),dvel(:,1),dvel(:,2),dpos(:,1),dpos(:,2),dpos(:,1),dpos_plus_vel);
    title(sprintf('Unit: %u', unit_indx(k+1,1)));
    if k == 0
        legend('position and velocity','velocity','position','position + velocity');
    end
end

else
    u = unit;
    p_list = struct('x_pos', 'include','y_pos', 'include', ... 
                    'x_vel', 'include', 'y_vel','include', ...
                    'x_acc', 'omit', 'y_acc', 'omit', ...
                    'x_force', 'omit', 'y_force', 'omit', ...
                    'samples', 0.2,'window', 3000,...
                   'unit', 9,'block_param', 0.00, 'resp_param', ...
                    0.05, 'resp_axes', 'omit','graph', 'no');
                
    [dboth,tmp,tmp] = KLD_nongauss(bdf,p_list,u);

    p_list.x_pos = 'omit';
    p_list.y_pos = 'omit';

    [dvel,tmp,tmp] = KLD_nongauss(bdf,p_list,u);

    p_list.x_pos = 'include';
    p_list.y_pos = 'include';
    p_list.x_vel = 'omit';
    p_list.y_vel = 'omit';

    [dpos,tmp,tmp] = KLD_nongauss(bdf,p_list,u);

    dpos_plus_vel = dpos(:,2) + dvel(:,2);
    
    figure;
    plot(dboth(:,1),dboth(:,2),dvel(:,1),dvel(:,2),dpos(:,1),dpos(:,2),dpos(:,1),dpos_plus_vel);
    title(sprintf('Unit: %u', u));
    legend('position and velocity','velocity','position','position + velocity');

end
                
 