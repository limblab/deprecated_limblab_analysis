function animalList=DvMax_audit(varargin)
    %checks DvMax for missed water, food and weight entries
    
    
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
    free_water_codes = {'EP9200 ','AC1093'};
    water_restriction_start_codes = {'EP9100','AC1092'};
    food_codes = {'EP8600','EP8700','EP1000'};
    free_food_codes = {'EP9400'};
    food_restriction_start_code = 'EP9300';
    
    do_save=0;
    start_date=datenum('1-Oct-2013');
    end_date=datenum(date);
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
    %% loop across all monkeys, checking each one
    for iMonkey = 1:length(animalList)
        %% get the info for this specific monkey
            cagecardID = animalList(iMonkey).cageID;
            cagecardID(strfind(cagecardID,'C')) = [];
            exestring= ['select distinct cage_card_id, datetime_performed_cst, med_rec_code, med_description, comments'...
               ' from granite_reports.dvmax_med_rec_entries_vw where cage_card_id=' cagecardID 'order by datetime_performed_cst asc'];
            data = fetch(conn,exestring);
            data = data(end:-1:1,:);
        %% get all body weights entries
            body_weight = datenum(data(strcmpi('EX1050',{data{:,3}}),2));
            body_weight =floor(sort(body_weight));
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
            temp=data(strcmpi(food_restriction_start_code,{data{:,3}}),2);
            if ~isempty(temp)
                food_restriction_start = datenum(temp);
            else
                food_restriction_start =[];
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
        animalList(iMonkey).missed_food=[];
        for idate=start_date:end_date
            if is_water_restricted
                %check for water entry, if missing flag it
                if isempty(find(water_entry==idate,1))
                    animalList(iMonkey).missed_water=[animalList(iMonkey).missed_water;datestr(idate)];
                end
                %check for weight entry. if found update most recent weight
                %date If not found, compare current date to most recent 
                %date and flag if more than 7 days
                if isempty(find(body_weight==idate))
                    if last_weight+6<idate
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
                    if last_weight+6<idate
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




