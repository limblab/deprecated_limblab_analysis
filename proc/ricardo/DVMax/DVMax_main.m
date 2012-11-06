function DVMax_main
    clc
    disp(['Starting DVMax checker on ' datestr(now)])
    web http://129.105.202.144:9421/login.shtml -browser

    pause(5)
    username = 'rtorres';
    password = '';
    animalList = struct('cageID',{},'animalID',{},'animalName',{},'personInCharge',{},'contactNumber',{},'contactEmail',{});

    animalList(1).cageID = 'CC557936';
    animalList(1).animalID = '12A2';
    animalList(1).animalName = 'Kevin';
    animalList(1).personInCharge = 'Ricardo';
    animalList(1).contactNumber = '312-970-0062';
    animalList(1).contactEmail = 'ricardort@gmail.com';

    water_codes = {'EP8500','EP9000'};

    import java.awt.Robot;
    import java.awt.event.*;
    robot = Robot;

    % Open browser and login
    typestring(username)
    robot.keyPress(KeyEvent.VK_TAB)
    typestring(password)
    robot.keyPress(KeyEvent.VK_ENTER)
    robot.keyRelease(KeyEvent.VK_ENTER)
    pause(2)

    % Go to address line
    robot.keyPress(KeyEvent.VK_CONTROL)
    robot.keyPress(KeyEvent.VK_L)
    robot.keyRelease(KeyEvent.VK_CONTROL)
    robot.keyRelease(KeyEvent.VK_L)

    % Cycle through animal list
    for iAnimal = 1:length(animalList)
        disp(['Checking monkey ' num2str(iAnimal) ' of ' num2str(length(animalList))])
        animal_url = ['http://129.105.202.144:9421/animal.shtml?action=viewAnimal&studyID=&animalID=' animalList(iAnimal).cageID];
        typestring(animal_url)
        robot.keyPress(KeyEvent.VK_ENTER)
        robot.keyRelease(KeyEvent.VK_ENTER)
        pause(2)
        robot.keyPress(KeyEvent.VK_CONTROL)
        robot.keyPress(KeyEvent.VK_A)
        robot.keyRelease(KeyEvent.VK_A)
        robot.keyPress(KeyEvent.VK_C)
        robot.keyRelease(KeyEvent.VK_C)
        robot.keyRelease(KeyEvent.VK_CONTROL)
        pause(.5)
        animal_entry = clipboard('paste');    
        animal_entry = animal_entry(8+strfind(animal_entry,'Vet/Exp'):end);
        
        % Search for water codes
        for iWaterCodes = 1:length(water_codes)
            temp_entries = strfind(animal_entry,water_codes{iWaterCodes});
            last_water_entry(iWaterCodes) = temp_entries(1);
        end
        last_water_entry = last_water_entry(1);
        last_water_entry_date = animal_entry(last_water_entry-9:last_water_entry-2);
        if ~strcmp(datestr(last_water_entry_date),date)
            monkey_warning(animalList(iAnimal))
        else
            disp([animalList(iAnimal).animalName ' received water'])
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

function monkey_warning(animal)
    message = {[animal.animalName ' (' animal.animalID ') has not received water as of ' datestr(now) '.'],...
        'Sent from Matlab! (And Kevin got water, this is just a test)'};
    send_mail_message(animal.contactEmail,'Your monkey has not received water',message)
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