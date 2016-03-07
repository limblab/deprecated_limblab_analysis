function varargout = animate_stick(xstick,ystick,zstick,varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if nargin >= 4
    frames = varargin{1};
else 
    frames = [];
end

if nargin >= 5
    view_para = varargin{2};
    az = view_para(1);
    el = view_para(2);
else
    az = 0; el = 90;
end

npoints = size(xstick,2);
nsamples = size(xstick,1);
for ii = 1:nsamples
    h(ii) = plot3(xstick(ii,:),ystick(ii,:),zstick(ii,:),'o-');
    for jj = 1:npoints
        text(xstick(ii,jj)-1,ystick(ii,jj)-1,zstick(ii,jj)-1,num2str(jj))
    end
    axis([min(xstick(:)) max(xstick(:)) min(ystick(:)) max(ystick(:)) min(zstick(:)) max(zstick(:))])
    xrange = max(xstick(:)) -min(xstick(:));
    yrange = max(ystick(:)) -min(ystick(:));
    use_range = max([xrange yrange]);
    
    axis([min(xstick(:)) min(xstick(:))+use_range min(ystick(:)) min(ystick(:))+use_range min(zstick(:)) min(zstick(:))+use_range])

    axis('square')
    grid
    if isempty(frames)
        title(ii)
    else
        title(['frame #: ' num2str(frames(ii))]);
    end
    view(az,el)
%     view([50 50])
%     set(gca,'CameraUpVector',[.7 1 1])
    set(gca,'Box','on')
    drawnow
    [az,el] = view;
    F(ii) = getframe(gca);
    pause(0.0001)
end

if nargout == 1
    varargout{1} = h;
elseif nargout == 2
    varargout{1} = h;
    varargout{2} = F;
end