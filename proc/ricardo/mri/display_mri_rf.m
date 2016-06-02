function display_mri_rf(mri_data,excel_file,stereotax_opts,options)

if nargin <4
    xmmperpix=1;
    ymmperpix=1;
    mmperslice=1;
else
    xmmperpix=options.xresolution;
    ymmperpix=options.yresolution;
    mmperslice=options.zresolution;
end

figure
[ndata, headertext] = xlsread('tikimap.xls', 'coor');
xtra=strmatch('name', headertext);
for i =1 : length(xtra);
    pen(i)=(ndata(xtra(i),1));
    lenti(i)=length(ndata(xtra(i)+2,:))-(length(find(isnan(ndata(xtra(i)+2,:))==1)));
end

CMS = stereotax_opts.CMS;
CMM = stereotax_opts.CMM;
ang = stereotax_opts.ang;
x_crop = 50;
y_crop = 50;

ap_list = CMS(1)-(ndata(xtra+1,1)-(CMM(1)));

for v =1 :  length(xtra) 
    for i =1 : lenti(v)    
        ml_list(v,i) = CMS(2)-((CMM(2)-(ndata(xtra(v)+1,2)))*cosd(ang))+(sind(ang)*((ndata(xtra(v)+1,3))-(ndata(xtra(v)+2,i))));
    end
end

mean_ml = mean(ml_list(ml_list~=0));
ap_list_short = unique(ap_list);

hold on;
for plot_num=1:length(ap_list_short)      
    subplot(2,4,plot_num)
    ap_loc = ap_list_short(plot_num);
    ap_index = find(ap_list == ap_loc);
    imagesc(mri_data(round(end/2)+(-x_crop+1:x_crop),round(end/2)+(-y_crop+1:y_crop),round(end/2+ap_loc)));
    colormap(gray)
    xticks = 10:10:2*x_crop;   
    set(gca,'XTick',[1 xticks],'XTickLabel',[-x_crop xticks-x_crop])
    yticks = 10:10:2*y_crop;   
    set(gca,'YTick',[1 yticks],'YTickLabel',[-y_crop yticks-y_crop])
    set (gca,'dataaspectratio',[ymmperpix mmperslice xmmperpix],'YDir','normal');
    hold on   
    xlim([1 2*x_crop])
    ylim([1 2*y_crop])
    i = 1;
    ml_loc = CMS(2)-((CMM(2)-(ndata(xtra(ap_index)+1,2)))*cosd(ang))+(sind(ang)*((ndata(xtra(ap_index)+1,3))-(ndata(xtra(ap_index)+2,i))));   
    plot([x_crop+ml_loc x_crop+ml_loc],[1 2*y_crop],'white');
    [x_temp y_temp] = ginput(1);
    cortex_z = y_temp-y_crop;
    imagesc(mri_data(round(end/2)+(-x_crop+1:x_crop),round(end/2)+(-y_crop+1:y_crop),round(end/2+ap_loc)));
    title(['AP ' num2str(ap_loc)])
    for v = ap_index(1):ap_index(end)
        for i=1:lenti(v)
            ml_loc = CMS(2)-((CMM(2)-(ndata(xtra(v)+1,2)))*cosd(ang))+(sind(ang)*((ndata(xtra(v)+1,3))-(ndata(xtra(v)+2,i))));
            depth = ((ndata(xtra(v)+2,i))-(ndata(xtra(v)+1,3)));        

    %       text(CMS(2)-(CMM(2)-(ndata(xtra(v)+1,2))),0,num2str(pen(v)))
            plot(x_crop+ml_loc,depth+cortex_z+y_crop,char(headertext(xtra(v)+3,i+1)),...
                'MarkerFaceColor',char(headertext(xtra(v)+4,i+1)),...
                'MarkerEdgeColor',char(headertext(xtra(v)+4,i+1)));
        end
    end
end

figure
ap_loc = mean(ap_list_short);
imagesc(mri_data(round(end/2)+(-x_crop+1:x_crop),round(end/2)+(-y_crop+1:y_crop),round(end/2+ap_loc)));
colormap(gray)
xticks = 10:10:2*x_crop;   
set(gca,'XTick',[1 xticks],'XTickLabel',[-x_crop xticks-x_crop])
yticks = 10:10:2*y_crop;   
set(gca,'YTick',[1 yticks],'YTickLabel',[-y_crop yticks-y_crop])
set (gca,'dataaspectratio',[ymmperpix mmperslice xmmperpix],'YDir','normal');
hold on   
xlim([1 2*x_crop])
ylim([1 2*y_crop])
i = 1;
ml_loc = CMS(2)-((CMM(2)-(ndata(xtra(ap_index)+1,2)))*cosd(ang))+(sind(ang)*((ndata(xtra(ap_index)+1,3))-(ndata(xtra(ap_index)+2,i))));   
plot([x_crop+ml_loc x_crop+ml_loc],[1 2*y_crop],'white');
[x_temp y_temp] = ginput(1);
cortex_z = y_temp-y_crop;
imagesc(mri_data(round(end/2)+(-x_crop+1:x_crop),round(end/2)+(-y_crop+1:y_crop),round(end/2+ap_loc)));
title(['AP ' num2str(ap_loc,2)])
for v = 1:length(xtra)
    for i=1:lenti(v)
        ml_loc = CMS(2)-((CMM(2)-(ndata(xtra(v)+1,2)))*cosd(ang))+(sind(ang)*((ndata(xtra(v)+1,3))-(ndata(xtra(v)+2,i))));
        depth = ((ndata(xtra(v)+2,i))-(ndata(xtra(v)+1,3)));        

%       text(CMS(2)-(CMM(2)-(ndata(xtra(v)+1,2))),0,num2str(pen(v)))
        plot(x_crop+ml_loc,depth+cortex_z+y_crop,char(headertext(xtra(v)+3,i+1)),...
            'MarkerFaceColor',char(headertext(xtra(v)+4,i+1)),...
            'MarkerEdgeColor',char(headertext(xtra(v)+4,i+1)));
    end
end

figure
sag_loc = mean_ml;
z_crop = 50;
imagesc(squeeze(mri_data(round(end/2)+(-x_crop+1:x_crop),round(end/2+sag_loc),round(end/2)+(-z_crop+1:z_crop))));
colormap(gray)
zticks = 10:10:2*z_crop;   
set(gca,'XTick',[1 zticks],'XTickLabel',[-z_crop zticks-z_crop])
yticks = 10:10:2*y_crop;   
set(gca,'YTick',[1 yticks],'YTickLabel',[-y_crop yticks-y_crop])
set (gca,'dataaspectratio',[ymmperpix mmperslice xmmperpix],'YDir','normal');
hold on   
xlim([1 2*z_crop])
ylim([1 2*y_crop])
i = 1;
ap_loc = CMS(1)-(ndata(xtra(v)+1,1)-(CMM(1))),((ndata(xtra(v)+2,i))-(ndata(xtra(v)+1,3)));
plot([x_crop-ap_loc x_crop-ap_loc],[1 2*y_crop],'white');
[x_temp y_temp] = ginput(1);
cortex_z = y_temp;
imagesc(squeeze(mri_data(round(end/2)+(-x_crop+1:x_crop),round(end/2+sag_loc),round(end/2)+(-z_crop+1:z_crop))));
title(['Sag ' num2str(sag_loc,2)])

for v =1:length(xtra)
    for i =1:lenti(v)
        ap_loc = CMS(1)-(ndata(xtra(v)+1,1)-(CMM(1))),((ndata(xtra(v)+2,i))-(ndata(xtra(v)+1,3)));
        depth = ((ndata(xtra(v)+2,i))-(ndata(xtra(v)+1,3)));
        plot(x_crop-ap_loc,depth+cortex_z,char(headertext(xtra(v)+3,i+1)),...
            'MarkerFaceColor',char(headertext(xtra(v)+4,i+1)),...
            'MarkerEdgeColor',char(headertext(xtra(v)+4,i+1)));
    end
end
