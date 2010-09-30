function display_mri(mri_data, rot_params, options)

if nargin == 2
    xmmperpix=1;
    ymmperpix=1;
    mmperslice=1;
else
    xmmperpix=options.xresolution;
    ymmperpix=options.yresolution;
    mmperslice=options.zresolution;
end

pixx=size(mri_data,2);
pixy=size(mri_data,3);
nslices=size(mri_data,1);

figure
subplot(2,2,1)
imagesc(squeeze(mri_data(round(size(mri_data,1)/2),:,:)));
colormap(gray);
xticks = 1:size(mri_data,3)/4:size(mri_data,3)+1;
set(gca,'XTick',xticks,'XTickLabel',xticks-size(mri_data,3)/2-1)
yticks = 1:size(mri_data,2)/4:size(mri_data,2)+1;
set(gca,'YTick',yticks,'YTickLabel',-(yticks-size(mri_data,2)/2-1))
set (gca,'dataaspectratio',[xmmperpix ymmperpix mmperslice]);
hold on
plot([size(mri_data,3)/2 size(mri_data,3)/2],get(gca,'YLim'),'white')
plot(get(gca,'Xlim'),[size(mri_data,2)/2 size(mri_data,2)/2],'white')

subplot(2,2,2)
% imagesc(squeeze(mri_data(:,round(size(mri_data,2)/2),:)));
imagesc(squeeze(mri_data(:,round(size(mri_data,2)/2-18),:)));
xticks = 1:size(mri_data,3)/4:size(mri_data,3)+1;
set(gca,'XTick',xticks,'XTickLabel',xticks-size(mri_data,3)/2-1)
yticks = 1:size(mri_data,1)/4:size(mri_data,1)+1;
set(gca,'YTick',yticks,'YTickLabel',-(yticks-size(mri_data,1)/2-1))
set(gca,'dataaspectratio',[ymmperpix mmperslice xmmperpix],'YDir','normal');
hold on
plot([size(mri_data,3)/2 size(mri_data,3)/2],get(gca,'YLim'),'white')
plot(get(gca,'Xlim'),[size(mri_data,1)/2 size(mri_data,1)/2],'white')

subplot(2,2,3)
imagesc(squeeze(mri_data(:,:,round(size(mri_data,3)/2))));
xticks = 1:size(mri_data,2)/4:size(mri_data,2)+1;
set(gca,'XTick',xticks,'XTickLabel',xticks-size(mri_data,2)/2-1)
yticks = 1:size(mri_data,1)/4:size(mri_data,1)+1;
set(gca,'YTick',yticks,'YTickLabel',-(yticks-size(mri_data,1)/2-1))
set (gca,'dataaspectratio',[ymmperpix mmperslice xmmperpix],'YDir','normal');
hold on
plot([size(mri_data,2)/2 size(mri_data,2)/2],get(gca,'YLim'),'white')
plot(get(gca,'Xlim'),[size(mri_data,1)/2 size(mri_data,1)/2],'white')
