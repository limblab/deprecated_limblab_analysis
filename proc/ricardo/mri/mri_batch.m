% MRI batch
subject = 'Pedro_4C2';
switch subject
    case 'Tiki_4C1'
        shortpath = 'D:\Data\Tiki_4C1\MRI\';
        longpath = 'DICOM\09070609\09420000\';
        datapath = [shortpath longpath];
        patientName = '4c1-tiki';
        seriesNo = 3;
        disp_options.xresolution = 1;
        disp_options.yresolution = 1;
        disp_options.zresolution = 1;
        excel_file = 'tikimap.xls';
        stereotax_opts.CMS=[17.1,-6.9];
        stereotax_opts.CMM=[59.1,54.3];
        stereotax_opts.ang=24;
    case 'Pedro_4C2'
        shortpath = 'D:\Data\Pedro_4C2\MRI\';
        longpath = 'DICOM\10070609\31420001\';
        datapath = [shortpath longpath];
        patientName = 'PEDRO BASELINE';
        seriesNo = 1;
        disp_options.xresolution = 0.5;
        disp_options.yresolution = 0.5;
        disp_options.zresolution = 0.5;
        excel_file = 'tikimap.xls';
        stereotax_opts.CMS=[17.1,-6.9];
        stereotax_opts.CMM=[59.1,54.3];
        stereotax_opts.ang=24;
end

try load([shortpath subject '_processed_mri'])
    data_analyzed = 1;
catch
    data_analyzed = 0;
end

if ~data_analyzed
    mri_data = read_mri(datapath,patientName,seriesNo);
    close all
    [learbar, rearbar, leyebar, reyebar, midline] = get_mri_landmarks(mri_data,disp_options);
    [rotated_mri rot_params] = rotate_mri(mri_data,learbar, rearbar, leyebar, reyebar, midline);
    display_mri(rotated_mri, rot_params, disp_options);
    save([shortpath subject '_processed_mri'],'rotated_mri','excel_file','stereotax_opts',...
    'disp_options','rot_params','mri_data','learbar','rearbar','leyebar','reyebar','midline')
end

display_mri_rf(rotated_mri,excel_file,stereotax_opts, disp_options)