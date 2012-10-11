function PD_plot_selection(varargin)

%  PD_PLOT_SELECTION(CHANNEL_SELECTION,BDF,INCLUDE_UNSORTED)
%       generates a polar plot showing the PDs of selected channels as 
%       thicker lines, the area between the 95% confidence bounds as
%       shaded, and the length of the lines indicating the modulation depth
%       of the PDs.

if length(varargin)<3
    include_unsorted = 0;
else
    include_unsorted = varargin{3};
end

bdf = varargin{2};
channel_selection = varargin{1}; % vector of channels you want plotted: [13, 15, 94]

%% get pds, errs, moddepth, unit list
[pds, errs, moddepth]=glm_pds(bdf,include_unsorted);
u1 = unit_list(bdf,include_unsorted);

%% make plots
CI = errs*1.96; % confidence bounds

figure('name','PDs of selected channels')

str = strtrim(cellstr(int2str(channel_selection.')));

for iChan=1:length(channel_selection)
    iPD = find(u1 == channel_selection(iChan),1,'first');
    r = 0.001:0.01:moddepth(iPD); % /max(moddepth); % the length of the radial line is normalized by the modulation depth
    angle = repmat(pds(iPD),1,length(r)); % vector size (1,length(r)) of elements equal to each preferred direction
    err_up = angle+repmat(CI(iPD),1,length(r)); % upper error bound
    err_down = angle-repmat(CI(iPD),1,length(r)); % lower error bound
    
    h1 = polar(angle,r);
    hold on
    h2 = polar(err_up,r);
    h3 = polar(err_down,r);
    set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
            '-or','String','150','-or','String','210','-or','String','240',...
            '-or','String','300','-or','String','330') ,'String', ' '); % remove a bunch of labels from the polar plot; radial and tangential
        
%         '-or','String','  0.2',...
%             '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
%             '-or','String','  0.1','-or','String','  1',...
%             '-or','String','  0.4','-or','String','  0.6',...
%             '-or','String','  0.8'
        
    set(h1,'linewidth',2);
    [x1,y1]=pol2cart(angle,r); % needed to fill up the space between the two CI
    [x2,y2]=pol2cart(err_up,r);
    [x3,y3]=pol2cart(err_down,r);
   
    x_fill = [x2(end), x1(end), x3(end), 0];
    y_fill = [y2(end), y1(end), y3(end), 0];
    patch(x_fill,y_fill,'b','facealpha',0.3);
    text(x1(end)+x1(end)/5,y1(end)+y1(end)/5,str{iChan});
 
end
