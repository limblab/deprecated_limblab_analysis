/**
 * $Id: Behavior.cpp 858 2012-04-11 21:46:24Z brian $
 *
 * Parent class for all c++ behaviors.
 */

#include "Behavior.h"
#include <math.h>

#ifndef __COMMON_HEADER_CPP
#error "This file is meant to be included through common_header.cpp."
#endif

/*********************************************************
 * Behavior 
 ************************************************************/

/**
 * Default constructor. Should be called by subclasses during their
 * constructors.
 */
Behavior::Behavior() {
	numParams = 0;
	state = 0;
	state_changed = true;
	tone_counter = 0;
	last_tone_id = 0;
	masterResetCounter = 0;
	masterResetParamId = -1;
	this->trialCounter = new TrialCounter();
	this->stateTimer = new Timer();
	this->random = new Random();
	this->db = new DataBurst();
}

/**
 * Updates the bound parameter variables to the values of the parameters of the master control block.
 * @param S the current SimStruct.
 */
void Behavior::updateParameters(SimStruct *S) {
	int i;
	for (i = 0; i < this->numParams; i++) {
		*paramAddrs[i] = mxGetScalar(ssGetSFcnParam(S, i));
	}
}

/**
 * Sets the number of parameters this behavior will use. This function should be called once in the 
 * derived class constructor prior to any calls to Behavior::bindParamId.
 * @param n the number of parameters to be used.
 */
void Behavior::setNumParams(int n) {
	this->numParams = n;
	this->paramAddrs = new real_T* [n];
	for (int i=0; i<n; i++) {
		this->paramAddrs[i] = &dummy_value;
	}
}

/**
 * Returns the number of prameters specified for this behavior's master control block.
 * This function will give the number of parameters specified by a prior call to Behavior::setNumParams(n).
 * This function is used during the RTW build setup and probably won't be terribly useful to behavior
 * developers since you (presumably) know what you passed to setNumParams.
 * @returns the number of parameters for this behavior.
 */
int Behavior::getNumParams() {
	return this->numParams;
}

/**
 * Binds a parameter ID to a particular instance variable.
 * This function should be called once for each parameter to be implemented in the 
 * behavior's master control block.  This is typically done in the subclass' constructor.
 * Once a variable is bound to a particular (zero indexed) parameter id, that variable
 * will automatically be set to the value of the parameter each time Behavior::updateParameters()
 * is called.
 * @param paramLocation a pointer to the variable to be bound.
 * @param paramIdNumber the identifier number for the parameter to bind.
 */
void Behavior::bindParamId(real_T *paramLocation, int paramIdNumber) {
	if (paramIdNumber >= 0 && paramIdNumber < numParams) {
		this->paramAddrs[paramIdNumber] = paramLocation;
	}
}

/**
 * Get the current state of the behavior.
 * @return the current state.
 */
int Behavior::getState() {
	return this->state;
}

/**
 * Set the behavior to a new state.
 * This function automatically handles flagging the state transition and 
 * reseting the state timer.
 * @param s the desired state.
 */
void Behavior::setState(int s) {
	this->state = s;
	this->state_changed = true;
	this->stateTimer->reset(S);
}

/**
 * Returns true on the first cycle after a state transition, false otherwise.
 * @return true on the first cycle after a state transition, false otherwise.
 */
bool Behavior::isNewState() {
	return this->state_changed;
}

/**
 * Updates the trial counters (automatically called).
 * If we have just transitioned to a reward, failure, incomplete, or abort state
 * this function will increment the appropriate counter.  This funciton is called 
 * automatically before the subclass' calculateOutputs function is called.
 */
void Behavior::updateTrialCounters() {
	if (state == STATE_REWARD && state_changed)
		this->trialCounter->successes++;

	if (state == STATE_FAIL && state_changed)
		this->trialCounter->failures++;

	if (state == STATE_INCOMPLETE && state_changed)
		this->trialCounter->incompletes++;

	if (state == STATE_ABORT && state_changed)
		this->trialCounter->aborts++;
}

/**
 * Run general (for all behaviors) update functions -- called automatically.
 * @param S the current SimStruct.
 */
void Behavior::generalUpdate(SimStruct *S) {
	this->readInputs(S);
	this->state_changed = false;
	this->S = S;
	if (!this->stateTimer->isRunning()) 
		this->stateTimer->start(S);
	this->random->getUL(); // burn a number of the pRNG
}

/**
 * Play the requested sound.
 * This function updates internal counters to indicate that a tone should be played.
 * The tone is play by the graphics computer.
 * @param toneId the tone id to be played.
 */
void Behavior::playTone(int toneId) {
	this->last_tone_id = toneId;
	this->tone_counter++;
}

/**
 * private helper function
 */
void writePoint(real_T *u, Point *p) {
	u[0] = (real_T)(p->x);
	u[1] = (real_T)(p->y);
}

/**
 * Declares which parameter corresponds to the Master Reset parameter.
 * When the Master Reset parameter is incremented, the behavior will 
 * automatically clear all trial counters, update all parameters,
 * and revert to PRETRIAL.
 * @param n the parameter ID that corresponds to a Master Reset.
 */
void Behavior::setMasterResetParamId(int n) {
	this->masterResetParamId = n;
}

/**
 * Checks if a master reset has been issued (automatically called).
 * This function is called prior to the subclasses' update function.
 * It will perform a reset if the Master Reset parameter has been 
 * incremented.
 * @returns true if a master reset has been issued.
 */
int Behavior::checkMasterReset(SimStruct *S) {
	// If we haven't set a master reset param, then ignore this check
	if (masterResetParamId == -1) {
		return 0;
	}

	// If we have set one, then check if it's been issued
	if (mxGetScalar(ssGetSFcnParam(S, masterResetParamId)) != masterResetCounter) {
		// issue master reset
		trialCounter->reset();
		
		masterResetCounter = (int)mxGetScalar(ssGetSFcnParam(S, masterResetParamId));
		setState(0);
		
		return 1;
	} else {
		return 0;
	}
}







