function [x_fixed,y_fixed]=fix_angles(y,varargin)
    if isempty(varargin)
        x=1:length(y);
    else
        x=varargin{1};
    end
    if ~isrow(x)
        x=x';
    end
    if ~isrow(y)
        y=y';
    end
    if length(x)~=length(y)
        error(fix_angles:VectorsNotSameLength)
    end
    %rearrange angles to be on -pi to pi range
    y=wrapToPi(y);
    % if the gap between numbers is greater than pi, we wrapped around , 
    % so insert a nan so the plot appears to jump
    jumps=find(abs(diff(y))>pi);
    num_jumps=length(jumps);
    
    if num_jumps>0
        x_parts{1}=x(1:jumps(1));
        y_parts{1}=y(1:jumps(1));
        j=1;
        for i=1:num_jumps-1
            j=j+1;
            x_parts{j}=x(jumps(i));
            y_parts{j}=nan;
            j=j+1;
            x_parts{j}=x(jumps(i)+1:jumps(i+1));
            y_parts{j}=y(jumps(i)+1:jumps(i+1));
        end
        j=j+1;
        x_parts{j}=x(jumps(end));
        y_parts{j}=nan;
        j=j+1;
        x_parts{j}=x(jumps(end)+1:end);
        x_fixed=cell2mat(x_parts);
        y_parts{j}=y(jumps(end)+1:end);
        y_fixed=cell2mat(y_parts);
    else
        x_fixed=x;
        y_fixed=y;
    end
    
    
end