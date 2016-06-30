rem File Handling Release Batch File
REM 8/3/2004


rem Copy the release executables to project directory
copy C:\Plexon\FileHandling\ddtReader_Win32_Console\Release\ddtread.exe C:\Plexon\FileHandling\ddtReader_Win32_Console\ddtread.exe
copy C:\Plexon\FileHandling\plxReader_Win32_Console\Release\plxread.exe C:\Plexon\FileHandling\plxReader_Win32_Console\plxread.exe


del C:\Plexon\FileHandling\plxReader_Win32_Console\Release\*
del C:\Plexon\FileHandling\plxReader_Win32_Console\Debug\*
del C:\Plexon\FileHandling\ddtReader_Win32_Console\Release\*
del C:\Plexon\FileHandling\ddtReader_Win32_Console\Debug\*
del C:\Plexon\FileHandling\ddtReader_MFC\Release\*
del C:\Plexon\FileHandling\ddtReader_MFC\Debug\*
del C:\Plexon\FileHandling\plxReader_MFC\Release\*
del C:\Plexon\FileHandling\plxReader_MFC\Debug\*


rmdir C:\Plexon\FileHandling\plxReader_Win32_Console\Release
rmdir C:\Plexon\FileHandling\plxReader_Win32_Console\Debug
rmdir C:\Plexon\FileHandling\ddtReader_Win32_Console\Release
rmdir C:\Plexon\FileHandling\ddtReader_Win32_Console\Debug
rmdir C:\Plexon\FileHandling\ddtReader_MFC\Release
rmdir C:\Plexon\FileHandling\ddtReader_MFC\Debug
rmdir C:\Plexon\FileHandling\plxReader_MFC\Release
rmdir C:\Plexon\FileHandling\plxReader_MFC\Debug

del C:\Plexon\FileHandling\plxReader_Win32_Console\*.pdb
del C:\Plexon\FileHandling\ddtReader_Win32_Console\*.pdb
del C:\Plexon\FileHandling\ddtReader_MFC\*.pdb
del C:\Plexon\FileHandling\plxReader_MFC\*.pdb

del C:\Plexon\FileHandling\plxReader_Win32_Console\*.plg
del C:\Plexon\FileHandling\ddtReader_Win32_Console\*.plg
del C:\Plexon\FileHandling\ddtReader_MFC\*.plg
del C:\Plexon\FileHandling\plxReader_MFC\*.plg

del C:\Plexon\FileHandling\plxReader_Win32_Console\*.clw
del C:\Plexon\FileHandling\ddtReader_Win32_Console\*.clw
del C:\Plexon\FileHandling\ddtReader_MFC\*.clw
del C:\Plexon\FileHandling\plxReader_MFC\*.clw

del C:\Plexon\FileHandling\plxReader_Win32_Console\*.ncb
del C:\Plexon\FileHandling\ddtReader_Win32_Console\*.ncb
del C:\Plexon\FileHandling\ddtReader_MFC\*.ncb
del C:\Plexon\FileHandling\plxReader_MFC\*.ncb


del C:\Plexon\FileHandling\plxReader_Win32_Console\*.opt
del C:\Plexon\FileHandling\ddtReader_Win32_Console\*.opt
del C:\Plexon\FileHandling\ddtReader_MFC\*.opt
del C:\Plexon\FileHandling\plxReader_MFC\*.opt




