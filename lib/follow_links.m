function fname=follow_links(fname)
% takes a file path and returns the same path if its a real file, or the 
%path to the linked file if it's a shortcut
    if exist(fname,'file')~=2
        error('FOLLOW_LINKS:NonFileInput',strcat('the path given is not a file or shortcut. It may be a folder or workspace variable or you may have forgotten the extension'))
    end

    if strcmp(fname(end-3:end),'.lnk')
        x=java.io.File(fname);
        y=sun.awt.shell.ShellFolder.getShellFolder(x);
        fname=char(y.getLinkLocation());
    end
end