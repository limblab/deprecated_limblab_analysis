/**
 * common_footer.cpp
 * Contains the c functions required to build an s-function coresponding to the class defined
 * in the cpp file that included it.  Generally speaking, this should not have to be edited.
 * 
 * $Id: common_footer.cpp 853 2012-04-05 15:57:42Z brian $
 */


#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
#endif       // defined within this scope                     

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    MY_CLASS_NAME *b = new MY_CLASS_NAME(S);

    ssSetNumSFcnParams(S, b->getNumParams()); 
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* parameter number mismatch */
    }
    for (i=0; i<ssGetNumSFcnParams(S); i++)
        ssSetSFcnParamTunable(S,i, 1);
    // mdlCheckParameters(S);
    
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    
    /*
     * Block has 4 input ports
     *      input port 0: (position) of width 2 (x, y)
     *      input port 1: (position offset) of width 2 (x, y)
     *      input port 2: (force) of width 2 (x, y)
     *      input port 3: (catch force) of width 2 (x, y)
     */
    if (!ssSetNumInputPorts(S, 4)) return;
    ssSetInputPortWidth(S, 0, 2); /* x & y position */
    ssSetInputPortWidth(S, 1, 2); /* x & y position offsets */
    ssSetInputPortWidth(S, 2, 2); /* main force */
    ssSetInputPortWidth(S, 3, 2); /* catch trial force */
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);
    
    /* 
     * Block has 8 output ports (force, status, word, targets, reward, tone, version, pos) of widths:
     *  force: 2
     *  status: 5 ( block counter, successes, aborts, failures, incompletes )
     *  word:  1 (8 bits)
     *  target: 10 ( target 1, 2: 
     *                  on/off, 
     *                  target UL corner x, 
     *                  target UL corner y,
     *                  target LR corner x, 
     *                  target LR corner y)
     *  reward: 1
     *  tone: 2     ( 1: counter incemented for each new tone, 2: tone ID )
     *  version: 1 ( the cvs revision of the current .c file )
     *  pos: 2 (x and y position of the cursor)
     */
    if (!ssSetNumOutputPorts(S, 8)) return;
    ssSetOutputPortWidth(S, 0, 2);   /* force   */
    ssSetOutputPortWidth(S, 1, 5);   /* status  */
    ssSetOutputPortWidth(S, 2, 1);   /* word    */
    ssSetOutputPortWidth(S, 3, 85);  /* target  */
    ssSetOutputPortWidth(S, 4, 1);   /* reward  */
    ssSetOutputPortWidth(S, 5, 2);   /* tone    */
    ssSetOutputPortWidth(S, 6, 4);   /* version */
    ssSetOutputPortWidth(S, 7, 2);   /* pos     */
    
    ssSetNumSampleTimes(S, 1);

    /* work buffers */
	ssSetNumRWork(S, 0);
	ssSetNumIWork(S, 0);
	ssSetNumPWork(S, 1);

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

#define MDL_START
static void mdlStart(SimStruct *S)
{
	ssGetPWork(S)[0] = (void *) new MY_CLASS_NAME(S);
}

#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid) 
{
	MY_CLASS_NAME *b = (MY_CLASS_NAME *) ssGetPWork(S)[0];
	if (b->checkMasterReset(S))
		return;
	b->generalUpdate(S);
	b->update(S);
	
    UNUSED_ARG(tid);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
	MY_CLASS_NAME *b = (MY_CLASS_NAME *) ssGetPWork(S)[0];
	b->readInputs(S);
	b->updateTrialCounters();
	b->calculateOutputs(S);
	b->writeOutputs(S);
	
	UNUSED_ARG(tid);
}

static void mdlTerminate (SimStruct *S) { 
	MY_CLASS_NAME *b = (MY_CLASS_NAME *) ssGetPWork(S)[0];
	delete b;
}

#ifdef MATLAB_MEX_FILE   /* Is this being compiled as a MEX-file? */
#include "simulink.c"    /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"     /* Code generation registration func */
#endif

#ifdef __cplusplus
} // end of extern "C" scope
#endif