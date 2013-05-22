function varargout=errorbar_vert(varargin)

% syntax varargout=errorbar_vert(varargin)
%
% generates an errorbar plot, but shows only the vertical lines associated
% with the errorbar, not the horizontal part.  All arguments that can be
% passed to errorbar, can be passed to errorbar_vert in exactly the same
% way.

if nargout
	[varargout{1:nargout}]=errorbar(varargin{:});
    h=varargout{1};
else
    h=errorbar(varargin{:});
end

kids=get(h,'Children');
if iscell(kids)
    for n=1:length(kids)
        barH(n)=kids{n}(2);
    end
else
    barH=kids(2);
end

ydatas=get(barH,'ydata');
if iscell(ydatas)
    wascell=1;
    ydatas=cat(1,ydatas{:});
else
    wascell=0;
end

ydatas(:,4:9:end)=NaN;
ydatas(:,5:9:end)=NaN;
ydatas(:,7:9:end)=NaN;
ydatas(:,8:9:end)=NaN;

for n=1:size(ydatas,1)
    set(barH(n),'ydata',ydatas(n,:))
end