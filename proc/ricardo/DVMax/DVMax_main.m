function DVMax_main
    time = clock;
    time = time(4);
    [~,day_of_week] = weekday(now,'Long','en_US');
    
    import java.awt.Robot;
    import java.awt.event.*;
    robot = Robot;
    
    clc
    disp(['Starting DVMax checker on ' datestr(now)])
    
    animalList = load_animal_list();
    peopleList = load_people_list();
    
    water_codes = {'EP8500','EP9000'};
    free_water_codes = {'EP9200'};

    % Open browser and log in
    web('http://129.105.202.144:9421/login.shtml');
    pause(5)
    username = '';  % Enter your DVMax credentials here
    password = '';
    typestring(username)
    robot.keyPress(KeyEvent.VK_TAB)
    robot.keyRelease(KeyEvent.VK_TAB)
    pause(1)
    typestring(password)
    robot.keyPress(KeyEvent.VK_ENTER)
    robot.keyRelease(KeyEvent.VK_ENTER)
    pause(2)

    % Cycle through animal list
    animals_who_got_water = {};
    for iAnimal = 1:length(animalList)
        disp(['Checking monkey ' num2str(iAnimal) ' of ' num2str(length(animalList))])            
        responsible_for_monkey = eval(['animalList(iAnimal).' day_of_week ';']);
        
        if ~strcmpi(responsible_for_monkey,'ccm')         
            web(['http://129.105.202.144:9421/animal.shtml?action=viewAnimal&studyID=&animalID=' animalList(iAnimal).cageID])
            pause(5)

            animal_entry = [];
            counter = 0;
            counter_2 = 0;
            while isempty(strfind(animal_entry,'Back to Animal list'))
                counter = counter+1;
                if counter > 10
                    web(['http://129.105.202.144:9421/animal.shtml?action=viewAnimal&studyID=&animalID=' animalList(iAnimal).cageID])
                    pause(10)
                    counter_2 = counter_2+1;
                    counter = 0;
                end                
                robot.keyPress(KeyEvent.VK_TAB)
                robot.keyRelease(KeyEvent.VK_TAB)
                robot.keyPress(KeyEvent.VK_CONTROL)
                robot.keyPress(KeyEvent.VK_A)
                robot.keyRelease(KeyEvent.VK_A)
                robot.keyPress(KeyEvent.VK_C)
                robot.keyRelease(KeyEvent.VK_C)
                robot.keyRelease(KeyEvent.VK_CONTROL)
                pause(10)
                animal_entry = clipboard('paste');    
                if counter_2 > 3
                    disp(['Unable to confirm that ' animalList(iAnimal).animalName ' has received water today.'])
                    warning_DVMax(animalList(iAnimal),peopleList)
                    break
                end
            end
            animal_entry = animal_entry(7+strfind(animal_entry,'Vet/Exp'):end);        

            % Search for water codes
            last_free_water_entry = [];
            for iFreeWaterCodes = 1:length(free_water_codes)
                temp_entries = strfind(animal_entry,free_water_codes{iFreeWaterCodes});
                if ~isempty(temp_entries)
                    last_free_water_entry(end+1) = temp_entries(1);        %#ok<AGROW>  % Find first water entry in list
                end
            end
            if ~isempty(last_free_water_entry)
                last_free_water_entry = min(last_free_water_entry);     % Find first water entry in list
            else
                last_free_water_entry = 1000000;
            end

            last_water_entry = [];
            for iWaterCodes = 1:length(water_codes)
                temp_entries = strfind(animal_entry,water_codes{iWaterCodes});
                if ~isempty(temp_entries)
                    last_water_entry(end+1) = temp_entries(1);             %#ok<AGROW>
                end
            end
            if ~isempty(last_water_entry)
                last_water_entry = min(last_water_entry);
            else
                last_water_entry = 1000000;
            end              

            if last_water_entry < last_free_water_entry                 %% water restricted monkey
                last_water_entry_date = animal_entry(last_water_entry-8:last_water_entry-1);

    %             %TEST!
    %             last_water_entry_date = '04-Nov-2012';

                if ~strcmp(datestr(last_water_entry_date),date)
                    if time < 18
                        monkey_warning(animalList(iAnimal),'NoWater')
                        disp(['Warning: ' animalList(iAnimal).animalName ' has not received water today.'])
                    elseif time < 21
                        monkey_last_warning(animalList(iAnimal),peopleList)
                        disp(['Last warning: ' animalList(iAnimal).animalName ' has not received water today.'])
                    else
                        monkey_emergency(animalList(iAnimal),peopleList)
                        disp(['Emergency: ' animalList(iAnimal).animalName ' has not received water today!'])
                    end
                else
                    animals_who_got_water{end+1} = animalList(iAnimal).animalName;
                    disp([animalList(iAnimal).animalName ' received water today.'])
                end
            elseif last_water_entry > last_free_water_entry                 %% free water monkey
                animals_who_got_water{end+1} = animalList(iAnimal).animalName;
                disp([animalList(iAnimal).animalName ' is on free water.'])
            else
                animals_who_got_water{end+1} = animalList(iAnimal).animalName;
                disp([animalList(iAnimal).animalName ' has no water restriction record.'])
    %             monkey_warning(animalList(iAnimal),'NoRecord')
            end
            web('http://129.105.202.144:9421/index.shtml')
            pause(3)
        else
            animals_who_got_water{end+1} = [animalList(iAnimal).animalName ' (CCM responsibility)'];
        end
    end
        
    if time > 20 && time < 23
        if length(animals_who_got_water)==length(animalList)
            monkey_final_list(animalList,peopleList)
        end
    end
    disp('Finished checking DVMax')
end

function typestring(str)
import java.awt.Robot;
import java.awt.event.*;
robot = Robot;
    for iStr = 1:length(str)
        switch str(iStr)
            case ':'
                robot.keyPress(KeyEvent.VK_SHIFT);
                robot.keyPress(KeyEvent.VK_SEMICOLON);
                robot.keyRelease(KeyEvent.VK_SEMICOLON);
                robot.keyRelease(KeyEvent.VK_SHIFT);
            case '?'
                robot.keyPress(KeyEvent.VK_SHIFT);
                robot.keyPress(KeyEvent.VK_SLASH);
                robot.keyRelease(KeyEvent.VK_SLASH);
                robot.keyRelease(KeyEvent.VK_SHIFT);
            case '&'
                robot.keyPress(KeyEvent.VK_SHIFT);
                robot.keyPress(KeyEvent.VK_7);
                robot.keyRelease(KeyEvent.VK_7);
                robot.keyRelease(KeyEvent.VK_SHIFT);
            otherwise
                if isstrprop(str(iStr),'upper')
                    robot.keyPress(KeyEvent.VK_SHIFT)
                end
                robot.keyPress(double(upper(str(iStr))))
                robot.keyRelease(double(upper(str(iStr))))
                if isstrprop(str(iStr),'upper')
                    robot.keyRelease(KeyEvent.VK_SHIFT)
                end
        end
    end
end

function monkey_warning(animal,messageType)
    recepients{1} = animal.contactEmail;
    if ~isempty(animal.secondInCharge)
        recepients = {recepients{:},animal.secondarycontactEmail};
    end
    if strcmp(messageType,'NoWater')
        subject = '(this is a test) Your monkey has not received water';
        message = {[animal.animalName ' (' animal.animalID ') has not received water as of ' datestr(now) '.'],...
            'Sent from Matlab! This is a test.'};
    elseif strcmp(messageType,'NoRecord')
        subject = '(this is a test) Your monkey has no water restriction record';
        message = {[animal.animalName ' (' animal.animalID ') has no water restriction record.'],...
            'Sent from Matlab! This is a test.'};
    end
    send_mail_message(recepients,subject,message)    
end

function monkey_last_warning(animal,peopleList)
    for iP = 1:length(peopleList)
        if strcmp(animal.personInCharge,peopleList(iP).Name)
            person_in_charge = iP;
            break;
        end
    end
    second_in_charge = [];
    for iP = 1:length(peopleList)
        if strcmp(animal.secondInCharge,peopleList(iP).Name)
            second_in_charge = iP;
            break;
        end
    end
    receipients = {};
    for iP = 1:length(peopleList)
        receipients = {recepients{:} peopleList(iP).contactEmail};  
    end
    subject = ['(this is a test) Last warning: ' animal.animalName ' has not received water!'];
    if ~isempty(second_in_charge)
        message = {[animal.animalName ' (' animal.animalID ') has not received water as of ' datestr(now) '.'],...
            ['Person in charge: ' peopleList(person_in_charge).Name '(' peopleList(person_in_charge).contactNumber ')'],...
            ['Second in charge: ' peopleList(second_in_charge).Name '(' peopleList(second_in_charge).contactNumber ')'],...
            'Sent from Matlab! This is a test.'};
    else
        message = {[animal.animalName ' (' animal.animalID ') has not received water as of ' datestr(now) '.'],...
            ['Person in charge: ' peopleList(person_in_charge).Name '(' peopleList(person_in_charge).contactNumber ')'],...                
            'Sent from Matlab! This is a test.'};
    end    
    send_mail_message(receipients,subject,message)
end

function monkey_emergency(animal,peopleList)
    for iP = 1:length(peopleList)
        if strcmp(animal.personInCharge,peopleList(iP).Name)
            person_in_charge = iP;
            break;
        end
    end
    for iP = 1:length(peopleList)
        subject = ['(this is a test) Emergency: ' animal.animalName ' has not received water!'];
        message = {[animal.animalName ' (' animal.animalID ') has not received water as of ' datestr(now) '.'],...
            ['Person in charge: ' peopleList(person_in_charge).Name '(' peopleList(person_in_charge).contactNumber ')'],...
            'Sent from Matlab! This is a test.'};
        send_mail_message(peopleList(iP).contactEmail,subject,message)
    end
end

function monkey_final_list(animalList,peopleList)
    for iP = 1:length(peopleList)
        subject = ['(this is a test) All monkeys received water'];
        message = {'The following monkeys received water today:'};
        for iAnimal = 1:length(animalList)
            message = {message{:},animalList(iAnimal).animalName};
        end 
        
        message = {message{:},'Sent from Matlab! This is a test.'};
        send_mail_message(peopleList(iP).contactEmail,subject,message)
    end
end

function warning_DVMax(animal,peopleList)
     for iP = 1:length(peopleList)
        subject = ['(this is a test) Warning: DVMAx_checker could not confirm that ' animal.animalName ' received water today'];               
        message = {'Sent from Matlab! This is a test.'};
        send_mail_message(peopleList(iP).contactEmail,subject,message)
     end
end

function animalList = load_animal_list()    
    [~,animal_xls,~] = xlsread('MonkeyWaterData.xlsx',1);
    [~,people_xls,~] = xlsread('MonkeyWaterData.xlsx',2);
    for iAnimal = 2:size(animal_xls,1)
        for iCol = 1:size(animal_xls,2)
            eval(['animalList(iAnimal-1).' animal_xls{1,iCol} ' = ''' animal_xls{iAnimal,iCol} ''';'])
        end
        for iPerson = 2:size(people_xls,1)
            if strcmp(people_xls{iPerson,1},animalList(iAnimal-1).personInCharge)
                for iCol = 2:size(people_xls,2)
                    eval(['animalList(iAnimal-1).' people_xls{1,iCol} ' = ''' people_xls{iPerson,iCol} ''';'])
                end                
                break
            end  
        end
        for iPerson = 2:size(people_xls,1)
            if strcmp(people_xls{iPerson,1},animalList(iAnimal-1).secondInCharge)
                for iCol = 2:size(people_xls,2)
                    eval(['animalList(iAnimal-1).secondary' people_xls{1,iCol} ' = ''' people_xls{iPerson,iCol} ''';'])
                end                
                break
            end
        end
    end    
end

function peopleList = load_people_list()    
    [~,people_xls,~] = xlsread('MonkeyWaterData.xlsx',2);
    for iPerson = 2:size(people_xls,1)
        for iCol = 1:size(people_xls,2)
            eval(['peopleList(iPerson-1).' people_xls{1,iCol} ' = ''' people_xls{iPerson,iCol} ''';'])
        end  
    end 
end
% robot control
% robot.mouseMove(0, 0);
% screenSize = get(0, 'screensize');
% for i = 100
% robot.mouseMove(i, i);
% pause(0.00001);
% end
% robot.mousePress(InputEvent.BUTTON1_MASK);
% robot.mouseRelease(InputEvent.BUTTON1_MASK);