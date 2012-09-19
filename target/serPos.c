/* $Id: serPos.c 359 2009-01-23 21:00:54Z matt $
 *
 * used to output the position data to TDT by cycling through the two 16
 * bit encoder signals one byte at a time.
 */

#define S_FUNCTION_NAME serPos
#define S_FUNCTION_LEVEL 2

#include "simstruc.h" 

static void mdlInitializeSizes(SimStruct *S)
{
    int i; /* used for batch initilizing inputs */
    
    ssSetNumSFcnParams(S, 0); 
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* parameter number mismatch */
    }
        
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    
    /*
     * Block has 3 input ports (index, sh, el)
     */
    if (!ssSetNumInputPorts(S, 3)) return;
    for (i=0; i<ssGetNumInputPorts(S); i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }
    
    /* 
     * Block has 1 output port coresponding to the one output byte
     */
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);
    
    ssSetNumSampleTimes(S, 1);
    
    /* we have no zero crossing detection or modes */
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs;
    real_T index, sh, el;
    int i, s, e;
    
    real_T *byteOut;
    
    /* Get input */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    index = *uPtrs[0];
    uPtrs = ssGetInputPortRealSignalPtrs(S, 1);
    sh = *uPtrs[0];
    uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
    el = *uPtrs[0];
    
    /* Get outputs */
    byteOut = ssGetOutputPortRealSignal(S,0);
    
    i = (int)index;
    s = (int)sh;
    e = (int)el;
    
    if (i == 0) {
        byteOut[0] = s & 0x00ff;
    } else if (i == 1) {
        byteOut[0] = (s & 0xff00) >> 8;
    } else if (i == 2) {
        byteOut[0] = e & 0x00ff;
    } else /* i == 3 */ {
        byteOut[0] = (e &0xff00) >> 8;
    }

    UNUSED_ARG(tid);
}

static void mdlTerminate (SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE   /* Is this being compiled as a MEX-file? */
#include "simulink.c"    /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"     /* Code generation registration func */
#endif


