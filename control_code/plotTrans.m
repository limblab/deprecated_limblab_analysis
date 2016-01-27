% Function for plotting transparent lines in R
%   this is useful for having transparency propto likelihood, for instance
%   Requires the Matlab R-link (http://www.mathworks.com/matlabcentral/fileexchange/5051)
%
%   x   vector
%   y   matrix
%   t   vector of [0,255] alpha values
%
% Example:
% [b,sidx] = sort(S.log_llhd);
% plotTrans(x1(1:5:end),y2(flipud(sidx),1:5:end),ceil(sidx/length(sidx)*255/4))
%
% Ian Stevenson, 4/2010

function plotTrans(x,y,t,col,x0,y0)

if nargin<4, col=[255 0 0]; end
colstr = [num2str(col(1)) ',' num2str(col(2)) ',' num2str(col(3)) ','];

try
    closeR;
catch
    [status,msg] = openR;
    if status ~= 1
        disp(['Problem connecting to R: ' msg]);
    else
        if nargin<3
            t = 255*ones(size(y,1),1);
        end
        yl = [0 max(y(:))];
        putRdata('x',x)
        putRdata('y',y(1,:))
        evalR(['plot(x,y, type="l", col=rgb(' colstr num2str(t(1)) ',maxColorValue=255), pch=16, ylim=c(' num2str(yl(1)) ',' num2str(yl(2)) '))'])
        for i=2:size(y,1)
            putRdata('y',y(i,:))
            evalR(['lines(x,y, type="l", col=rgb(' colstr num2str(t(i)) ',maxColorValue=255))'])
            fprintf('.')
        end
        
        if nargin>4
            putRdata('x',x0)
            putRdata('y',y0)
            evalR(['lines(x,y, type="l", col=rgb(0,0,0,255,maxColorValue=255))'])
        end
        
        fprintf('\n')
    end
end