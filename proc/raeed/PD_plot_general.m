%% Plot channel PDs
ul = unit_list(bdf_whole,1); % gets two columns back, first with channel

figure

for iPD = 1:length(ul(:,1))
    r = 0.0001:0.0001:moddepth(iPD)/max(moddepth); % the length of the radial line is normalized by the modulation depth
    angle = repmat(pds(iPD),1,length(r)); % vector size (1,length(r)) of elements equal to each preferred direction
    err_up = repmat(CI_high(iPD),1,length(r)); % upper error bound
    err_down = repmat(CI_low(iPD),1,length(r)); % lower error bound
    
    subplot(length(ul),1,iPD) % put the plot in the correct location relative to position in array ( [ 1 2 3;..
                                                                                                                               % 4 5 6 ]; )
    h0 = polar(pi,1); % place point at max length so all polar plots are scaled the same.
    hold on
    h1 = polar(angle,r);
    h2 = polar(err_up,r);
    h3 = polar(err_down,r);
    set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
        '-or','String','150','-or','String','210','-or','String','240',...
        '-or','String','300','-or','String','330','-or','String','  0.2',...
        '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
        '-or','String','  0.1','-or','String','  1') ,'String', ' '); % remove a bunch of labels from the polar plot; radial and tangential
    set(h1,'linewidth',2);

    [x1,y1]=pol2cart(angle,r); % needed to fill up the space between the two CI
    [x2,y2]=pol2cart(err_up,r);
    [x3,y3]=pol2cart(err_down,r);

    %     jbfill(x1,y1,y2,'b','b',1,0.5);
    x_fill = [x2(end), x1(end), x3(end), 0];
    y_fill = [y2(end), y1(end), y3(end), 0];

    % fill(x_fill,y_fill,'r');
    patch(x_fill,y_fill,'b','facealpha',0.3);


    title(['Chan' num2str(ul(iPD,1))]) % last part finds the cerebus assigned label in cer_list that belongs to the channel number of the current channel
end