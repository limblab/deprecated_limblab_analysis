function [dcmSeries] = loaddcmdir(directoryname)
%function dcmSeries = loaddcmdir(directoryname)
%
% LOADDICOMDIR reads metadata from DICOMDIR file and shows a list of
% the different DICOM SERIES in a Pop-up menus. After selecting a dicom 
% series the program creates a dcmSeries structure containig the 
% related file names and path.
% 
% Input: (OPTIONAL)
%   directoryname  - the path where the DICOMDIR file located                       
%   
% Output:
%   dcmSeries.Images - cell array containing the file names of the images
%   dcmSeries.Path   - directory of the image files
%
% Matlab library function for MIA_gui utility. 
% University of Debrecen, PET Center/LB 2005

try
    hm = [];
    dcmSeries = [];
	if nargin == 0
         directoryname = uigetdir;
    end
    filename1 = fullfile(directoryname,'dicomdir');
    dirres1 = dir(filename1);
    filename2 = fullfile(directoryname,'DICOMDIR');
    dirres2 = dir(filename2);
    if ~isempty(dirres1)
        dcmdir_path = filename1;
    elseif ~isempty(dirres2) 
        dcmdir_path = filename2;
    else
        hm = msgbox('No DICOMDIR in the selected folder !','MIA Info','warn' );
        disp('No DICOMDIR in the selected folder !')
        return;
    end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% open DICOMDIR file & read DirectoryRecordSequence structure 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	hm = msgbox('Reading the DICOMDIR structure. It takes time. Please wait!','MIA Info' );
    set(hm, 'tag', 'Msgbox_MIA Info');
	SetData=setptr('watch');set(hm,SetData{:});
	hmc = (get(hm,'children'));
	set(hmc(2),'enable','inactive');
    pause(1);
    
	dcmhdr = dicominfo(dcmdir_path);
    delete(hm);
    
    DirRecords = dcmhdr.DirectoryRecordSequence;
    DirRecordsFieldNames = fieldnames(DirRecords);
    NumOfField = size(DirRecordsFieldNames,1);
    CurrentPatient = 0;
    SeriesListNum = 0;
    for i = 1: NumOfField
        CurrentItem = getfield(DirRecords,DirRecordsFieldNames{i});
        CurrentItemType = getfield(CurrentItem,'DirectoryRecordType');
        if strcmp(CurrentItemType,'PATIENT')
           CurrentPatient = CurrentPatient + 1;
           CurrentStudy = 0;
           dcmPatient(CurrentPatient,1).PatientName = ...
               CurrentItem.PatientName.FamilyName;
        elseif strcmp(CurrentItemType,'STUDY')
            CurrentStudy = CurrentStudy + 1; 
            CurrentSeries = 0;
            dcmPatient(CurrentPatient,1).Study(CurrentStudy,1).StudyDescription = ...
                CurrentItem.StudyDescription;
        elseif strcmp(CurrentItemType,'SERIES')
            if CurrentSeries > 0 % create summary about the previous read series for popupmenu
                SeriesListNum = SeriesListNum + 1;
                Pname = dcmPatient(CurrentPatient,1).PatientName;
                Modality = dcmPatient(CurrentPatient,1).Study(CurrentStudy,1).Series(CurrentSeries,1).Modality;
                SeriesDescription = dcmPatient(CurrentPatient,1).Study(CurrentStudy,1). ...
                    Series(CurrentSeries,1).SeriesDescription;
                NumOfImages = num2str(CurrentImage);
                SeriesList{SeriesListNum} = [Pname,',  ',Modality,',  Decription: ', SeriesDescription,',  Number of Images: ',NumOfImages];
                SeriesListNumInfo(SeriesListNum).PatientNum = CurrentPatient;
                SeriesListNumInfo(SeriesListNum).StudyNum = CurrentStudy;
                SeriesListNumInfo(SeriesListNum).SeriesNum = CurrentSeries;
            end
            CurrentSeries = CurrentSeries + 1;
            CurrentImage = 0;
            dcmPatient(CurrentPatient,1).Study(CurrentStudy,1).Series(CurrentSeries,1).Modality = ...
                CurrentItem.Modality;
            if isfield(CurrentItem,'SeriesDescription')
                dcmPatient(CurrentPatient,1).Study(CurrentStudy,1).Series(CurrentSeries,1). ...
                    SeriesDescription = CurrentItem.SeriesDescription;
            else
                dcmPatient(CurrentPatient,1).Study(CurrentStudy,1).Series(CurrentSeries,1). ...
                    SeriesDescription = '';
            end 
        elseif strcmp(CurrentItemType,'IMAGE')
            CurrentImage = CurrentImage + 1;
            [pathstr, dcmfname, ext] = fileparts(CurrentItem.ReferencedFileID);
            if CurrentImage == 1
                dcmPatient(CurrentPatient,1).Study(CurrentStudy,1).Series(CurrentSeries,1). ...
                    ImagePath = pathstr;
            end
            dcmPatient(CurrentPatient,1).Study(CurrentStudy,1).Series(CurrentSeries,1). ...
                ImageNames{CurrentImage,1} = dcmfname;
        end
        
    end
    % create summary about the last read series for popupmenu
    SeriesListNum = SeriesListNum + 1;
    Pname = dcmPatient(CurrentPatient,1).PatientName;
    Modality = dcmPatient(CurrentPatient,1).Study(CurrentStudy,1).Series(CurrentSeries,1).Modality;
    SeriesDescription = dcmPatient(CurrentPatient,1).Study(CurrentStudy,1). ...
        Series(CurrentSeries,1).SeriesDescription;
    NumOfImages = num2str(CurrentImage);
    SeriesList{SeriesListNum} = [Pname,',  ',Modality,',  Decription: ', SeriesDescription,',  Number of Images: ',NumOfImages];
    SeriesListNumInfo(SeriesListNum).PatientNum = CurrentPatient;
    SeriesListNumInfo(SeriesListNum).StudyNum = CurrentStudy;
    SeriesListNumInfo(SeriesListNum).SeriesNum = CurrentSeries;
    
    % create popupmenu for dicomseries
    global dcmdirlistVal;
    dcmdirlistVal = 0;
    dcmdirlistfh = figure('menubar','none','NumberTitle','off','name','DICOMDIR info');
    lbh = uicontrol('Style','listbox','Position',[10 60 520 340],'tag','dcmdirlist_popupmenu');
    set(lbh,'string',SeriesList);
    OKCallback = 'global dcmdirlistVal; dcmdirlistVal = get(findobj(''tag'',''dcmdirlist_popupmenu''),''value''); delete(findobj(''name'',''DICOMDIR info''));';
    CancelCallback = 'delete(findobj(''name'',''DICOMDIR info''));';
    OK_h = uicontrol('Style', 'pushbutton', 'String', 'OK','Position', [440 10 80 30], 'Callback', OKCallback);
    Cancel_h = uicontrol('Style', 'pushbutton', 'String', 'Cancel','Position', [340 10 80 30], 'Callback', CancelCallback);
    
    uiwait(dcmdirlistfh);
    
    if dcmdirlistVal == 0;
        disp('No DICOM Series was selected!');
        return;
    end
    dcmSeriesPath = dcmPatient(SeriesListNumInfo(dcmdirlistVal).PatientNum). ...
        Study(SeriesListNumInfo(dcmdirlistVal).StudyNum). ...
        Series(SeriesListNumInfo(dcmdirlistVal).SeriesNum). ...
        ImagePath;
    dcmSeries.Path = [directoryname, filesep, dcmSeriesPath, filesep];
    dcmSeries.Images = dcmPatient(SeriesListNumInfo(dcmdirlistVal).PatientNum). ...
        Study(SeriesListNumInfo(dcmdirlistVal).StudyNum). ...
        Series(SeriesListNumInfo(dcmdirlistVal).SeriesNum). ...
        ImageNames;
    
catch %in case of any error
    ErrorOnDicomOpening = lasterr
    if isobject(hm)
        delete(hm);
    end
    dcmPatient = [];
end