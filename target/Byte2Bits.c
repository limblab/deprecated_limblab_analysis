/* $Id: Byte2Bits.c 359 2009-01-23 21:00:54Z matt $
 *
 * Simulink S-Function block that converts an input byte (represented 
 * internaly as a double) and gives the eight bits as 1.0 or 0.0.
 */


#define S_FUNCTION_NAME Byte2Bits
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

static void mdlInitializeSizes(SimStruct *S)
{
    int i; /* used for batch initilizing outputs */
    
    ssSetNumSFcnParams(S, 0); 
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* parameter number mismatch */
    }
        
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    
    /*
     * Block has 1 input port
     */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    
    /* 
     * Block has 8 output ports  coresponding to the eight bits.
     */
    if (!ssSetNumOutputPorts(S, 8)) return;
    for (i=0; i<ssGetNumOutputPorts(S); i++)
        ssSetOutputPortWidth(S, i, 1);
    
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
    real_T u0[1];
    int u, i;
    
    real_T *y0[8];
    
    /* Get input */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    u0[0] = *uPtrs[0];
    u = (int)u0[0];
    
    /* Get outputs */
    for (i=0; i<8; i++)
        y0[i] = ssGetOutputPortRealSignal(S,i);
    
    *y0[0] = ( (u & 0x01) ? 1.0 : 0.0 );
    *y0[1] = ( (u & 0x02) ? 1.0 : 0.0 );
    *y0[2] = ( (u & 0x04) ? 1.0 : 0.0 );
    *y0[3] = ( (u & 0x08) ? 1.0 : 0.0 );
    *y0[4] = ( (u & 0x10) ? 1.0 : 0.0 );
    *y0[5] = ( (u & 0x20) ? 1.0 : 0.0 );
    *y0[6] = ( (u & 0x40) ? 1.0 : 0.0 );
    *y0[7] = ( (u & 0x80) ? 1.0 : 0.0 );

    UNUSED_ARG(tid);
}

static void mdlTerminate (SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE   /* Is this being compiled as a MEX-file? */
#include "simulink.c"    /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"     /* Code generation registration func */
#endif




