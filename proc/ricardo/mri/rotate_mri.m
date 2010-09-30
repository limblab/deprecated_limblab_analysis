function [rotated_mri,p] = rotate_mri(mri_data,learbar, rearbar, leyebar, reyebar, midline)

p0=[0,0,0,-(learbar(1)+rearbar(1))/2,-mean(midline(2,:)), ...
    -(learbar(3)+rearbar(3)+reyebar(3)+leyebar(3))/4];

p=fminsearch(@(params) mrierr(params,learbar,rearbar,leyebar,reyebar,midline),p0,...
    optimset ('maxfunevals',1000000,'tolfun',1e-8,'tolx',1e-8));

rotation_angle_trans = 180*p(1)/pi;
rotation_angle_sag = -180*p(2)/pi;
rotation_angle_cor = 180*p(3)/pi;
Y_trans = mri_data;

% translation_params = round([-p(4)-size(mri_data,1)/2 p(5)+size(mri_data,2)/2 p(6)+size(mri_data,3)/2]);
translation_params = round([-p(6)-size(mri_data,1)/2,...
                            -p(5)-size(mri_data,2)/2,...
                            -p(4)-size(mri_data,3)/2]);

if translation_params(1)>=0
    Y_trans(1:end-translation_params(1),:,:) = Y_trans(translation_params(1)+1:end,:,:);
else
    Y_trans(-translation_params(1):end,:,:) = Y_trans(1:end+translation_params(1)+1,:,:);
end

if translation_params(2)>=0
    Y_trans(:,1:end-translation_params(2),:) = Y_trans(:,translation_params(2)+1:end,:);
else
    Y_trans(:,-translation_params(2):end,:) = Y_trans(:,1:end+translation_params(2)+1,:);
end

if translation_params(3)>=0
    Y_trans(:,:,1:end-translation_params(3)) = Y_trans(:,:,translation_params(3)+1:end);
else
    Y_trans(:,:,-translation_params(3):end) = Y_trans(:,:,1:end+translation_params(3)+1);
end

Y_rot = Y_trans;
if rotation_angle_sag~=0
    for i = 1:size(mri_data,2)
        Y_rot(:,i,:) = imrotate(squeeze(Y_rot(:,i,:)),rotation_angle_sag,'bicubic','crop');
    end
end

if rotation_angle_cor~=0
    for i = 1:size(mri_data,3)
        Y_rot(:,:,i) = imrotate(squeeze(Y_rot(:,:,i)),rotation_angle_cor,'bicubic','crop');
    end
end

if rotation_angle_trans~=0
    for i = 1:size(mri_data,1)
        Y_rot(i,:,:) = imrotate(squeeze(Y_rot(i,:,:)),rotation_angle_trans,'bicubic','crop');
    end
end

% Y_trans = Y_rot;
% if translation_params(3)>=0
%     Y_trans(:,:,1:end-translation_params(3)) = Y_trans(:,:,translation_params(3)+1:end);
% else
%     Y_trans(:,:,-translation_params(3):end) = Y_trans(:,:,1:end+translation_params(3)+1);
% end

rotated_mri = Y_rot;