function DVMax_checker()
    testing = 0;    
    maintainer_email_address = 'ricardort@gmail.com';
    
    try
        % Add JDBC driver to path
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

        MonkeyWaterLocation = '\\citadel\limblab\lab_folder\Lab-Wide Animal Info\WeekendWatering\MonkeyWaterData.xlsx';
        water_codes = {'EP8500','EP9000','EP2000','AC1091'};
        free_water_codes = {'EP9200 ','AC1093'};
        water_restriction_start_codes = {'EP9100','AC1092'};
        food_codes = {'EP8600','EP8700'};
        free_food_codes = {'EP9400'};
        food_restriction_start_code = 'EP9300';
        time = clock;
        time = time(4);

        conn = database('OR','dvmax_lmiller','dvmax','Vendor','Oracle',...
            'DriverType','thin','Server','risdatsvr3.itcs.northwestern.edu','PortNumber',1521);    
        try
            load('animalList')
            oldAnimalList = animalList;
            oldAnimalList2 = rmfield(oldAnimalList,'idealBodyWeight');
            oldAnimalList2 = rmfield(oldAnimalList2,'contactNumber');
            oldAnimalList2 = rmfield(oldAnimalList2,'secondarycontactNumber');
            oldAnimalList2 = rmfield(oldAnimalList2,'dateOfWeightUpdate');
        end

        animalList = load_animal_list(MonkeyWaterLocation);
        save('animalList','animalList')    
        animalList2 = rmfield(animalList,'idealBodyWeight');
        animalList2 = rmfield(animalList2,'contactNumber');
        animalList2 = rmfield(animalList2,'secondarycontactNumber');
        animalList2 = rmfield(animalList2,'dateOfWeightUpdate');

        peopleList = load_people_list(MonkeyWaterLocation);
        ccmList = load_ccm_list(MonkeyWaterLocation);    

        if ~isequal(animalList2,oldAnimalList2)
            send_monkey_person_email(animalList,peopleList,ccmList)
        end

        [~,weekend_water_xls,~] = xlsread(MonkeyWaterLocation,3);   
        weekendWaterList = weekend_water_xls(2:end,2:end);

        [~,weekend_food_xls,~] = xlsread(MonkeyWaterLocation,4); 
        weekendFoodList = weekend_food_xls(2:end,2:end);

        todaysDate = datenum(date);
        weekendDates = datenum(weekendWaterList(1,2:end));
        today_is_a_holiday = find(todaysDate == weekendDates)+1;

        animals_who_got_water = {};
        animals_who_got_food = {};
        for iMonkey = 1:length(animalList)
            animalList(iMonkey).animalName;
            cagecardID = animalList(iMonkey).cageID;
            cagecardID(strfind(cagecardID,'C')) = [];
            exestring= ['select distinct cage_card_id, datetime_performed_cst, med_rec_code, med_description, comments'...
               ' from granite_reports.dvmax_med_rec_entries_vw where cage_card_id=' cagecardID 'order by datetime_performed_cst asc'];
            data = fetch(conn,exestring);
            data = data(end:-1:1,:);

            body_weight_entries = find(~cellfun(@isempty,strfind(data(:,3),'EX1050')));
            body_weight_idx = cellfun(@strfind,data(body_weight_entries,5),repmat({'Weight: '},length(body_weight_entries),1),'UniformOutput',false);
            units_idx = cellfun(@strfind,data(body_weight_entries,5),repmat({'Units: '},length(body_weight_entries),1),'UniformOutput',false);
            units_idx_2 = cellfun(@strfind,data(body_weight_entries,5),repmat({'(kg)'},length(body_weight_entries),1),'UniformOutput',false);
            units_idx_3 = cellfun(@strfind,data(body_weight_entries,5),repmat({'kg'},length(body_weight_entries),1),'UniformOutput',false);
            units_idx(cellfun(@isempty,units_idx)) = {inf};
            units_idx_2(cellfun(@isempty,units_idx_2)) = {inf};
            units_idx_3(cellfun(@isempty,units_idx_3)) = {inf};
            units_idx_3 = cellfun(@min,units_idx_3);
            units_idx = cellfun(@min,units_idx,units_idx_2);
            units_idx = min(units_idx,units_idx_3);
            animalList(iMonkey).body_weight = [];
            animalList(iMonkey).body_weight_date = [];
            for iEntry = 1:length(body_weight_entries)
                if ~isempty(body_weight_idx{iEntry})
                    try
                        animalList(iMonkey).body_weight(end+1) = str2num(data{body_weight_entries(iEntry),5}(body_weight_idx{iEntry}+8 : units_idx(iEntry)-2));
                        animalList(iMonkey).body_weight_date(end+1) = floor(datenum(data{body_weight_entries(iEntry),2}));
                    end
                end
            end

            if today_is_a_holiday
                ccm_in_charge_water = weekendWaterList{find(strcmpi(weekendWaterList(:,1),['CC' cagecardID])),today_is_a_holiday};
                ccm_in_charge_water = strcmpi(ccm_in_charge_water,'ccm');
                ccm_in_charge_food = weekendFoodList{find(strcmpi(weekendFoodList(:,1),['CC' cagecardID])),today_is_a_holiday};
                ccm_in_charge_food = strcmpi(ccm_in_charge_food,'ccm');
            else
                ccm_in_charge_water = 0;
                ccm_in_charge_food = 0;
            end
            animalList(iMonkey).restricted = 0;
            check_weight = 0;

            if ccm_in_charge_water 
                animals_who_got_water{end+1} = animalList(iMonkey).animalName;
                disp([animalList(iMonkey).animalName ' was bottled by CCM.'])
                animalList(iMonkey).bottled_by = 'CCM';
            else            
                last_free_water_entry = [];
                for iFreeWaterCodes = 1:length(free_water_codes)
                    temp = find(strcmpi(free_water_codes{iFreeWaterCodes},{data{:,3}}),1,'first');
                    if ~isempty(temp)
                        last_free_water_entry(end+1) = temp; %#ok<AGROW>
                    end
                end
                if ~isempty(last_free_water_entry)
                    last_free_water_entry = min(last_free_water_entry);     % Find first water entry in list
                else
                    last_free_water_entry = 1000000;
                end

                last_water_entry = [];
                for iWaterCodes = 1:length(water_codes)
                    temp = find(strcmpi(water_codes{iWaterCodes},{data{:,3}}),1,'first');
                    if ~isempty(temp)
                        last_water_entry(end+1) = temp; %#ok<AGROW>
                    end      
                end
                if ~isempty(last_water_entry)
                    last_water_entry = min(last_water_entry);
                else
                    last_water_entry = 1000000;
                end

                last_water_restriction_start = inf;
                for iCode = 1:length(water_restriction_start_codes)
                    temp = find(strcmpi(water_restriction_start_codes{iCode},{data{:,3}}),1,'first');
                    if isempty(temp)
                        temp = inf;
                    end
                    last_water_restriction_start = min(last_water_restriction_start,temp);
                end
                if isempty(last_water_restriction_start)
                    last_water_restriction_start = 1000000;
                end

                if last_water_restriction_start < last_free_water_entry                 %% water restricted monkey
                    check_weight = 1;
                    animalList(iMonkey).restricted = 1;
                    last_water_entry_date = data{last_water_entry,2};
                    if floor(datenum(last_water_entry_date)) ~= datenum(date)                    
                        if time < 18
                            monkey_warning(animalList(iMonkey),'NoWater',testing,maintainer_email_address)
                            disp(['Warning: ' animalList(iMonkey).animalName ' has not received water today.'])
                        else %if time < 21
                            monkey_last_warning(animalList(iMonkey),peopleList,'NoWater',testing,maintainer_email_address)
                            disp(['Last warning: ' animalList(iMonkey).animalName ' has not received water today.'])
    %                     else
    %                         monkey_emergency(animalList(iMonkey),peopleList,testing)
    %                         disp(['Emergency: ' animalList(iMonkey).animalName ' has not received water today!'])
                        end
                    else
                        animals_who_got_water{end+1} = animalList(iMonkey).animalName;
                        disp([animalList(iMonkey).animalName ' received water today.'])
                        animalList(iMonkey).bottled_by = 'lab';
                    end
                elseif last_water_restriction_start > last_free_water_entry       %% free water monkey
                    animals_who_got_water{end+1} = animalList(iMonkey).animalName;
                    disp([animalList(iMonkey).animalName ' is on free water.'])
                    animalList(iMonkey).bottled_by = 'free water';
                else
                    animals_who_got_water{end+1} = animalList(iMonkey).animalName;
                    disp([animalList(iMonkey).animalName ' has no water restriction record.'])
                    animalList(iMonkey).bottled_by = 'no water restriction record';
                end       
            end

            if ccm_in_charge_food
                animals_who_got_food{end+1} = animalList(iMonkey).animalName;
                disp([animalList(iMonkey).animalName ' was fed by CCM.'])       
                animalList(iMonkey).fed_by = 'CCM';
            else            
                last_free_food_entry = [];
                for iFreeFoodCodes = 1:length(free_food_codes)
                    temp = find(strcmpi(free_food_codes{iFreeFoodCodes},{data{:,3}}),1,'first');
                    if ~isempty(temp)
                        last_free_food_entry(end+1) = temp; %#ok<AGROW>
                    end
                end
                if ~isempty(last_free_food_entry)
                    last_free_food_entry = min(last_free_food_entry);     % Find first water entry in list
                else
                    last_free_food_entry = 1000000;
                end

                last_food_entry = [];
                for iFoodCodes = 1:length(food_codes)
                    temp = find(strcmpi(food_codes{iFoodCodes},{data{:,3}}),1,'first');
                    if ~isempty(temp)
                        last_food_entry(end+1) = temp; %#ok<AGROW>
                    end      
                end
                if ~isempty(last_food_entry)
                    last_food_entry = min(last_food_entry);
                else
                    last_food_entry = 1000000;
                end              

                last_food_restriction_start = find(strcmpi(food_restriction_start_code,{data{:,3}}),1,'first');
                if isempty(last_food_restriction_start)
                    last_food_restriction_start = 1000000;
                end

                if last_food_restriction_start < last_free_food_entry                 %% food restricted monkey
                    check_weight = 1;
                    animalList(iMonkey).restricted = 1;
                    last_food_entry_date = data{last_food_entry,2};
                    if floor(datenum(last_food_entry_date)) ~= datenum(date)                    
                        if time < 18
                            monkey_warning(animalList(iMonkey),'NoFood',testing,maintainer_email_address)
                            disp(['Warning: ' animalList(iMonkey).animalName ' has not received food today.'])
                        else %if time < 21
                            monkey_last_warning(animalList(iMonkey),peopleList,'NoFood',testing,maintainer_email_address)
                            disp(['Last warning: ' animalList(iMonkey).animalName ' has not received food today.'])
    %                     else
    %                         monkey_emergency(animalList(iMonkey),peopleList,testing)
    %                         disp(['Emergency: ' animalList(iMonkey).animalName ' has not received water today!'])
                        end
                    else
                        animals_who_got_food{end+1} = animalList(iMonkey).animalName;
                        disp([animalList(iMonkey).animalName ' received food today.'])
                        animalList(iMonkey).fed_by = 'lab';
                    end
                elseif last_food_restriction_start > last_free_food_entry       %% free food monkey
                    animals_who_got_food{end+1} = animalList(iMonkey).animalName;
                    disp([animalList(iMonkey).animalName ' is not food restricted.'])
                    animalList(iMonkey).fed_by = 'CCM';
                else
                    animals_who_got_food{end+1} = animalList(iMonkey).animalName;
                    disp([animalList(iMonkey).animalName ' has no food restriction record.'])
                    animalList(iMonkey).fed_by = 'CCM';
                end       
            end   


        % Monkey weight warning
        if check_weight        
            if time < 18            
                lastWeighing = (animalList(iMonkey).body_weight_date(1));
                if datenum(date) - lastWeighing > 4 
                    disp(['Warning: ' animalList(iMonkey).animalName ' has not been weighed in ' num2str(datenum(date) - lastWeighing) ' day(s).'])
                    monkey_weight_warning(animalList(iMonkey),lastWeighing,testing,maintainer_email_address);
                end
            end
        end        

        if time >= 18 %&& time < 23
            if (length(animals_who_got_water)==length(animalList) &&...
                    length(animals_who_got_food)==length(animalList))
                monkey_final_list(animalList,peopleList,testing,maintainer_email_address)
            end
        end
        end

        %% Body weight
        if time >= 18 && weekday(date) == 2   
            gf = figure;
            monkey_counter = 0;
            num_plots = 3;
            for iPlot = 1:num_plots
                subplot(num_plots,1,iPlot)
                hold on            
                legend_text = {};
                monkey_list = [1:floor(length(animalList)/num_plots)]+floor(length(animalList)/num_plots)*(iPlot-1);
                if iPlot == num_plots && mod(length(animalList),num_plots)
                    monkey_list = [monkey_list monkey_list(end)+mod(length(animalList),num_plots)];
                end
                colors = distinguishable_colors_2(length(monkey_list),{'w'});
                color_idx = 0;
                hp = [];
                for iMonkey = monkey_list
                    if animalList(iMonkey).restricted
                        animalList(iMonkey).days_since_last_weighing = num2str((datenum(date)-animalList(iMonkey).body_weight_date(1)));
                    else
                        animalList(iMonkey).days_since_last_weighing = 'FW';
                    end
                    color_idx = color_idx+1;
                    if ~isempty(animalList(iMonkey).body_weight_date)
                        hp(end+1) = plot(animalList(iMonkey).body_weight_date,animalList(iMonkey).body_weight,'Color',colors(color_idx,:),'LineWidth',2);   
                        if str2double(animalList(iMonkey).idealBodyWeight)
                            plot(animalList(iMonkey).body_weight_date([1 end]),[str2double(animalList(iMonkey).idealBodyWeight) str2double(animalList(iMonkey).idealBodyWeight)],'LineStyle','--','Color',colors(color_idx,:));
                        end
                        legend_text{end+1} = [animalList(iMonkey).animalName ' ' num2str(round(100*(animalList(iMonkey).body_weight(1)/str2double(animalList(iMonkey).idealBodyWeight) - 1))) '%. (' animalList(iMonkey).days_since_last_weighing ')'];
                    end
                end        
                set(gca,'XTick',[datenum('2013-01-01'):182:datenum(date)])
                datetick('x',26,'keepticks')   
                xlim([datenum('2013-01-01') datenum(date)])                             
                legend(hp,legend_text,'Location','West')
            end
            print(gf,'BodyWeights','-dpng')        
            body_weight_email(animalList,peopleList,testing,maintainer_email_address)
        end        

        disp('Finished checking DVMax')
        close(conn)
        pause(10)
    catch ME
        dvmax_crash_email(maintainer_email_address,ME)
    end
end

function animalList = load_animal_list(MonkeyWaterLocation)    
    [animal_xls_num,animal_xls,~] = xlsread(MonkeyWaterLocation,1);
    [~,people_xls,~] = xlsread(MonkeyWaterLocation,2);
    for iMonkey = 2:size(animal_xls,1)
        for iCol = 1:size(animal_xls,2)
            if isempty(animal_xls{iMonkey,iCol})
                eval(['animalList(iMonkey-1).' animal_xls{1,iCol} ' = ''' num2str(animal_xls_num(iMonkey-1)) ''';'])
            else
                eval(['animalList(iMonkey-1).' animal_xls{1,iCol} ' = ''' animal_xls{iMonkey,iCol} ''';'])
            end
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

function peopleList = load_people_list(MonkeyWaterLocation)    
    [~,people_xls,~] = xlsread(MonkeyWaterLocation,2);
    for iPerson = 2:size(people_xls,1)
        for iCol = 1:size(people_xls,2)
            eval(['peopleList(iPerson-1).' people_xls{1,iCol} ' = ''' people_xls{iPerson,iCol} ''';'])
        end  
    end 
end

function ccmList = load_ccm_list(MonkeyWaterLocation)
    [~,ccm_xls,~] = xlsread(MonkeyWaterLocation,5);
    for iPerson = 2:size(ccm_xls,1)
        for iCol = 1:size(ccm_xls,2)
            eval(['ccmList(iPerson-1).' ccm_xls{1,iCol} ' = ''' ccm_xls{iPerson,iCol} ''';'])
        end  
    end 
end

% function weekendList = load_weekend_list(MonkeyWaterLocation)    
%     [~,weekend_xls,~] = xlsread(MonkeyWaterLocation,3);   
%     weekendList = weekend_xls(2:end,2:end);
% end

function monkey_warning(animal,messageType,testing,maintainer_email_address)
    if testing
        recepients = maintainer_email_address;
        if strcmpi(messageType,'NoWater')
        subject = '(this is a test) Your monkey has not received water';
        message = {[animal.animalName ' (' animal.animalID ') has not received water as of ' datestr(now) '.'],...
            'Sent from Matlab! This is a test.'};
        elseif strcmpi(messageType,'NoFood')
            subject = '(this is a test) Your monkey has not received food';
            message = {[animal.animalName ' (' animal.animalID ') has not received food as of ' datestr(now) '.'],...
                'Sent from Matlab! This is a test.'};
        elseif strcmpi(messageType,'NoRecord')
            subject = '(this is a test) Your monkey has no water restriction record';
            message = {[animal.animalName ' (' animal.animalID ') has no water restriction record.'],...
                'Sent from Matlab! This is a test.'};
        end
        message_sent = 0;
        while (~message_sent)
            try
                send_mail_message(recepients,subject,message)                
                message_sent = 1;  
            catch
                message_sent
                pause(5)
            end
        end
    else
        recepients{1} = animal.contactEmail;
        if ~isempty(animal.secondInCharge)
            recepients = {recepients{:},animal.secondarycontactEmail};
        end
        if strcmpi(messageType,'NoWater')
            subject = 'Your monkey has not received water';
            message = {[animal.animalName ' (' animal.animalID ') has not received water as of ' datestr(now) '.'],...
                'Sent from Matlab!'};
        elseif strcmpi(messageType,'NoFood')
            subject = 'Your monkey has not received food';
            message = {[animal.animalName ' (' animal.animalID ') has not received food as of ' datestr(now) '.'],...
                'Sent from Matlab!'};
        
        elseif strcmpi(messageType,'NoRecord')
            subject = 'Your monkey has no water restriction record';
            message = {[animal.animalName ' (' animal.animalID ') has no water restriction record.'],...
                'Sent from Matlab!'};
        end
        message_sent = 0;
        while (~message_sent)
            try
                send_mail_message(recepients,subject,message)                
                message_sent = 1;  
            catch
                pause(5)
            end
        end
    end           
end

function monkey_last_warning(animal,peopleList,message,testing,maintainer_email_address)
    if strcmpi(message,'NoWater')
        message = 'water';
    else
        message = 'food';
    end
    for iP = 1:length(peopleList)
        if strcmpi(animal.personInCharge,peopleList(iP).Name)
            person_in_charge = iP;
            break;
        end
    end
    second_in_charge = [];
    for iP = 1:length(peopleList)
        if strcmpi(animal.secondInCharge,peopleList(iP).Name)
            second_in_charge = iP;
            break;
        end
    end
    recepients = {};
    
    if testing
        recepients = maintainer_email_address;
        subject = ['(this is a test) Last warning: ' animal.animalName ' has not received ' message '!'];
    else
       	recepients = {peopleList.contactEmail};       
        subject = ['Last warning: ' animal.animalName ' has not received ' message '!'];
    end    
    
    if ~isempty(second_in_charge)
        message = {[animal.animalName ' (' animal.animalID ') has not received ' message ' as of ' datestr(now) '.'],...
            ['Person in charge: ' peopleList(person_in_charge).Name '(' peopleList(person_in_charge).contactNumber ')'],...
            ['Second in charge: ' peopleList(second_in_charge).Name '(' peopleList(second_in_charge).contactNumber ')'],...
            'Sent from Matlab!'};
    else
        message = {[animal.animalName ' (' animal.animalID ') has not received ' message ' as of ' datestr(now) '.'],...
            ['Person in charge: ' peopleList(person_in_charge).Name '(' peopleList(person_in_charge).contactNumber ')'],...                
            'Sent from Matlab!'};
    end    
    message_sent = 0;
    while (~message_sent)
        try
            send_mail_message(recepients,subject,message)
            message_sent = 1;            
        catch
            pause(5)
        end
    end
end

function monkey_final_list(animalList,peopleList,testing,maintainer_email_address)
    recepients = {};
    if testing
        recepients = maintainer_email_address;
        subject = ['(this is a test) All monkeys received water and food'];
        message = {'The following monkeys received water and food today:'};
        for iMonkey = 1:length(animalList)
            message = {message{:},[animalList(iMonkey).animalName ' -      water: ' animalList(iMonkey).bottled_by '    food: ' animalList(iMonkey).fed_by]};
        end 
        message = {message{:},'Sent from Matlab! This is a test.'};
        send_mail_message(recepients,subject,message)
    else
        for iP = 1:length(peopleList)
            recepients = {recepients{:} peopleList(iP).contactEmail};
        end
        subject = ['All monkeys received water and food'];
        message = {'The following monkeys received water and food today:'};
        for iMonkey = 1:length(animalList)
            message = {message{:},[animalList(iMonkey).animalName ' -       water: ' animalList(iMonkey).bottled_by '    food: ' animalList(iMonkey).fed_by]};
        end 
        message = {message{:},'Sent from Matlab!'};
            message_sent = 0;
        while (~message_sent)
            try
                send_mail_message(recepients,subject,message)
                message_sent = 1;            
            catch
                pause(5)
            end
        end
    end    
end

function send_monkey_person_email(animalList,peopleList,ccmList)
    subject = 'NHP caretaker list update';
    message_table = {};
    for iAnimal = 1:length(animalList)
        temp = length([animalList(iAnimal).animalID ' - ' animalList(iAnimal).animalName ':']);
        message_table{iAnimal} = [animalList(iAnimal).animalID ' - ' animalList(iAnimal).animalName ':' repmat(' ',1,25-temp) animalList(iAnimal).personInCharge...
            ' (' animalList(iAnimal).contactEmail '), ' animalList(iAnimal).secondInCharge ' (' animalList(iAnimal).secondarycontactEmail ')'];   
    end
    message = [{'Hi everyone, '} {''} {'This is the current list of monkeys and their caretakers from the Miller lab. You will automatically receive '...
        'a new email whenever this list changes.'} {''} message_table {''} {['If you don''t want to receive these emails anymore please email ' maintainer_email_address '.']}...
        {''} {'Best regards,'} {'Miller Lab'}];
    recepients = [{ccmList.contactEmail} {peopleList.contactEmail}];
    send_mail_message(recepients,subject,message)
end

function body_weight_email(animalList,peopleList,testing,maintainer_email_address)    
    if testing
        recepients = maintainer_email_address;
        subject = ['(this is a test) Weekly body weights update'];
    else
       	recepients = {peopleList.contactEmail};       
        subject = ['Weekly body weights update'];
    end    

    message = {'Here''s the weekly monkey body weight update.  Don''t forget to make body weight entries (EX1050) every week!';...
        'The numbers in parentheses are the numbers of days since the last EX1050 entry.'};
 
    message_sent = 0;
    while (~message_sent)
        try
            send_mail_message(recepients,subject,message,'BodyWeights.png')
            message_sent = 1;            
        catch
            pause(5)
        end
    end
end

function monkey_weight_warning(animal,lastWeighing,testing,maintainer_email_address)
    if testing
        recepients = maintainer_email_address;        
        subject = ['(this is a test) ' animal.animalName ' does not have a weight entry from the past 5 days.'];
        message = {[animal.animalName ' (' animal.animalID ') has not been weighed since ' datestr(lastWeighing) '.'],...
            'Sent from Matlab! This is a test.'};        
        message_sent = 0;
        while (~message_sent)
            try
                send_mail_message(recepients,subject,message)                
                message_sent = 1;  
            catch
                message_sent
                pause(5)
            end
        end
    else
        recepients{1} = animal.contactEmail;
        if ~isempty(animal.secondInCharge)
            recepients = {recepients{:},animal.secondarycontactEmail};
        end
        subject = [animal.animalName ' does not have a weight entry from the past 5 days.'];
        message = {[animal.animalName ' (' animal.animalID ') has not been weighed since ' datestr(lastWeighing) '.'],...
            'Sent from Matlab!'};          
        message_sent = 0;
        while (~message_sent)
            try
                send_mail_message(recepients,subject,message)                
                message_sent = 1;  
            catch
                pause(5)
            end
        end
    end           
end

function dvmax_crash_email(maintainer_email_address,ME)
    recepients = maintainer_email_address;    
    subject = 'DVMax checker crashed.';
    message = {ME.identifier;ME.message;ME.stack(1).file;['line: ' num2str(ME.stack(1).line)]}; 
    send_mail_message(recepients,subject,message)    
end