WaterSheetFile = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\Lab-Wide Animal Info\WeekendWatering\';
% WaterSheetFile = [WaterSheetFile '2016-01-30 weekend water and food Miller-Slutzky.xlsx'];
WaterSheetFile = [WaterSheetFile '2016-09-24 weekend water and food Miller-Slutzky.xlsx'];
% WaterSheetFile = [WaterSheetFile 'Weekend water and food Miller-HPs.xlsx'];
WeekendWateringFile = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\Lab-Wide Animal Info\WeekendWatering\MonkeyWaterData.xlsx';
[~,WeekendWatering] = xlsread(WeekendWateringFile,3);
existing_watering_weekends = datenum(WeekendWatering(2,3:end));
[~,WeekendFeeding] = xlsread(WeekendWateringFile,4);
existing_feeding_weekends = datenum(WeekendFeeding(2,3:end));
[WaterSheetNum,WaterSheetText,WaterSheetRaw] = xlsread(WaterSheetFile,1);
result = WaterSheetRaw;

if strfind(WaterSheetFile,'Weekend water and food Miller-HPs')
    %     ;)
    write_excel = 0;
else
    write_excel = 1;
end

% result = GetGoogleSpreadsheet(GoogleDriveID);
colors =    [1 1 0;...
            .6 1 0;...
            0 .75 1;...
            1 .27 0];

% Avery labels 5160 (buy Avery 6460, they are the same size and easier to peel off)
y_offset = 0.5;
% x_offset = 3/8;
x_offset = 3/16;
% label_width = 2 + 5/8;
label_width = (8.5-2*x_offset)/3;
label_height = 1;
num_rows = 8;
num_cols = 3;
%%
% Find interesting data
AnimalCell = cell(size(result));
AnimalCell(:) = {'Animal'};
[AnimalY,AnimalX] = find(cellfun(@strcmp,result,AnimalCell));

SupervisorCell = cell(size(result));
SupervisorCell(:) = {'Supervisor Check'};
[SupervisorY,SupervisorX] = find(cellfun(@strcmp,result,SupervisorCell));

num_rooms = length(AnimalX);
num_days = (size(result,2) - AnimalX)/2;

labelData = {};
color_order = [];


for iRoom = 1:num_rooms
    daystemp = result(AnimalY(iRoom)-1,AnimalX(iRoom)+1:end); 
    daystemp = daystemp(~cellfun(@isempty,daystemp));
    daystemp = {daystemp{find(~cellfun(@sum,cellfun(@isnan,daystemp,'UniformOutput',false)))}};
    datestemp = result(AnimalY(iRoom),AnimalX(iRoom)+1:end);    
    datestemp = datestemp(~cellfun(@isempty,datestemp));
    datestemp = {datestemp{find(~cellfun(@sum,cellfun(@isnan,datestemp,'UniformOutput',false)))}};
    datatemp = result(AnimalY(iRoom)+1:SupervisorY(iRoom)-1,AnimalX(iRoom):end);
    for iDate = 1:length(daystemp)
        if ~isnan(daystemp{iDate})
            if datenum(datestemp{iDate}) < datenum(date)
                error('Date on spreadsheet is in the past, check spreadsheet ID or date')
            end
            [~,day_of_week] = weekday(datestemp{iDate});
            if ~strcmpi(day_of_week,daystemp{iDate})
                error([datestemp{iDate} ' is not a ' daystemp{iDate} '. Fix dates on spreadsheet'])
            end
            
            if write_excel
                if ~sum(existing_watering_weekends==datenum(datestemp{iDate}))
                    water_col = xlsColNum2Str(2+length(existing_watering_weekends)+iDate);
                    range = strcat(water_col{1},'1');
                    [~,day] = weekday(datestemp{iDate},'long');
                    xlswrite(WeekendWateringFile,{day},3,range);
                    range = strcat(water_col{1},'2');
                    xlswrite(WeekendWateringFile,{datestemp{iDate}},3,range);            
                else
                    water_col = xlsColNum2Str(2+find(existing_watering_weekends==datenum(datestemp{iDate})));
                end
                if ~sum(existing_feeding_weekends==datenum(datestemp{iDate}))
                    food_col = xlsColNum2Str(2+length(existing_feeding_weekends)+iDate);
                    range = strcat(food_col{1},'1');
                    [~,day] = weekday(datestemp{iDate},'long');
                    xlswrite(WeekendWateringFile,{day},4,range);
                    range = strcat(food_col{1},'2');
                    xlswrite(WeekendWateringFile,{datestemp{iDate}},4,range);            
                else
                    food_col = xlsColNum2Str(2+find(existing_feeding_weekends==datenum(datestemp{iDate})));
                end
            end
            
            for iAnimal = 1:size(datatemp,1)
                if ~isempty(datatemp{iAnimal,2*iDate})
    %                 if sum(isstrprop(datatemp{iAnimal,2*iDate}, 'digit'))
                    if isnumeric(datatemp{iAnimal,2*iDate}) && ~isnan(datatemp{iAnimal,2*iDate})
                        labelData{end+1} = {daystemp{iDate};datatemp{iAnimal,1};datatemp{iAnimal,2*iDate}};
                        color_order(end+1) = iDate;
                        if write_excel
                            excel_water_row = (strfind({WeekendWatering{:,1}},datatemp{iAnimal,1}(find(datatemp{iAnimal,1}==' ',1,'last')+1:end)));
                            excel_water_row = find(~cellfun(@isempty,excel_water_row));
                            range = strcat(water_col{1},num2str(excel_water_row));                        
                            xlswrite(WeekendWateringFile,{'CCM'},3,range); 
                        end
                    elseif ~isnan(datatemp{iAnimal,1})
    %                     excel_water_row = (strfind({WeekendWatering{:,1}},datatemp{iAnimal,1}(find(datatemp{iAnimal,1}==' ',1,'last')+1:end)));
    %                     excel_water_row = find(~cellfun(@isempty,excel_water_row));  
                        if write_excel
                            excel_water_row = (strfind({WeekendWatering{:,1}},datatemp{iAnimal,1}(find(datatemp{iAnimal,1}==' ',1,'last')+1:end)));
                            excel_water_row = find(~cellfun(@isempty,excel_water_row));
                            if ~isempty(excel_water_row)
                                range = strcat(water_col{1},num2str(excel_water_row));
                                if strcmp(datatemp{iAnimal,2*iDate},'Free water')
                                    xlswrite(WeekendWateringFile,{'CCM'},3,range);
                                else
                                    xlswrite(WeekendWateringFile,{''},3,range); 
                                end
                            end
                        end
                    end            
                end
            end
            for iAnimal = 1:size(datatemp,1)
                if write_excel
                    if ~isempty(datatemp{iAnimal,2*iDate+1})
        %                 if sum(isstrprop(datatemp{iAnimal,2*iDate+1}, 'digit'))   
                        if isnumeric(datatemp{iAnimal,2*iDate+1})  && ~isnan(datatemp{iAnimal,2*iDate+1})
                            excel_food_row = (strfind({WeekendFeeding{:,1}},datatemp{iAnimal,1}(find(datatemp{iAnimal,1}==' ',1,'last')+1:end)));
                            excel_food_row = find(~cellfun(@isempty,excel_food_row));
                            range = strcat(food_col{1},num2str(excel_food_row));
                            xlswrite(WeekendWateringFile,{'CCM'},4,range); 
                        elseif ~isnan(datatemp{iAnimal,1})
                            excel_food_row = (strfind({WeekendFeeding{:,1}},datatemp{iAnimal,1}(find(datatemp{iAnimal,1}==' ',1,'last')+1:end)));
                            excel_food_row = find(~cellfun(@isempty,excel_food_row));
                            if ~isempty(excel_food_row)
                                range = strcat(food_col{1},num2str(excel_food_row));
                                xlswrite(WeekendWateringFile,{''},4,range); 
                            end
                        end  
                    end
                end
            end
        end
    end
end
%%  
num_pages = ceil(length(labelData)/30);
for iPage = 1:num_pages
    page_data = labelData((iPage-1)*30+1:min((iPage)*30,length(labelData)));
    page_colors = color_order((iPage-1)*30+1:min((iPage)*30,length(labelData)));
    h = figure;    
    hold on
    set(h,'Units','inches')
    set(h,'PaperUnits','inches')
    set(h,'PaperType','usletter')
    set(h,'PaperPositionMode','manual')
    set(h,'Clipping','off')
    
    a = ver;
    if str2double(a(strcmp({a.Name},'MATLAB')).Version) < 8.3
        set(h,'PaperPosition',[0 0 8.5 11-2*label_height])
        set(h,'Position',[0 -1 8.5 11-2*label_height])
    else
%         set(h,'PaperPosition',[0.375 0.25 7.75 11])
%         set(h,'Position',[0 0 7.75 10]).
        set(h,'PaperPosition',[x_offset y_offset+10-num_rows*label_height 8.5-2*x_offset 11-2*y_offset-2*label_height]) 
        set(h,'Position',[x_offset y_offset 8.5-2*x_offset 11-2*y_offset-2*label_height])               
    end
    set(gca,'YDir','reverse','units','inches')    
    hold on  
    set(gca,'Clipping','off')
    iLabel = 0;
    patch([0 8.5-2*x_offset 8.5-2*x_offset 0],...
       [11-2*y_offset-2*label_height 11-2*y_offset-2*label_height 0 0],...
       [1 1 1],'LineStyle','none','Clipping','off')
    for iRow = 1:num_rows
        for iCol = 1:num_cols
            iLabel = iLabel+1;
            x = 0*x_offset + (iCol-1)*label_width + 0.5 * label_width;
            y = 0*y_offset + (iRow-1)*label_height + 0.5 * label_height;
            if iLabel <= length(page_data) 
                patch([x-0.5*label_width x+0.5*label_width x+0.5*label_width x-0.5*label_width],...
                   [y+0.5*label_height y+0.5*label_height y-0.5*label_height y-0.5*label_height],...
                   [1 1 1],'LineStyle','none','Clipping','off')
                patch([x-0.35*label_width x+0.5*label_width x+0.5*label_width x-0.35*label_width],...
                   [y+0.5*label_height y+0.5*label_height y-0.5*label_height y-0.5*label_height],...
                   colors(page_colors(iLabel),:),'LineStyle','none','Clipping','off')  
                text(x,y,page_data{iLabel},'VerticalAlignment','middle',...
                    'HorizontalAlignment','center','FontSize',18)
                text(x-0.425*label_width,y,{'Fold here'},'Rotation',90,'VerticalAlignment','middle',...
                    'HorizontalAlignment','center','FontSize',9)
            else
               fill([x-0.5*label_width x+0.5*label_width x+0.5*label_width x-0.5*label_width],...
                   [y+0.5*label_height y+0.5*label_height y-0.5*label_height y-0.5*label_height],...
                   [1 1 1],'LineStyle','none')
            end
        end
    end
    drawnow        

%     set(gca,'Position',[0 0 8.5-2*x_offset 10])
    set(gca,'YDir','reverse','units','inches','Position',[0 0 8.5-2*x_offset 11-2*y_offset-2*label_height])
    xlim([0 8.5-2*x_offset])
    ylim([0 11-2*y_offset-2*label_height])   
%     ylim([-2.5 8.5])    
%     axis equal
    axis off  
    
    if str2double(a(strcmp({a.Name},'MATLAB')).Version) > 8.3
        temp = get(h,'Position');
%         ylim([temp(4)-num_rows temp(4)])
    end
end
