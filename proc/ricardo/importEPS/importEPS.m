filepath = 'D:\Data\Kevin_12A2\MRI_2012-10-18\T1_rotated_processed\';
filelist = {'','_2','_3','_4','_5','_6','_7','_8','_9','_10','_11'};
ml_coord = -12:-1:-22;
figure;
gca = axes;

mesh_points = [];

for iFile = 1:length(filelist)
    filename = ['Cicerone1.0_Picture_05-02-2013' filelist{iFile} '.eps'];
    copyfile([filepath filename],[filepath filename(1:end-3) 'txt']);

    file_ID = fopen([filepath filename(1:end-3) 'txt'],'r','n','windows-1252');
    % C = textscan(file_ID,'%s');
    C = fread(file_ID,inf,'char');
    fclose(file_ID);

    crs = find(C==13);
    all_text = cell(length(crs),1);

    old_last_idx = 0;
    for iLine = 1:length(crs)
        all_text{iLine} = char(C(old_last_idx+1:crs(iLine)-1))';
        old_last_idx = crs(iLine);
    end

    line_starts = regexp(all_text,'[0-9] mo$');
    line_starts = find(~cellfun('isempty',line_starts));
    line_starts = [line_starts;inf];

    vertices = regexp(all_text,'[0-9] li$');
    vertices = find(~cellfun('isempty',vertices));

    vert_cell = cell(length(line_starts)-1,1);
    for iLine = 1:length(line_starts)-1
        temp = all_text(line_starts(iLine):...
            vertices(find(vertices<line_starts(iLine+1),1,'last')));
        for iVert = 1:length(temp)
            temp_vert = regexp(temp{iVert},' ','split');
            vert_cell{iLine}(iVert,:) = [str2num(temp_vert{1}) str2num(temp_vert{2})];
        end
        if (size(vert_cell{iLine},1)==5 && min(vert_cell{iLine}(:))>10)
            %Scale bar
            scale = (max(vert_cell{iLine}(:,2))-min(vert_cell{iLine}(:,2)))/4;
        end
    end
    for iLine = 1:length(vert_cell)
        vert_cell{iLine} = vert_cell{iLine}/scale;
    end

    hold on
    for iVert = 1:length(vert_cell)
        if length(vert_cell{iVert})>5
            plot3(vert_cell{iVert}(:,1),repmat(ml_coord(iFile),size(vert_cell{iVert},1),1),...
                -vert_cell{iVert}(:,2),'-b')
            mesh_points = [mesh_points; vert_cell{iVert}(:,1) repmat(ml_coord(iFile),size(vert_cell{iVert},1),1)...
                -vert_cell{iVert}(:,2)];
        else
            plot3(vert_cell{iVert}(:,1),repmat(ml_coord(iFile),size(vert_cell{iVert},1),1),...
                -vert_cell{iVert}(:,2),'.k')
        end
        if length(vert_cell{iVert})==2
            plot3(vert_cell{iVert}(:,1),repmat(ml_coord(iFile),size(vert_cell{iVert},1),1),...
                -vert_cell{iVert}(:,2),'-r')
        end
    end
end
h = get(gca,'DataAspectRatio');
if h(3)==1
    set(gca,'DataAspectRatio',[1 1 1/max(h(1:2))])
else
    set(gca,'DataAspectRatio',[1 1 h(3)])
end
axis equal
% xlim([0 700])
% ylim([-700 0])
% figure;
% mesh(mesh_points(:,1),mesh_points(:,2),mesh_points(:,3))
triangles = delaunay(mesh_points(:,1),mesh_points(:,2),mesh_points(:,3));

