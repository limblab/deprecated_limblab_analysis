FileIndex = 1;

%MATfiles_sub = MATfiles(cellfun(@isempty,regexp(MATfiles_dates,'[0-9]{8}001'))==0);

% for n =1:length(MATfiles_sub)

%     try
%     BDFlist=findBDF_withControl('Mini',days{n},'hand');
%     catch
%         continue
%     end
    
    
    
    %for k = 1:length(BDFlist)

        direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Mini\Decoders';
        cd(direct)
        Files=dir(direct);
        Files(1:2)=[];
        FileNames={Files.name};
        
        for n =1:length(FileNames)

            Currentfile{n}=FileNames(n);
            
            %Currentfiles{FileIndex}=FileNames(:,strmatch(MATfiles_sub{n},strvcat(FileNames{1,:})));

%             if isempty(Currentfiles{1})
%                 continue
%             else
%                 Currentfile = Currentfiles{1,FileIndex}{1}
%             end
            y = load(Currentfile{n}{:},'vaf');
            vafs = y.vaf;
            AvgVafs(n,:) = mean(vafs);
            vafs = vafs(sum(vafs(:,:)>0,2)==2,:);
            if isempty(vafs) == 0 && size(vafs,1) > 1
                vaf_all_firstfiles(FileIndex,:) = mean(vafs);
            elseif isempty(vafs) == 0 && size(vafs,1) == 1
                vaf_all_firstfiles(FileIndex,:) = vafs;
            else
                vaf_all_firstfiles(FileIndex,:) = [0 0];
            end
            FileIndex = FileIndex + 1;
            
        end
%    end
    
%end