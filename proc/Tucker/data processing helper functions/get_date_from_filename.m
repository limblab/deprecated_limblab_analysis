function date_vector=get_date_from_filename(keystring,filename)
    %takes in a key to look for and then returns the next number scanned as
    %a date assumes dates are in the mmddyyyy format"
    %Kramer_randomwalk_10262012_tucker_006.nev could use 'randomwalk_' as a
    %keystring and the function would return a datestring for 10262012.
    %Note that the keystring must be the exact string leading up to the
    %date in the filename
    Index = strfind(filename, keystring);
    if isempty(Index)
        warning('get_date_from_filename:KeyStringNotFound','The key string was not found in the file name. Continuing assuming the date is the first numeric value in the filename')
        Index=[1];
    end
    
    for i=Index(1):length(filename)
        temp=str2num(filename(i));
        if(~isempty(temp))
            if temp==0
                leadingzero=1;
            else
                leadingzero=0;
            end
            break
        end
    end
    date_numeral=sscanf(filename(i:end),'%d');
    date_string=num2str(date_numeral);
    
    if leadingzero
        if length(date_string)~=7 
            disp(strcat('Date string is: ',date_string))
            error('get_date_from_filename:BadDateString','The numeric string that was recovered was not the correct length. Check your keystring')
        end
        date_vector=[str2num(date_string(4:end)),str2num(date_string(1)),str2num(date_string(2:3)),0,0,0];
    else
        if length(date_string)~=8  
            disp(strcat('Date string is: ',date_string))
            warning('get_date_from_filename:BadDateString','The numeric string that was recovered was not the correct length. Check your keystring')
            date_vector=date;
        end
        date_vector=[str2num(date_string(5:end)),str2num(date_string(1:2)),str2num(date_string(3:4)),0,0,0];
    end

    
    
end