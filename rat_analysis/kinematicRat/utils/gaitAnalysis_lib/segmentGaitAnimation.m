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

function [footStrike, footOff] = segmentGaitAnimation( data, freq )

    nDim = size(data{1});
    
    extr = getDataExtreme (data);
    
    X = cell2mat(cellfun(@(x)x(:,1),data,'UniformOutput', false));
    Y = cell2mat(cellfun(@(x)x(:,2),data,'UniformOutput', false));
    
    if nDim>2
        Z = cell2mat(cellfun(@(x)x(:,3),data,'UniformOutput', false));
        h = line(X(1,:),Y(1,:),Z(1,:),'Marker','o');
    else
        h = line(X(1,:),Y(1,:),'Marker','o');
    end    
    
    k                        = 1;
    fig                      = gcf;
    fig.UserData.i           = k;
    fig.UserData.footStrike  = [];
    fig.UserData.footOff     = [];
    fig.UserData.flagWait    = false;
    fig.UserData.fStrikeFlag = false;
    fig.KeyPressFcn          = @seg_figCallBack;    
    
    htf = text(extr(1)+100, extr(2)-80, ['Frame:' num2str(k)]);
    htt = text(extr(1)+100, extr(2)-130, ['Time [s]:' num2str((k-1)/freq)]);
    hfs = text(extr(1)+100, extr(2)-180, '', 'Color','r');
    hfo = text(extr(1)+100, extr(2)-230, '', 'Color','r');
    
    nPt = size(X,1);
    while fig.UserData.i<=nPt      
        
        if fig.UserData.i<1
            fig.UserData.i = 1;
            k = 1;
        end
        
        if fig.UserData.i>nPt
            fig.UserData.i = nPt;
            k = nPt;
        end
        
        if nDim>2
            set(h,'XData',X(k,:),'YData',Y(k,:),'ZData',Z(k,:));
        else
            set(h,'XData',X(k,:),'YData',Y(k,:));
        end                   
          
        lfs = length(fig.UserData.footStrike);
        lfo = length(fig.UserData.footOff);
        
        if fig.UserData.flagWait            
            waitforbuttonpress
            if ~strcmp(hfs.String,'') || ~strcmp(hfo.String,'')
                hfs.String = '';
                hfo.String = '';
            end
        else
            fig.UserData.i = fig.UserData.i + 1;
            pause(1/freq);
        end
        
        k = fig.UserData.i;
        htf.String = num2str(['Frame:' num2str(k)]);
        htt.String = num2str(['Time [s]:' num2str((k-1)/freq)]);
        
        if length(fig.UserData.footStrike)>lfs
            hfs.String = 'Foot Strike';
        end
        
        if length(fig.UserData.footOff)>lfo
            hfo.String = 'Foot Off';
        end
        
    end
    
    footStrike  = fig.UserData.footStrike; 
    footOff     = fig.UserData.footOff;
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
        case{'p'}
            data.flagWait = false;
        case{'s'}
            data.flagWait = true;
            
    end
    
    hObject.UserData = data;

end

function extremes = getDataExtreme (dat)

    xMin = cell2mat(cellfun(@(x)min(x(:,1)),dat,'UniformOutput', false));
    xMin = min(xMin);    

    yMin = cell2mat(cellfun(@(x)min(x(:,2)),dat,'UniformOutput', false));
    yMin = min(yMin);
    
    extremes = [xMin yMin];

end