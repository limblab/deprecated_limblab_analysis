%% SEGMENTGAITANIMATION animation used to create gait events
%
%segmentGaitAnimation ( data, freq )
%
%INPUTS:
%
%data: 1-by-M cell array containing the coordinates of M markers. Each
%element of the cell is a N-by-2 (or N-by-3) matrix containing N samples of
%the XY (XYZ) coordinates.
%
%freq: frequency of rendering in Hz
%
%Author: Cristiano Alessandro (cristiano.alessandro@northwestern.edu)
%Date: April 06 2016
%Licence: GNU GPL

%% Copyright (c) 2016 Cristiano Alessandro <cristiano.alessandro@northwestern.edu>
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program. If not, see <http://www.gnu.org/licenses/>.
%
% 2016-06-25: Maria Jantz added saving capabilities for both video and
% individual frames as png files. 

function [fhandle, footStrike, footOff] = saveGaitMovie( data, freq, overlay, filename, saving, annotate)

    nDim = size(data{1}); %get the dimensions of the array passed in
    
    extr = getDataExtreme (data); %find extreme values (to set limits later?)

    
    %divide into x, y, z coordinates
    X = cell2mat(cellfun(@(x)x(:,1),data,'UniformOutput', false));
    Y = cell2mat(cellfun(@(x)x(:,2),data,'UniformOutput', false));
    if nDim>2
        Z = cell2mat(cellfun(@(x)x(:,3),data,'UniformOutput', false));
        h = line(X(1,:),Y(1,:),Z(1,:),'Marker','o');
    else
        h = line(X(1,:),Y(1,:),'Marker','o');
    end    
    
    %set(h, 'linewidth', 3); 
    
    %set axes
    axis equal; 
    %scale extremes up by .1
    xinterval = (extr(2)-extr(1))*.1; 
    yinterval = (extr(4)-extr(3))*.1;
    lmt = [extr(1)-xinterval extr(2)+xinterval extr(3)-yinterval extr(4)+yinterval];
    lmt([1 3]) = 50*(floor(lmt([1 3])/50.));
    lmt([2 4]) = 50*(ceil(lmt([2 4])/50.));
    xlim([lmt(1) lmt(2)]); 
    ylim([lmt(3) lmt(4)]); 
    
    lmt_ratio = abs((lmt(2)-lmt(1))/(lmt(3)-lmt(4)));
    fig_width = 400; 
    fig = gcf; 
    fig.Position(3)=fig_width; 
    fig.Position(4)=fig_width/lmt_ratio; 
    
    ax = gca; 
    ax.XTick =  [lmt(1):50:lmt(2)];
    ax.YTick =  [lmt(3):50:lmt(4)];
    grid off; 
    
    
    k                        = 1;
    fig.UserData.i           = k;
    fig.UserData.footStrike  = [];
    fig.UserData.footOff     = [];
    fig.UserData.flagWait    = false;
    fig.UserData.fStrikeFlag = false;
    fig.UserData.saveframe   = false; 
    fig.KeyPressFcn          = @seg_figCallBack;    
    
    if annotate
    htf = text(extr(1)+10, extr(3)+50, ['Frame:' num2str(k)]);
    htt = text(extr(1)+10, extr(3)+30, ['Time [s]:' num2str((k-1)/freq)]);
    hfs = text(extr(1)+100, extr(3)-180, '', 'Color','r');
    hfo = text(extr(1)+100, extr(3)-230, '', 'Color','r');
    end
    
    frame = 0;
    
    nPt = size(X,1); %number of points in dataset = number of frames in movie
    if saving
    v = VideoWriter(filename); %for saving the movie; open video object
    open(v);
    end
    
    if overlay
        %get colors (this is a bit sloppy right now)
        %colors = [85 163 98; 11 62 25];
        colors = [132 242 144; 11 62 25];%[255 99 91; 95 199 232]; %[217 24 21; 0,32,184]; 
        ranges = [0 nPt]; 
        map = interp1(ranges/nPt,colors,linspace(0,1,nPt))/255; 
    end
    
    hold on; 
    while fig.UserData.i<=nPt %this loop is where the actual movie gets played     
        
        if fig.UserData.i<1
            fig.UserData.i = 1;
            k = 1;
        end
        
        if fig.UserData.i>nPt
            fig.UserData.i = nPt;
            k = nPt;
        end
        
        if nDim>2 %set the data points for this frame for X, Y, Z coordinates
            if overlay
                line(X(k,:),Y(k,:),Z(k,:),'Marker','o', 'Color', map(k, :));
                
                %disp(map(k, :)*255); 
            else
                set(h,'XData',X(k,:),'YData',Y(k,:),'ZData',Z(k,:)); %this is where the animation moves
            end
        else
            if overlay
                line(X(k,:),Y(k,:),'Marker','o', 'Color', map(k, :));
                %line(X(k,:),Y(k,:),'Marker','o');
            else
                set(h,'XData',X(k,:),'YData',Y(k,:), 'LineWidth', .2);
            end
        end                   
          
        lfs = length(fig.UserData.footStrike);
        lfo = length(fig.UserData.footOff);
        
        if fig.UserData.flagWait %toggle wait with p and s keys  
            waitforbuttonpress
            if fig.UserData.saveframe %if you press the 'e' key, it saves the frame
                %disp(['saving frame' num2str(k) '.png']); 
                saveas(gcf, ['frame' num2str(k) '.png']); 
                fig.UserData.saveframe = false; 
                %need to somehow make the figure active?? it's not picking
                %up button press after saving. 
            end
            if annotate
            if ~strcmp(hfs.String,'') || ~strcmp(hfo.String,'')
                hfs.String = '';
                hfo.String = '';
            end
            end
        else %advance the frame
            fig.UserData.i = fig.UserData.i + 1;
            pause(1/freq);
        end
        
        %set up next frame: first advance the frame/time labels
        k = fig.UserData.i;
        if annotate
        htf.String = num2str(['Frame:' num2str(k)]);
        htt.String = num2str(['Time [s]:' num2str((k-1)/freq)]);
       
        %check for foot strike/foot off
        if length(fig.UserData.footStrike)>lfs
            hfs.String = 'Foot Strike';
        end
        
        if length(fig.UserData.footOff)>lfo
            hfo.String = 'Foot Off';
        end
        end
    if saving
    writeVideo(v,getframe); %actually save the frame of video
    end
    end
    
    footStrike  = fig.UserData.footStrike; 
    footOff     = fig.UserData.footOff;
    
    if saving
    close(v); %close video object
    end
    %mymovie(frame+1)=getframe; %getframe is a matlab utility to build movies frame by frame
    %clf %clears the current frame
    %savefig mymovie %this seems strange.

    fhandle = gcf; 
end

function seg_figCallBack(hObject,callbackdata)

    data    = hObject.UserData;
    key     = callbackdata.Key;
    
    switch key
        case{'uparrow'}
            if data.fStrikeFlag
                data.footOff     = [data.footOff; data.i];
                data.fStrikeFlag = false;
            end
        case{'downarrow'}
            if ~data.fStrikeFlag
                data.footStrike = [data.footStrike; data.i];
                data.fStrikeFlag = true;
            end
        case{'rightarrow'}
            data.i = data.i+1;
        case{'leftarrow'}
            data.i = data.i-1;            
        case{'f'}
            data.flagWait = false;
        case{'s'}
            data.flagWait = true;
        case{'e'}
            data.saveframe = true; 
            
    end
    
    hObject.UserData = data;

end

function extremes = getDataExtreme (dat)

    xMin = cell2mat(cellfun(@(x)min(x(:,1)),dat,'UniformOutput', false));
    xMin = min(xMin);    
    
    xMax = cell2mat(cellfun(@(x)max(x(:,1)),dat,'UniformOutput', false));
    xMax = max(xMax);

    yMin = cell2mat(cellfun(@(x)min(x(:,2)),dat,'UniformOutput', false));
    yMin = min(yMin);
    
    yMax = cell2mat(cellfun(@(x)max(x(:,2)),dat,'UniformOutput', false));
    yMax = max(yMax);
    
    extremes = [xMin xMax yMin yMax];

end