function printxmlstruct(A,name,buffer)
    if iscell(A); % This is an element with children
        n = length(A);
        for ii = 1:n
            if isstruct(A{ii})
                disp([buffer '<',name,'>' num2str(ii) ' of ' num2str(n)])
                FN = fieldnames(A{ii});
                for jj = 1:length(FN)
                    printxmlstruct(A{ii}.(FN{jj}),FN{jj},['  ' buffer])
                end
            elseif strcmpi(name,'Comments__')
 
                disp([buffer 'Comment ' num2str(ii) ' of ' num2str(n) ':' A{ii}])
            else                warning('Something failed')
            end
        end
    elseif isstruct(A) %This is an attribute
        disp([buffer,name,'='])
        FN = fieldnames(A);
        for jj = 1:length(FN)
            printxmlstruct(A.(FN{jj}),FN{jj},['  ' buffer])
        end
    else %This is the text node
        if ischar(A)
             disp([buffer name '=' A])
        else
            disp([buffer name '=' mat2str(A)])
        end
    end