#include "csmex.h"
#include "BStimulator.h"

double getpar(const mxArray* prhs[], int i);
int configure_command(int nrhs, const mxArray* prhs[]);
void errorMsg(char *msg1, char *msg2);

static BStimulator myStim;
int verbose=1;

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {

	    /***** LIST OF COMMANDS *********************************/
    static char cmd_list[] = "\
\tautoStimulus\n\
\tbeginningOfGroup\n\
\tbeginningOfSequence\n\
\tconfigure\n\
\tconnect\n\
\tdisconnect\n\
\tendOfGroup\n\
\tendOfSequence\n\
\tgetParams\n\
\tmanualStimulus\n\
\tmeasureOutputVoltage\n\
\tplay\n\
\treadDeviceInfo\n\
\tstim_max\n\
";
    
	if (nrhs < 1) {
		mexPrintf("The following commands have been implemented:\n%s", cmd_list);
		mexErrMsgTxt("csmex: At least one input required.");
    }
    
    if (!mxIsClass(prhs[0], "char")) {
	mexPrintf("The following commands have been implemented:\n%s", cmd_list);
        mexErrMsgTxt("csmex: First argument must be a command string");
        return;
    }
        
    BMaximumValues maxValues;
    const char    *cs_cmd;
    int i=0;
    BUsbParams	myParams;
    
    cs_cmd = mxArrayToString(prhs[i]);
	if (verbose>1) mexPrintf("\nCommand (arg %d): %s\n", i, cs_cmd);
    
    /***** autoStimulus *****************************/
    if (!strcmp(cs_cmd, "autoStimulus")) {
        if (nrhs != 3) {
            mexPrintf("Error: autoStimulus requires 2 parameters, channel and configID\n");
            return;
        }
        UINT8 channel;
        
        int i=1;
        channel = (UINT8)getpar(prhs, i);
        i++;

		int cfgID0 = getpar(prhs,i);
		BConfig cfgID = (BConfig)cfgID0;

	    if ((cfgID > 15)||(cfgID==0)) {
	        mexPrintf("csmex ERROR: configID=%d, range=1-15\n", cfgID);
		    return;
	    }

        int retval = myStim.autoStimulus(channel, cfgID);
        if (retval!=BSUCCESS) {
            mexPrintf("Fail autoStimulus: %d\n", retval);
        } else if(verbose){
            mexPrintf("autoStimulus executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }

	/***** beginningOfGroup *****************************/
    if (!strcmp(cs_cmd, "beginningOfGroup")) {
        int retval = myStim.beginningOfGroup();
        if (retval!=BSUCCESS) {
            mexPrintf("Fail beginning of group: %d\n", retval);
        } else if(verbose){
            mexPrintf("Beginning of group executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }

	/***** beginningOfSequence *****************************/
    if (!strcmp(cs_cmd, "beginningOfSequence")) {
        int retval = myStim.beginningOfSequence();
        if (retval!=BSUCCESS) {
            mexPrintf("Fail beginning of sequence: %d\n", retval);
        } else if (verbose){
            mexPrintf("Beginning of sequence executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }

	/***** configure ***************************************/
    if (!strcmp(cs_cmd, "configure")) {
        int retval = configure_command(nrhs, &prhs[0]);
		plhs[0] = mxCreateDoubleScalar((double)retval);
		return;
    }

    /***** connect************************************************/
    if (!strcmp(cs_cmd, "connect")) {
		myParams.size=sizeof(BUsbParams);
        myParams.timeout = 2000; // in ms
//        myParams.vid = 0x04d8;
//        myParams.pid = 0x003f;
		void *parP;
		parP = &myParams;
//		parP->timeout = 2000;
        BResult retval = myStim.connect(BINTERFACE_DEFAULT, parP);
		if (verbose) {
			if (retval != -10) {
				mexPrintf("Attempt connection to Cerestim: retval=%d\n", retval);
			} else {
				mexPrintf("Connect already present\n");
			}
	        if (!retval) {
		        mexPrintf("Vendor ID = %d, Product ID = %d\n", myParams.vid, myParams.pid);
			}
		}
		plhs[0] = mxCreateDoubleScalar((double)retval);
        
        return;
    }

	/***** disconnect *******************************************/
    if (!strcmp(cs_cmd, "disconnect")) {
        int retval = myStim.disconnect();
		if (verbose) {
			if (retval != -9) {
		        mexPrintf("Attempt disconnection from Cerestim: retval=%d\n", retval);
			} else {
				mexPrintf("Disconnect already present\n");
			}
		}
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }

    /***** endOfGroup *****************************/
    if (!strcmp(cs_cmd, "endOfGroup")) {
        int retval = myStim.endOfGroup();
        if (retval!=BSUCCESS) {
            mexPrintf("Fail end of group: %d\n", retval);
        } else if(verbose){
            mexPrintf("End of group executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }

	/***** endOfSequence *****************************/
    if (!strcmp(cs_cmd, "endOfSequence")) {
        int retval = myStim.endOfSequence();
        if (retval!=BSUCCESS) {
            mexPrintf("Fail End of sequence: %d\n", retval);
        } else if(verbose){
            mexPrintf("End of sequence executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }

    /***** getParams*****************************/
    if (!strcmp(cs_cmd, "getParams")) {
        void *voidP;
        struct BUsbParams *outputP;

        voidP = myStim.getParams();
		if (!voidP) {
            mexPrintf("getParams Failed\n");
			return;
		} else {
			outputP = (struct BUsbParams *) voidP;
				if(verbose){
					mexPrintf("getParams: vid = %x\n", outputP->vid);
					mexPrintf("getParams: pid = %x\n", outputP->pid);
				}
        }
        plhs[0] = mxCreateDoubleMatrix(5,1,mxREAL);
        BUsbParams *myP = (BUsbParams *)mxGetPr(plhs[0]);
        myP = outputP;
        return;
    }

    /***** manualStimulus *****************************/
    if (!strcmp(cs_cmd, "manualStimulus")) {
        if (nrhs != 3) {
            mexPrintf("Error: manualStimulus requires 2 parameters, channel and configID\n");
            return;
        }
        UINT8 channel;
        
        int i=1;
        channel = (UINT8)getpar(prhs, i);
        i++;

		int cfgID0 = getpar(prhs,i);
		BConfig cfgID = (BConfig)cfgID0;

	    if ((cfgID > 15)||(cfgID==0)) {
	        mexPrintf("csmex ERROR: configID=%d, range=1-15\n", cfgID);
		    return;
	    }

        int retval = myStim.manualStimulus(channel, cfgID);
        if (retval!=BSUCCESS) {
            mexPrintf("Fail manualStimulus: %d\n", retval);
        } else if(verbose){
            mexPrintf("manualStimulus executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }

	/***** measureOutputVoltage *****************************/
    if (!strcmp(cs_cmd, "measureOutputVoltage")) {
        BOutputMeasurement output;
		INT16 *myMeasP;
        if (nrhs != 3) {
            mexPrintf("Error: measureOutputVoltage requires 2 parameters: module and channel\n");
            return;
        }
        UINT8 module = (UINT8)getpar(prhs, 1);
        UINT8 channel = (UINT8)getpar(prhs, 2);
        
        int retval = myStim.measureOutputVoltage(&output, module, channel);
        if (retval!=BSUCCESS) {
            mexPrintf("Fail measureOutputVoltage: %d\n", retval);
        } else if(verbose){
            mexPrintf("measureOutputVoltage executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        plhs[1] = mxCreateDoubleMatrix(5,1,mxREAL);
        myMeasP = (INT16 *)mxGetPr(plhs[1]);
//        myMeasP = &(output.measurement[0]);
		int b=1;
        return;
    }

	/***** play *****************************/
    if (!strcmp(cs_cmd, "play")) {
		int count;
		if (nrhs == 2) {
			count = 1;
		} else if (nrhs  == 2) {
			count = getpar(prhs, 2);
			if (count <1) {
				mexPrintf("ERROR: count parameter must be at least 1\n");
				return;
			}
		} else {
			mexPrintf("ERROR: play takes one parameter, the count of # times to run\n");
			return;
		}
		int retval = myStim.play(count);
        if (retval=BSUCCESS) {
			mexPrintf("play Failed:%d\n", retval);
        } else if(verbose){
			mexPrintf("play executed\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }

	/***** readDeviceInfo*****************************/
    if (!strcmp(cs_cmd, "readDeviceInfo")) {
        BDeviceInfo output;
        int retval = myStim.readDeviceInfo(&output);
        if (retval!=BSUCCESS) {
            mexPrintf("Read Device Info Failed\n");
        } else if(verbose){
            for (i=0;i<MAXMODULES;i++) {
                mexPrintf("Device Info: module status = %d\n", output.moduleStatus[i]);
                mexPrintf("Device Info: module version = %d\n", output.moduleVersion[i]);            }
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        plhs[1] = mxCreateDoubleMatrix(5,1,mxREAL);
        BDeviceInfo *myP = (BDeviceInfo *)mxGetPr(plhs[1]);
        myP = &output;
        return;
    }

    /***** readSequenceStatus *******************************************/
    if (!strcmp(cs_cmd, "readSequenceStatus")) {
		struct BSequenceStatus output;
        int retval = myStim.readSequenceStatus(&output);
		if (verbose) {
			if (retval ==0) {
		        mexPrintf("readSequenceStatus: Success\n");
				// 0x00 = Stopped, 0x01 = Playing, 0x02 = Paused, 0x03 = Writing Sequence
		        mexPrintf("Status=%d\n", output);
			} else {
		        mexPrintf("Fail readSequenceStatus: retval=%d\n", retval);
			}
		}
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
    
	/**** stim_max ********************************************/
    if (!strcmp(cs_cmd, "stim_max")) {
        //Ensure that max values are set high enough so you don't get errors when configuring patterns
        int retval = myStim.stimulusMaxValues(&maxValues, 1, BOCVOLT9_5, 215, 65535, 950000, 5154);
        if (retval != BSUCCESS) {
			mexPrintf("maxValues NOT set at Cerestim: %d\n", retval);
        }else if(verbose){
            mexPrintf("maxValues SET at Cerestim\n");
        }
	    return ;
	}

    /***** wait *****************************/
    if (!strcmp(cs_cmd, "wait")) {
		int delay;
		if (nrhs == 1) {
			delay = 1;
		} else if (nrhs  == 2) {
			delay = getpar(prhs, 2);
			if (delay <1) {
				mexPrintf("ERROR: wait parameter must be at least 1 msec\n");
				return;
			}
		} else {
			mexPrintf("ERROR: wait takes one parameter, the # msec to delay\n");
			return;
		}
		int retval = myStim.wait(delay);
        if (retval=BSUCCESS) {
			mexPrintf("wait Failed:%d\n", retval);
        } else if(verbose){
			mexPrintf("wait executed\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
	/***** Here for NO recognized command ***************/
	/***** Here for NO recognized command ***************/
    mexPrintf("Cannot recognize command %s\n\n", cs_cmd);
    mexPrintf("The following commands have been implemented:\n%s", cmd_list);
}

/***************************************************************
 * function getpar() *
 ***************************************************************/
double getpar(const mxArray* prhs[], int i) {
    const char    *argclass;
    int retvalue;
    argclass=mxGetClassName(prhs[i]);
    if (!strcmp(argclass, "double")) {
        retvalue = mxGetScalar(prhs[i]); /* conversion double to int ok? */
		if (verbose>1) mexPrintf("\nInput arg %d: %d\n", i, retvalue);
    } else {
        mexErrMsgTxt("csmex: argument must be a number");
    }
    return retvalue;
}

/***************************************************************
 * function configure_command()
 ***************************************************************/
int configure_command(int nrhs, const mxArray* prhs[]) {
    int NUMCFGPARS = 10;
	int retval = -2;
    if (nrhs < NUMCFGPARS) {
        mexPrintf("csmex ERROR: see %d parameters; configure requires %d parameters\n",
                nrhs-1, NUMCFGPARS-1);
		char *cfgstring = "% configID:     The configuration to save (0-15) <<but 0 is reserved>>\n\
% afcf:         The polarity of the waveform; 0=anodic first\n\
% pulses:       The number of pulses in the stimulation train (1-255)\n\
% amp1:         The amplitude of the first phase in the stimulation (1-215) uA\n\
% amp2:         The amplitude of the second phase in the stimulation (1-215) uA\n\
% width1:       The width of the first phase in the stimulation ( 44 – 65535) uS\n\
% width2:       The width of the second phase in the stimulation ( 44 – 65535) uS\n\
% frequency:    The frequency to stimulate at (4-5154)Hz\n\
% interphase:   The width between phases in the stimulation (53-65535) uS\n";
		printf("%s",cfgstring);
        mexErrMsgTxt("Parameter count mismatch");
        return retval;
    }
    
    int i=1;
	int cfgID0 = getpar(prhs,i);
    BConfig cfgID = (BConfig)cfgID0;

    if ((cfgID >= BCONFIG_COUNT)||(cfgID==BCONFIG_0)) {
        mexPrintf("csmex ERROR: configID=%d, range=1-15\n", cfgID);
        return retval;
    }
    
    i++;
	int afcf0 = getpar(prhs,i);
	BWFType afcf = (BWFType)afcf0;

    if ((afcf > 1)||(cfgID<0)) {
        mexPrintf("csmex ERROR: AnodicFirstCathodicFirst=%d, range=0-1\n", afcf);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    
    i++;
	int npuls0 = getpar(prhs,i);
	UINT8 npuls = (UINT8) npuls0;
    
    if ((npuls0 > 255)||(npuls0==0)) {  // test npuls0 instead of npuls since UINT8 stops at 255
        mexPrintf("csmex ERROR: NumberOfPulses=%d, range=1-255\n", npuls);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    
    i++;
	int amp10 = getpar(prhs, i);
    UINT8 amp1 = (UINT8) amp10;
    
    if ((amp10 > 215)||(amp10==0)) {  // test npuls0 instead of npuls since UINT8 stops at 255
        mexPrintf("csmex ERROR: Amp1=%d, range=1-215\n", amp10);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    
    i++;
	int amp20 = getpar(prhs, i);
	UINT8 amp2 = amp20;
 
    if ((amp20 > 215)||(amp20==0)) {  // test npuls0 instead of npuls since UINT8 stops at 255
        mexPrintf("csmex ERROR: amp2=%d, range=1-215\n", amp20);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    
    i++;
    int width10 = getpar(prhs, i);
    UINT16 width1 = (UINT16)width10;
    
    if ((width10 > 65565)||(width10<44)) {  // test npuls0 instead of npuls since UINT8 stops at 255
        mexPrintf("csmex ERROR: width1=%d, range=44-65565\n", width10);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    
    i++;
    int width20 = getpar(prhs, i);
    UINT16 width2 = (UINT16)width20;

    if ((width20 > 65565)||(width20<44)) {  // test npuls0 instead of npuls since UINT8 stops at 255
        mexPrintf("csmex ERROR: width2=%d, range=44-65565\n", width20);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    
    i++;
    int freq0 = getpar(prhs, i);
    UINT16 freq = (UINT16)freq0;

	if ((freq0 > 5154)||(freq0<4)) {  // test npuls0 instead of npuls since UINT8 stops at 255
        mexPrintf("csmex ERROR: frequency=%d, range=53-65565\n", freq0);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    
    i++;
    int interphase0 = getpar(prhs, i);
    UINT16 interphase = (UINT16)interphase0;
    
    if ((interphase0 > 65565)||(interphase0<53)) {  // test npuls0 instead of npuls since UINT8 stops at 255
        mexPrintf("csmex ERROR: interphase=%d, range=53-65565\n", interphase0);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    if (verbose) 
    mexPrintf("Parameters: %d, %d, %d, %d, %d, %d, %d, %d, %d\n",
            cfgID,
            afcf,
            npuls,
            amp1,
            amp2,
            width1,
            width2,
            freq,
            interphase);
    retval = myStim.configureStimulusPattern(
            cfgID,
            afcf,
            npuls,
            amp1,
            amp2,
            width1,
            width2,
            freq,
            interphase);
    if (verbose)
    mexPrintf("Attempt Configure Cerestim: retval=%d\n", retval);
    return retval;
}

/***************************************************************
 * function errorMsg() *
 ***************************************************************/
void errorMsg(char *msg1, char *msg2) {
    mexPrintf(msg1);
    mexErrMsgTxt(msg2);
    return;
}