GoogleDriveID = '0AtEH4EqHWe9JdDRaY0dOWUJhMGpia0VoRHhzSGc1LVE';

result = GetGoogleSpreadsheet(GoogleDriveID);
colors =    [1 1 0;...
            .6 1 0;...
            0 .75 1;...
            1 .27 0];

% Avery labels 5160
y_offset = 0.5;
x_offset = 3/8;
label_width = 2 + 5/8;
label_height = 1;
num_rows = 10;
num_cols = 3;

% Find interesting data
AnimalCell = cell(size(result));
AnimalCell(:) = {'Animal'};
[AnimalY AnimalX] = find(cellfun(@strcmp,result,AnimalCell));

SupervisorCell = cell(size(result));
SupervisorCell(:) = {'Supervisor Check'};
[SupervisorY SupervisorX] = find(cellfun(@strcmp,result,SupervisorCell));

num_rooms = length(AnimalX);
num_days = size(result,2) - AnimalX;

labelData = {};
color_order = [];
for iRoom = 1:num_rooms
    datestemp = result(AnimalY(iRoom)-1,AnimalX(iRoom)+1:end); 
    datatemp = result(AnimalY(iRoom)+1:SupervisorY(iRoom)-1,AnimalX(iRoom):end);
    for iDate = 1:length(datestemp)
        for iAnimal = 1:length(datatemp)
            if ~isempty(datatemp{iAnimal,iDate+1})
                labelData{end+1} = {datestemp{iDate};datatemp{iAnimal,1};datatemp{iAnimal,iDate+1}};
                color_order(end+1) = iDate;
            end
        end
    end
end
    
num_pages = ceil(length(labelData)/30);
for iPage = 1:num_pages
    page_data = labelData((iPage-1)*30+1:min((iPage)*30,length(labelData)));
    page_colors = color_order((iPage-1)*30+1:min((iPage)*30,length(labelData)));
    h = figure;
    set(gca,'YDir','reverse','units','inches','Position',[0 0 8.5 11])
    xlim([0 8.5])
    ylim([0 11])    
    axis equal
    axis off
    set(h,'Units','inches')
    set(h,'PaperType','usletter')
    set(h,'PaperPosition',[0 0 8.5 11])
    set(h,'Position',[0 0 8.5 11])
    hold on
    
%     for iLabel = 1:length(page_data)
    iLabel = 0;
    for iRow = 1:num_rows
        for iCol = 1:num_cols
            iLabel = iLabel+1;
%         iRow = floor((iLabel-1)/3)+1;
%         iCol = mod(iLabel-1,3);
            x = x_offset + (iCol-1)*label_width + 0.5 * label_width;
            y = y_offset + (iRow)*label_height + 0.5 * label_height;
            if iLabel <= length(page_data)
                fill([x-0.5*label_width x+0.5*label_width x+0.5*label_width x-0.5*label_width],...
                   [y+0.5*label_height y+0.5*label_height y-0.5*label_height y-0.5*label_height],...
                   colors(page_colors(iLabel),:))        
                text(x,y,page_data{iLabel},'VerticalAlignment','middle',...
                    'HorizontalAlignment','center','FontSize',18)
            else
                fill([x-0.5*label_width x+0.5*label_width x+0.5*label_width x-0.5*label_width],...
                   [y+0.5*label_height y+0.5*label_height y-0.5*label_height y-0.5*label_height],...
                   [1 1 1]) 
            end
        end
    end
end
