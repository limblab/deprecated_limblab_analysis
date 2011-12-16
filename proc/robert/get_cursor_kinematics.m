function varargout=get_cursor_kinematics(inputItem)

% syntax varargout=get_cursor_kinematics(inputItem)
%
%              INPUT:
%                   inputItem - can either be left out, or 
%                               a path to the BDF-formatted
%                               .mat file, or a BDF-formatted
%                               struct from the workspace
%                               
%              OUTPUT:
%                   arbitrary_variable  - if specified, will return
%                                         a BDF-formatted struct
%                                         with the .pos field having
%                                         been filled in from the 
%                                         BR log array.  If unspecified,
%                                         the function will save the 
%                                         updated .mat file to the same
%                                         location from which the original
%                                         .mat file was read in.
%


if ~nargin                      % dialog for bdf
    [FileName,PathName]=uigetfile('*.mat','select a bdf file');
    pathToBDF=fullfile(PathName,FileName);
    load(pathToBDF)
    if exist('bdf','var')~=1
        if exist('out_struct','var')~=1
            error(sprintf(['neither ''bdf'' or ''out_struct'' was found.\n', ...
                'if %s\n contains a properly formatted bdf structure, \n', ...
                'load it manually, and pass it as an argument.\n']))
        else
            bdf=out_struct;
            clear out_struct
            varName='out_struct';
        end
    else
        varName='bdf';
    end     % if we make it to this point we know the variable bdf exists.
else
    if isstr(inputItem) % path to bdf is input
        pathToBDF=inputItem;
        load(pathToBDF)
        if exist('bdf','var')~=1
            if exist('out_struct','var')~=1
                error(sprintf(['neither ''bdf'' or ''out_struct'' was found.\n', ...
                    'if %s\n contains a properly formatted bdf structure, \n', ...
                    'load it manually, and pass it as an argument.\n']))
            else
                bdf=out_struct;
                clear out_struct
                varName='out_struct';
            end
        else
            varName='bdf';
        end     % if we make it to this point we know the variable bdf exists.        
    else                % bdf has been passed in.
        bdf=inputItem;
        clear inputItem
        varName=inputname(1);
        % try to be smart about where bdf might be located.  Do something
        % with bdf.meta.filename
        CCMbank={'Chewie_8I2','Mini_7H1'};
        animal=regexp(bdf.meta.filename,'Chewie|Mini','match','once');
        if isempty(animal)
            % revert to dialog, because the name was not found in our
            % database.  But now, the dialog is looking for the text file
            [FileNameTxt,PathNameTxt]=uigetfile('*.txt','select the log file');
            pathToBR=fullfile(PathNameTxt,FileNameTxt);
            % this is stupid, but at least it keeps things consistent.
            % Just switch the logic on the application below.
            pathToBDF=regexprep(fullfile(PathNameTxt,FileNameTxt), ...
                {['BrainReader logs',filesep,'online'],'\.txt'},{'bdf','\.mat'});
        else
            if ismac
                % automagically, assuming /Volumes is the mount point for data.
                pathToCitadelData=[fullfile('/Volumes','data', ...
                    CCMbank{cellfun(@isempty,regexp(CCMbank,animal))==0})];
                [status,result]=unix(['find ',pathToCitadelData,' -name "', ...
                    regexprep(bdf.meta.filename,'\.plx','\.mat" -print')]);
                if status==0
                    pathToBDF=result;
                else
                    % revert to dialog, we couldn't automagically locate the
                    % BDF.  But now, the dialog is looking for the text file;
                    % the pathToBDF will be reverse-lookup'd.
                    [FileNameTxt,PathNameTxt]=uigetfile('*.mat','select a bdf file');
                    pathToBR=fullfile(PathNameTxt,FileNameTxt);
                    % this is stupid, but at least it keeps things consistent.
                    % Just switch the logic on the application below.
                    pathToBDF=regexprep(fullfile(PathNameTxt,FileNameTxt), ...
                        {['BrainReader logs',filesep,'online'],'\.txt'},{'bdf','\.mat'});
                end
            else
                % PC case.  revert to dialog, or smartly determine drive
                % letter, etc. for citadel/data
            end
        end
    end
end




% load the BrainReader file
pathToBR=regexprep(pathToBDF,{'bdf','\.mat'},{['BrainReader logs',filesep,'online'],'\.txt'});
pathToBR(regexp(pathToBR,sprintf('\n')))='';
BRarray=readBrainReaderFile_function(pathToBR);

% get rid of any lead-in data
tmp=size(BRarray,1);
BRarray(BRarray(:,7)==0,:)=[];
fprintf(1,'deleted %d lines with time stamp=0\n',tmp-size(BRarray,1))

% scale time vector
BRarray(:,7)=BRarray(:,7)/1e9;
BRarray(:,7)=BRarray(:,7)-BRarray(1,7);

bdf.pos=BRarray(:,[7 3 4]);
% could also probably do bdf.vel
bdf.meta.brain_control=1;
% could look into the brainReader file as it's read in, guess from the
% decoder file's name whether it was spike control or LFP control, and save
% that info in bdf.meta.brain_control, rather than just a 1.

if nargout
    varargout{1}=bdf;
else
    % automatically re-save the bdf
    if strcmp(varName,'out_struct')
        out_struct=bdf;
        clear bdf
    end
    save(pathToBDF,varName)
end