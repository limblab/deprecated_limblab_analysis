function [learbar, rearbar, leyebar, reyebar, midline] = get_mri_landmarks(mri_data,options)

if nargin == 1
    xmmperpix=1;
    ymmperpix=1;
    mmperslice=1;
else
    xmmperpix=options.xresolution;
    ymmperpix=options.yresolution;
    mmperslice=options.zresolution;
end

pixx=size(mri_data,2);
pixy=size(mri_data,3);
nslices=size(mri_data,1);

learbar = [];
rearbar = [];
leyebar = [];
reyebar = [];
midline = [];

curslice=1;
measstr=[];
hfigure = figure('Units','normalized');
hslider = uicontrol('Style','slider','Units','normalized','Position',[.25 .85 .5 .03],'Parent',hfigure,'Value',2,...
    'SliderStep',[1/nslices 10/nslices],'Min',1,'Max',nslices);
hbuttonDone = uicontrol('Style','togglebutton','Parent',hfigure,'String','Done','Units','normalized',...
    'Position',[0.05 .9 .2 .05],'HandleVisibility','off','Value',0);

hpanel = uipanel('Parent',hfigure,'Position',[.1 .05 .8 .15],'Units','normalized');

hbuttons = uibuttongroup('Parent',hpanel,'Position',[0 0 1 1]);
% Create three radio buttons in the button group.
hbuttonLEar = uicontrol('Style','Radio','Units','normalized','String','Left earbar',...
    'pos',[0.05 .7 .2 .2],'parent',hbuttons,'HandleVisibility','off');
htextLEar = uicontrol('Style','text','Units','normalized','String','',...
    'pos',[0.05 .5 .2 .2],'parent',hpanel);

hbuttonREar = uicontrol('Style','Radio','Units','normalized','String','Right earbar',...
    'pos',[0.05 .3 .2 .2],'parent',hbuttons,'HandleVisibility','off');
htextREar = uicontrol('Style','text','Units','normalized','String','',...
    'pos',[0.05 .1 .2 .2],'parent',hpanel);

hbuttonLEye = uicontrol('Style','Radio','Units','normalized','String','Left eyebar',...
    'pos',[0.3 .7 .2 .2],'parent',hbuttons,'HandleVisibility','off');
htextLEye = uicontrol('Style','text','Units','normalized','String','',...
    'pos',[0.3 .5 .2 .2],'parent',hpanel);

hbuttonREye = uicontrol('Style','Radio','Units','normalized','String','Right eyebar',...
    'pos',[0.3 .3 .2 .2],'parent',hbuttons,'HandleVisibility','off');
htextREye = uicontrol('Style','text','Units','normalized','String','',...
    'pos',[0.3 .1 .2 .2],'parent',hpanel);

hbuttonMidline = uicontrol('Style','Radio','Units','normalized','String','Midline',...
    'pos',[0.6 .7 .2 .2],'parent',hbuttons,'HandleVisibility','off');
htextMidline = uicontrol('Style','text','Units','normalized','String','',...
    'pos',[0.6 .1 .2 .55],'parent',hpanel);

hbuttonAcquire = uicontrol('Style','togglebutton','Units','normalized','String','Acquire',...
    'pos',[0.8 .3 .1 .2],'parent',hpanel,'HandleVisibility','off','Value',0);

while get(hbuttonDone,'Value')==0
    cla;
    imagesc(squeeze(mri_data(curslice,:,:)));
    colormap(gray);
    set (gca,'dataaspectratio',[xmmperpix ymmperpix mmperslice*nslices]);
    title (['Slice ',num2str(curslice),' = ',num2str(curslice*mmperslice),' mm']);
    xlabel (measstr);
    
    while round(get(hslider,'Value')) == curslice
        pause(0.01)
        if get(hbuttonDone,'Value')==1
            break
        end
        selectedButton = get(hbuttons,'SelectedObject');
        if get(hbuttonAcquire,'Value')
            [x,y] = ginput(1);
            set(hbuttonAcquire,'Value',0);
            switch selectedButton
                case hbuttonLEar
                    learbar = [x y curslice]';
                    set(htextLEar,'String',[num2str(x,3) ' ' num2str(y,3) ' ' num2str(curslice,3)])
                case hbuttonREar
                    rearbar = [x y curslice]';
                    set(htextREar,'String',[num2str(x,3) ' ' num2str(y,3) ' ' num2str(curslice,3)])
                    
                case hbuttonLEye
                    leyebar = [x y curslice]';
                    set(htextLEye,'String',[num2str(x,3) ' ' num2str(y,3) ' ' num2str(curslice,3)])
                    
                case hbuttonREye
                    reyebar = [x y curslice]';
                    set(htextREye,'String',[num2str(x,3) ' ' num2str(y,3) ' ' num2str(curslice,3)])
                    
                case hbuttonMidline
                    midline = [midline, [x y curslice]'];
                    set(htextMidline,'String',strvcat(get(htextMidline,'String'),...
                    [num2str(x,3) ' ' num2str(y,3) ' ' num2str(curslice,3)]))
            end
        end
    end
    curslice = round(get(hslider,'Value'));      
end

close 1