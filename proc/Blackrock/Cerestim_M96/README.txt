Cerestim M96 API/Matlab interface programming and debugging
			Ted Ballou
			May 2013

Blackrock provides a C/C++ API for programming the Cerestim M96 stimulator. I have developed a "mex" file so that commands can be accessed from Matlab. This "README" gives notes and tips for continuing this process.

The API Windows libraries do not build with 64-bit Matlab. I am using R2008b which works fine. Set up for the mex interface with the command:
	mex -setup
and choose the Visual Studio environment.

To build for debugging use this Matlab command:
	mex -g csmex.cpp BStimAPI.lib
Note that BStimAPI.dll must be present in the directory in order to run "csmex".
Verify that Matlab recognizes the csmex command; with no arguments, you should see this output:
	??? Error using ==> csmex
	csmex: At least one input required.

To debug in Visual Studio (I am using 2008 Version 9.0.21022.8 RTM), first create the project using
	File/New/ProjectFromExistingCode
Name your project and navigate to the directory with this code & the Cerestim libraries.
Open the file csmex.cpp, and place any desired breakpoints by clicking in the left gutter.

Next, select Debug/AttachToProcess, select the MATLAB process, and click "Attach".

Now calling csmex will run the code under control of the Visual Studio debugger.

The csmex code provides a Matlab interface for a subset of the C/C++ commands described in the API manual. To view the list of supported commands, call with invalid argument.

