ECHO * > results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO File Handling Test For Window Console Versions > results.txt
ECHO Batch File 8/3/2004 >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt


ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ** DDT CONSOLE TEST CASES *********************************************** >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt

ECHO * >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
C:\Plexon\FileHandling\ddtReader_Win32_Console\ddtread >> results.txt

ECHO * >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
C:\Plexon\FileHandling\ddtReader_Win32_Console\ddtread C:\Plexon\FileHandling\SampleData\test1.ddt >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt


ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ** PLX CONSOLE TEST CASES *********************************************** >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt

ECHO * >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
C:\Plexon\FileHandling\plxReader_Win32_Console\plxread >> results.txt

ECHO * >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
C:\Plexon\FileHandling\plxReader_Win32_Console\plxread C:\Plexon\FileHandling\SampleData\test1.plx >> results.txt

ECHO * >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
C:\Plexon\FileHandling\plxReader_Win32_Console\plxread C:\Plexon\FileHandling\SampleData\test1.plx -header >> results.txt

ECHO * >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
C:\Plexon\FileHandling\plxReader_Win32_Console\plxread C:\Plexon\FileHandling\SampleData\test1.plx -spike >> results.txt

ECHO * >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
C:\Plexon\FileHandling\plxReader_Win32_Console\plxread C:\Plexon\FileHandling\SampleData\test1.plx -event >> results.txt

ECHO * >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ************************************************************************* >> results.txt
C:\Plexon\FileHandling\plxReader_Win32_Console\plxread C:\Plexon\FileHandling\SampleData\test1.plx -slow >> results.txt

ECHO * >> results.txt
ECHO ************************************************************************* >> results.txt
ECHO ** END OF TEST >> results.txt
ECHO ************************************************************************* >> results.txt

