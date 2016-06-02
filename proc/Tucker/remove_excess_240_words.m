function words=remove_excess_240_words(words)
    %written for databursts that have a bunch of words with value of 240
    %tacked onto the front. Removes all values of 240 between the end word
    %and the next DB start, as indicated by words 245 and 241 in sequence
    
    %find start of trial
    starts=find(words(:,2)==31);
    for i=1:length(starts)
        j=1;
        try
            while (words(starts(i)+j,2)~= 245) | (words(starts(i)+j+1,2)~= 241)
                if words(starts(i)+j,2)==240
                    words(starts(i)+j,:)=[];
                else
                    j=j+1;
                end
                if (starts(i)+j+1)>length(words(:,2))
                    break
                end
            end
            if (starts(i+1)+j+1)>length(words(:,2))
                break
            end
        catch
            i
            j
            starts(i)
            length(words(:,2))
            rethrow(lasterror)
        end
    end
end