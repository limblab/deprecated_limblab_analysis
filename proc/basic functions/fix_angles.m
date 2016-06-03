function [x_fixed,y_fixed]=fix_angles(y,varargin)
    % assumes at least one input, which is a vector of angles in radians
    % wraps angles onto the range -pi to pi
    % wherever the angle changes by more than pi, inserts a nan, bounded by
    % 2 points outside the range -pi to pi, such that plotted data will
    % appear to wrap across the edges of a plot if the plot limits are set
    % to -pi and pi. Optionally takes a second vector of time points that
    % matches the angle vector. If no time vector is given, fix_angles will
    % generate one using the indices of the original vector, and return
    % that so that multiple corrected vectors may be plotted on the same
    % axes.
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
        %get the data before the first jump
        x_parts{1}=x(1:jumps(1));
        y_parts{1}=y(1:jumps(1));
        j=1;
        %loop through the jumps filling the data after each jump
        for i=1:num_jumps-1
            j=j+1;
            x_parts{j}=[    x(jumps(i)+1),                x(jumps(i)),    x(jumps(i))                 ];
            y_parts{j}=[    y(jumps(i))-y(jumps(i)+1),  nan,            y(jumps(i)+1)-y(jumps(i))   ];
            j=j+1;
            x_parts{j}=x(jumps(i)+1:jumps(i+1));
            y_parts{j}=y(jumps(i)+1:jumps(i+1));
        end
        %deal with the last jump specially
        j=j+1;
        x_parts{j}=[    x(jumps(end)+1),                x(jumps(end)),  x(jumps(end))                   ];
        y_parts{j}=[    y(jumps(end))-y(jumps(end)+1),  nan,            y(jumps(end)+1)-y(jumps(end))   ];

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