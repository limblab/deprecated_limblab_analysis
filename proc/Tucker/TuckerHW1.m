function [C,D] = TuckerHW()
    % Insert Comment here
    %
    % another comment
    A = zeros(100,10);
    B = find(A==0);
    A(1:end) = B(1:end);

    [C D]= variFinder(50, A);

end

function [C] = selector(A, varargin)
    if length(varargin)>0
        Blength=varargin{1};
    else
        Blength=50;
    end
    if length(varargin)>1
        BrepeatOKFlag=varargin{2};
    else
        BrepeatOKFlag=1;
    end

    B = sort(randi(100,1,Blength));
    if(~BrepeatOKFlag)
        B = unique(B, 'first');
    end
    C = A(B,:);    
end


function [meanMatrix, variMatrix] = variFinder(N, A)

    sumMatrix=selector(A,50,1);

    for count=2:N
        sumMatrix = cat(3,sumMatrix,selector(A,50,1));
    end
    meanMatrix = mean(sumMatrix, 3);

    variMatrix = (sumMatrix(:,:,1) - meanMatrix).^2;

    for count=2:N
        variMatrix = cat(3,variMatrix,(sumMatrix(:,:,count) - meanMatrix).^2);
    end
    variMatrix = mean(variMatrix,3);
end


    



    
    