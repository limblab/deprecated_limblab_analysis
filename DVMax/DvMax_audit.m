function animalList=DvMax_audit(varargin)
    % checks DvMax for missed water, food and weight entries. Prints out
    % uncommon entries.
    % animalList=DvMax_audit('startDate',datenum('1-Mar-2015'),'endDate',datenum('31-Mar-2015'))
    
    %% Add JDBC driver to path
    path_file = fopen('classpath.txt');
    path_file_text = fread(path_file)';
    fclose(path_file);
    driver_idx = strfind(char(path_file_text),'ojdbc6.jar')-2;
    [current_folder,~,~] = fileparts(mfilename('fullpath'));
    if ~isempty(driver_idx)
        driver_path_start = find(path_file_text(1:driver_idx)==10,1,'last')+1;
        driver_path = char(path_file_text(driver_path_start:driver_idx));        
        if ~strcmp(current_folder,driver_path)
            path_file_text(driver_path_start:driver_idx+11) = [];
            path_file_text = [path_file_text 10 uint8([current_folder filesep 'ojdbc6.jar'])];
            javarmpath([driver_path filesep 'ojdbc6.jar'])
            javaaddpath([current_folder filesep 'ojdbc6.jar'],'-end')
        end
    else
        path_file_text = [path_file_text 10 uint8([current_folder filesep 'ojdbc6.jar'])];
        javaaddpath([current_folder filesep 'ojdbc6.jar'],'-end')
    end
    %% set variables
    MonkeyWaterLocation = '\\citadel\limblab\lab_folder\Lab-Wide Animal Info\WeekendWatering\MonkeyWaterData.xlsx';
    water_codes = {'EP8500','EP9000','EP2000','AC1091'};
    free_water_codes = {'EP9200 ','AC1093','FC1025'};
    water_restriction_start_codes = {'EP9100','AC1092'};
    food_codes = {'EP8600','EP8700','EP1000'};
    free_food_codes = {'EP9400','FC1025'};
    food_restriction_start_codes = {'EP9300'};
    
    do_save=0;
    start_date=datenum('1-Oct-2013');
    end_date=datenum(date)-1;
    for i=1:2:length(varargin)
        switch varargin{i}
            case 'writeFiles'
                do_save=1;
                savepath=varargin{i+1};
                if ~strcmp(filesep,savepath(end))
                    savepath=[savepath,filesep];
                end
            case 'startDate'
                start_date=varargin{i+1};
            case 'endDate'
                end_date=varargin{i+1};
            otherwise
                warning(['did not recognize the string given in the ',num2str(i),'th input'])
        end
    end
    
    
    %% connect to database and load monkey list
    conn = database('OR','dvmax_lmiller','dvmax','Vendor','Oracle',...
        'DriverType','thin','Server','risdatsvr3.itcs.northwestern.edu','PortNumber',1521);    

    animalList = load_animal_list(MonkeyWaterLocation);
    save('animalList','animalList')
%     load('audit_animalList.mat')
%     animalList=audit_animalList;
    %% loop across all monkeys, checking each one
    for iMonkey = 1:length(animalList)
        %% get the info for this specific monkey
            cagecardID = animalList(iMonkey).cageID;
            cagecardID(strfind(cagecardID,'C')) = [];
            exestring= ['select distinct cage_card_id, datetime_performed_cst, med_rec_code, med_description, comments'...
               ' from granite_reports.dvmax_med_rec_entries_vw where cage_card_id=' cagecardID 'order by datetime_performed_cst asc'];
            data = fetch(conn,exestring);
            data = data(end:-1:1,:);
            data_dates = reshape([data{:,2}],21,[])';
            data_dates = data_dates(:,1:10);
            data_dates = cellstr(data_dates);
        %% get all body weights entries
%         iMonkey
            body_weight = datenum(data(strcmpi('EX1050',{data{:,3}}),2));
            body_weight =floor(sort(body_weight));
            
            body_weight_in_water_entry = [];
            for iEntry = 1:size(data,1)
%                 if iEntry == 700 && iMonkey == 6
%                     pause
%                 end
                weight_pos_in_entry = regexp(data{iEntry,end},'Weight:')+7;
                if ~isempty(weight_pos_in_entry)
                    car_return = regexp(data{iEntry,end},'\n');
                    if ~isempty(car_return)
                        car_return = car_return(find(car_return>weight_pos_in_entry,1,'first'));
                        kg = regexp(data{iEntry,end},'kg')-1;
                        if ~isempty(kg)
                            car_return = min(car_return,kg);
                        end
                        weight_in_entry = str2double(data{iEntry,end}(weight_pos_in_entry:car_return));
                        if ~isnan(weight_in_entry)
                            body_weight_in_water_entry = [body_weight_in_water_entry; floor(datenum(data(iEntry,2)))];
                        end
                    end
                end
            end
            
            body_weight = sort([body_weight;body_weight_in_water_entry]);
            
            
            %find first weight entry before the start date
            last_weight=body_weight(find(body_weight<start_date,1,'Last'));
            if isempty(last_weight)
                %warning('DvMax_audit:NoPriorWeight',['could not find a weight prior to the given start date for:' animalList(iMonkey).animalID,', ',animalList(iMonkey).animalName])
                last_weight = 0;%set value very small
            end
        %% get all free water entries 
            free_water_start = [];
            for iFreeWaterCodes = 1:length(free_water_codes)
                temp=data(strcmpi(free_water_codes{iFreeWaterCodes},{data{:,3}}),2);
                if ~isempty(temp)
                    free_water_start = [free_water_start;datenum(temp)]; 
                end
            end
            free_water_start=floor(sort(free_water_start));
            % Find first water entry in list before the start date
            prior_free_water = free_water_start(find(free_water_start<start_date,1,'Last'));  
            if isempty(prior_free_water)
                %warning('DvMax_audit:NoFreeWaterFound',['could not find a free water start prior to the given start date for:' animalList(iMonkey).animalID,', ',animalList(iMonkey).animalName])
                prior_free_water = 0;%set value very small, comparison to real water restriction dates should show water restriction dates after this value
            end
        %% get all water restriction start entries
            water_restriction_start = [];
            for iCode = 1:length(water_restriction_start_codes)
                temp=data(strcmpi(water_restriction_start_codes{iCode},{data{:,3}}),2);
                if ~isempty(temp)
                    water_restriction_start = [water_restriction_start;datenum(temp)];
                end
            end
            water_restriction_start=floor(sort(water_restriction_start));
            prior_water_restriction=water_restriction_start(find(water_restriction_start<start_date,1,'Last'));
            if isempty(prior_water_restriction)
                %warning('DvMax_audit:NoRestrictionsFound',['could not find a water restriction start prior to the given start date for:' animalList(iMonkey).animalID,', ',animalList(iMonkey).animalName])
                prior_water_restriction = -1;%set value very small, comparison to real free water dates should show free water after this value. If both free water and restriction were empty, this value is smaller than the default for free water so the monkey will sort as on free water
            end
        %% get all water entries
            water_entry = [];
            for iWaterCodes = 1:length(water_codes)
                temp=data(strcmpi(water_codes{iWaterCodes},{data{:,3}}),2);
                if ~isempty(temp)
                    water_entry=[water_entry; datenum(temp)];     
                end
            end
            water_entry=floor(sort(water_entry));
            
            water_entry = sort([water_entry ; free_water_start ; water_restriction_start]);
            
        %% get all free food entries
            free_food_start = [];
            for iFreeFoodCodes = 1:length(free_food_codes)
                temp=data(strcmpi(free_food_codes{iFreeFoodCodes},{data{:,3}}),2);
                if ~isempty(temp)
                    free_food_start=[free_food_start;datenum(temp)];
                end
            end
            free_food_start=floor(sort(free_food_start));
            % Find first food restriction entry in list before the start date
            prior_free_food = free_food_start(find(free_food_start<start_date,1,'Last'));  
            if isempty(prior_free_food)
                %warning('DvMax_audit:NoFreeFoodFound',['could not find a free food start prior to the given start date for:' animalList(iMonkey).animalID,', ',animalList(iMonkey).animalName])
                prior_free_food = 0;%set value very small, comparison to real food restriction dates should show restriction dates after this value
            end
        %% get all food restriction start entries
            food_restriction_start=[];
            for iFoodRestrictionCodes = 1:length(food_restriction_start_codes)
                temp=data(strcmpi(food_restriction_start_codes{iFoodRestrictionCodes},{data{:,3}}),2);
                if ~isempty(temp)
                    food_restriction_start = [food_restriction_start;datenum(temp)];
                end
            end
            food_restriction_start=floor(sort(food_restriction_start));
            % Find first food restriction entry in list before the start date
            prior_food_restriction = food_restriction_start(find(food_restriction_start<start_date,1,'Last'));  
            if isempty(prior_food_restriction)
                %warning('DvMax_audit:NoFoodRestrictionFound',['could not find a food restriction start prior to the given start date for:' animalList(iMonkey).animalID,', ',animalList(iMonkey).animalName])
                prior_food_restriction = -1;%set value very small, comparison to real free food dates should show free food after this value. If both free food and restriction were empty, this value is smaller than the default for free food so the monkey will sort as on free food
            end
        %% get all food entries
            food_entry = [];
            for iFoodCodes = 1:length(food_codes)
                temp=data(strcmpi(food_codes{iFoodCodes},{data{:,3}}),2);
                if ~isempty(temp)
                    food_entry= [food_entry;datenum(temp)]; 
                end
            end
            food_entry=floor(sort(food_entry));
        %% set initial water restriction state
            is_water_restricted=prior_water_restriction>prior_free_water;
        %% set initial food restriction state
            is_food_restricted=prior_food_restriction>prior_free_food;
                
        %% loop through dates checking missing entries
        animalList(iMonkey).missed_water=[];
        animalList(iMonkey).missed_weight=[];
%         animalList(iMonkey).misplaced_weight=[];
        animalList(iMonkey).missed_food=[];
        for idate=start_date:end_date           
            
            prior_water_restriction=water_restriction_start(find(water_restriction_start<idate,1,'Last'));
            if isempty(prior_water_restriction)
                %warning('DvMax_audit:NoRestrictionsFound',['could not find a water restriction start prior to the given start date for:' animalList(iMonkey).animalID,', ',animalList(iMonkey).animalName])
                prior_water_restriction = -1;%set value very small, comparison to real free water dates should show free water after this value. If both free water and restriction were empty, this value is smaller than the default for free water so the monkey will sort as on free water
            end
            
            prior_food_restriction=food_restriction_start(find(food_restriction_start<idate,1,'Last'));
            if isempty(prior_food_restriction)
                %warning('DvMax_audit:NoRestrictionsFound',['could not find a water restriction start prior to the given start date for:' animalList(iMonkey).animalID,', ',animalList(iMonkey).animalName])
                prior_food_restriction = -1;%set value very small, comparison to real free water dates should show free water after this value. If both free water and restriction were empty, this value is smaller than the default for free water so the monkey will sort as on free water
            end
                        
%             if iMonkey == 7 && idate == 736006+2
%                 pause
%             end
            if is_water_restricted
                %check for water entry, if missing flag it
                if isempty(find(water_entry==idate,1))
                    animalList(iMonkey).missed_water=[animalList(iMonkey).missed_water;datestr(idate)];
                end
                %check for weight entry. if found update most recent weight
                %date If not found, compare current date to most recent 
                %date and flag if more than 7 days
                if isempty(find(body_weight==idate))                       
%                     this_day_entries = find(~cellfun(@isempty,strfind(data_dates,datestr(idate,'yyyy-mm-dd'))));                    
%                     for iEntry = 1:length(this_day_entries)
%                         weight_pos_in_entry = regexp(data{this_day_entries(iEntry),end},'Weight:')+7;
%                         if ~isempty(weight_pos_in_entry)
%                             car_return = regexp(data{this_day_entries(iEntry),end},'\n');
%                             car_return = car_return(find(car_return>weight_pos_in_entry,1,'first'));
%                             weight_in_entry = str2double(data{this_day_entries(iEntry),end}(weight_pos_in_entry:car_return));
%                             if last_weight+6<idate
%                                 animalList(iMonkey).misplaced_weight=[animalList(iMonkey).misplaced_weight;datestr(idate)];
%                             end
%                             if ~isnan(weight_in_entry)
%                                 last_weight=idate;
%                             end
%                         end                        
%                     end
                    if last_weight+7<idate && (prior_water_restriction < idate-7)
                        animalList(iMonkey).missed_weight=[animalList(iMonkey).missed_weight;datestr(idate)];
                    end
                else
                    last_weight=idate;
                end
                %check for stop of restriction and set restricted flag
                is_water_restricted= isempty(find(free_water_start==idate,1));
            else
                %check for start of restriction.
                is_water_restricted= ~isempty(find(water_restriction_start==idate,1));
                if is_water_restricted
                    % If started check for bottle entry, if missing flag it
                    if isempty(find(water_entry==idate,1))
                        animalList(iMonkey).missed_water=[animalList(iMonkey).missed_water;datestr(idate)];
                    end
                end
            end
            %repeat entry checks for food restriction:
            if is_food_restricted
                %check for food entry, if missing flag it
                if isempty(find(food_entry==idate,1))
                    animalList(iMonkey).missed_food=[animalList(iMonkey).missed_food;datestr(idate)];
                end
                %check for weight entry. if found update most recent weight
                %date If not found, compare current date to most recent 
                %date and flag if more than 7 days
                if isempty(find(body_weight==idate,1))
                    if last_weight+7<idate && (prior_food_restriction < idate-7)
                        animalList(iMonkey).missed_weight=[animalList(iMonkey).missed_weight;datestr(idate)];
                    end
                else
                    last_weight=idate;
                end
                %check for stop of restriction and set restricted flag
                is_food_restricted= isempty(find(free_food_start==idate,1));
            else
                %check for start of restriction.
                is_food_restricted= ~isempty(find(food_restriction_start==idate,1));
                if is_food_restricted
                    % If started check for food entry, if missing flag it
                    if isempty(find(food_entry==idate,1))
                        animalList(iMonkey).missed_food=[animalList(iMonkey).missed_food;datestr(idate)];
                    end
                end
            end
        end %end of loop across days
        if ~isempty(animalList(iMonkey).missed_weight)
            missed_weights = cellfun(@datenum,cellstr(animalList(iMonkey).missed_weight));
            iBlock = 1;
            missed_block = [];
            missed_dates = '';
            while true
                end_of_block = find(diff(missed_weights)>1,1,'first');
                if ~isempty(end_of_block)
                    missed_block(iBlock) = end_of_block; 
                    missed_dates(end+1,:) = datestr(missed_weights(1));
                    missed_weights = missed_weights(end_of_block+1:end);               
                    iBlock = iBlock+1;
                else
                    missed_block(iBlock) = length(missed_weights);
                    missed_dates(end+1,:) = datestr(missed_weights(1));
                    break
                end
            end
        else
            missed_block = [];
            missed_dates = [];
        end
        animalList(iMonkey).missed_weight_block_lengths = missed_block;
        animalList(iMonkey).missed_weight_block_dates = datestr(datenum(missed_dates)-7);
        
        
        this_audit_data = data((floor(datenum(data(:,2)))>=start_date & floor(datenum(data(:,2)))<=end_date),:);
        common_entries = lower({'EX1050','EP9000','EP8500','EP7000','Audit',...
            'BH1300','AC1480','Ex1060','Nt1100','Nt15000','LS1455',...
            'VA100','EP2000','EP9100','IS1350','EP1600','AC1080',...
            'AC2050','AC2000','AC1950','AC1975','IM2100','Bx1275',...
            'EX1325','IM2374','PLAN','EP9200 ','EX1100','AC1600',...
            'Hx8100','Hx8000','EX','EX1550','Rx1405','LS1260',...
            'Rx2000','IM1200','AC2075','AC1650',...
            'EX1500','LS1210','LS1452','Bx1276','Rx','Im','ac1060','LS',...
            'AC1360','Sx2225','Tx1300','BH','SX2200','Ax1400','AC1100',...
            'Nt6000','Rp1025','AC1700','IS','Sx2375','AC10','DS10',...
            'Tx1925','Ax1100','AC11','Tx1575','Tx1425','Tx1430','Sx1300',...
            'Dx1175','Nt9000','AC1275','AC1800','EP8700','EP9300','EP8600',...
            'EP9400','EP1000','AC1325','Bx1260'});
        for iCode = 1:length(common_entries)
            this_audit_data(~cellfun(@isempty,strfind(lower(this_audit_data(:,3)),common_entries{iCode})),:) = [];
        end
        
        disp(' ')
        disp(['Monkey: ' animalList(iMonkey).animalName '. CageCardID: ' animalList(iMonkey).cageID])        
        disp('Uncommon entries:')
        for iEntry = 1:size(this_audit_data,1)
            disp([datestr(this_audit_data(iEntry,2),26) '   ' this_audit_data{iEntry,3}  '   ' this_audit_data{iEntry,4}])
        end
        disp('Missed water:')
        disp(animalList(iMonkey).missed_water)
        disp('Missed food:')
        disp(animalList(iMonkey).missed_food)
        disp('Missed weight:')        
        if ~isempty(animalList(iMonkey).missed_weight_block_dates)
            disp([animalList(iMonkey).missed_weight_block_dates repmat('  -  ',length(animalList(iMonkey).missed_weight_block_lengths),1)...
                datestr(datenum(animalList(iMonkey).missed_weight_block_dates)+animalList(iMonkey).missed_weight_block_lengths'+6)...
                repmat('  -  ',length(animalList(iMonkey).missed_weight_block_lengths),1)...
                num2str((animalList(iMonkey).missed_weight_block_lengths+7)')])
        end
        disp(' ')
        
        %% if there were any missed entries print out text files with the list
        if do_save
            if ~isempty(animalList(iMonkey).missed_water)
                fname=[savepath animalList(iMonkey).animalID '_missed_water_entries.txt'];
                fid=fopen(fname,'w');
                for i=1:size(animalList(iMonkey).missed_water,1)
                    fprintf(fid,'%s\r\n',animalList(iMonkey).missed_water(i,:));
                end
                fclose(fid);
            end
            if ~isempty(animalList(iMonkey).missed_food)
                fname=[savepath animalList(iMonkey).animalID '_missed_food_entries.txt'];
                fid=fopen(fname,'w');
                for i=1:size(animalList(iMonkey).missed_food,1)
                    fprintf(fid,'%s\r\n',animalList(iMonkey).missed_food(i,:));
                end
                fclose(fid);
            end
            if ~isempty(animalList(iMonkey).missed_weight)
                fname=[savepath animalList(iMonkey).animalID '_missed_weight_entries.txt'];
                fid=fopen(fname,'w');
                for i=1:size(animalList(iMonkey).missed_weight,1)
                    fprintf(fid,'%s\r\n',animalList(iMonkey).missed_weight(i,:));
                end
                fclose(fid);
            end
        end
    end %end of loop across monkeys
    %% save whole animallist cell array 
        if do_save
            save(['Full_DvMax_audit_',datestr(date),'.mat'],'animalList')
        end
    %% close connections and finish audit
        disp('Finished checking DVMax')
        close(conn)
end
function animalList = load_animal_list(MonkeyWaterLocation)    
    [~,animal_xls,~] = xlsread(MonkeyWaterLocation,1);
    [~,people_xls,~] = xlsread(MonkeyWaterLocation,2);
    for iMonkey = 2:size(animal_xls,1)
        for iCol = 1:size(animal_xls,2)
            eval(['animalList(iMonkey-1).' animal_xls{1,iCol} ' = ''' animal_xls{iMonkey,iCol} ''';'])
        end
        for iPerson = 2:size(people_xls,1)
            if strcmpi(people_xls{iPerson,1},animalList(iMonkey-1).personInCharge)
                for iCol = 2:size(people_xls,2)
                    eval(['animalList(iMonkey-1).' people_xls{1,iCol} ' = ''' people_xls{iPerson,iCol} ''';'])
                end                
                break
            end  
        end
        for iPerson = 2:size(people_xls,1)
            if strcmpi(people_xls{iPerson,1},animalList(iMonkey-1).secondInCharge)
                for iCol = 2:size(people_xls,2)
                    eval(['animalList(iMonkey-1).secondary' people_xls{1,iCol} ' = ''' people_xls{iPerson,iCol} ''';'])
                end                
                break
            end
        end
    end    
end




