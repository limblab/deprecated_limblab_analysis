/* $Id: mastercon_rw2.cpp 858 2012-04-11 21:46:24Z brian $
 *
 * Master Control block for behavior: random walk task 
 */

#define S_FUNCTION_NAME mastercon_vs2
#define S_FUNCTION_LEVEL 2

#define TASK_VS 1

#include "words.h"
#include "common_header.cpp"

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_CT_ON 1
#define STATE_CENTER_HOLD 2
#define STATE_OT_ON 3
#define STATE_REACH 4
#define STATE_OUTER_HOLD 5

/* 
 * STATE_REWARD STATE_ABORT STATE_FAIL STATE_INCOMPLETE STATE_DATA_BLOCK 
 * are all defined in common_header.cpp Do not use state numbers above 64 (0x40)
 * to avoid conflict with these states
 */

/* 
 * Current Databurst version: 1
 *
 * Note that all databursts are encoded half a byte at a time as a word who's 
 * high order bits are all 1 and who's low order bits represent the half byte to
 * be transmitted.  Low order bits are transmitted first.  Thus to transmit the
 * two bytes 0xCF 0x07, one would send 0xFF 0xFC 0xF7 0xF0.
 *
 * Databurst version descriptions
 * ==============================
 *
 * Version 1 (0x01)
 * ----------------
 *
 * byte   0: uchar => number of bytes to be transmitted
 * byte   1: uchar => databurst version number (in this case one)
 * byte   2: uchar => model version major
 * byte   3: uchar => model version minor
 * bytes  4 to  5: short => model version micro
 * bytes  6 to  9: float => x offset
 * bytes 10 to 13: float => y offset
 * byte  14: int => number of targets
 * bytes 15 to 18: float => target radius
 * byte  19: int => target index
 * bytes 20 to 23: float => target size
 * bytes 24 to 27: float => target x position
 * bytes 28 to 31: float => target y position
 *
 */
#define DATABURST_VERSION ((byte)0x01) 

// This must be custom defined for your behavior
struct LocalParams {
	real_T num_targets;
	real_T target_radius;
	real_T target_size;
	real_T num_glyphs;
	real_T center_hold_L;
	real_T center_hold_H;
	real_T search_delay;
	real_T reach_time;
	real_T outer_hold_L;
	real_T outer_hold_H;
	real_T abort_timeout;
	real_T failure_timeout;
	real_T incomplete_timeout;
	real_T reward_timeout;
	real_T master_reset;
	real_T disable_abort;
	real_T green_hold;
};

#define MY_CLASS_NAME VisualSearchBehavior

class VisualSearchBehavior : public RobotBehavior {
public:
	// You must implement these three public methods
	VisualSearchBehavior(SimStruct *S);
	void update(SimStruct *S);
	void calculateOutputs(SimStruct *S);	

private:
	// Your behavior's instance variables

	LocalParams *params;	
	RectangleTarget *outerTargets[16];
	RectangleTarget *centerTarget;
	int correct_target;
	int current_target;
	int target_index;

	//target types for the Gabor wavelets
	int correct_type;
	int center_type;
	int distractor_type;

	// any helper functions you need
	void doPreTrial(SimStruct *S);
};

VisualSearchBehavior::VisualSearchBehavior(SimStruct *S) : RobotBehavior() {
	int i;
	params = new LocalParams();
	this->setNumParams(17);

	this->bindParamId(&params->num_targets,					0);
	this->bindParamId(&params->target_radius,				1);
	this->bindParamId(&params->target_size,					2);
	this->bindParamId(&params->num_glyphs,					3);
	this->bindParamId(&params->center_hold_L,				4);
	this->bindParamId(&params->center_hold_H,				5);
	this->bindParamId(&params->search_delay,				6);
	this->bindParamId(&params->reach_time,					7);
	this->bindParamId(&params->outer_hold_L,				8);
	this->bindParamId(&params->outer_hold_H,				9);
	this->bindParamId(&params->abort_timeout,				10);
	this->bindParamId(&params->failure_timeout,				11);
	this->bindParamId(&params->incomplete_timeout,			12);
	this->bindParamId(&params->reward_timeout,				13);
	this->bindParamId(&params->master_reset,				14);
	this->bindParamId(&params->disable_abort,				15);
	this->bindParamId(&params->green_hold,					16);

	// declare which already defined parameter is our master reset
	// (if you're using one) otherwise omit the following line
	this->setMasterResetParamId(14);

	// This function now fetches all of the parameters into the variables
	// as defined above.
	this->updateParameters(S);

	//initialize the targets
	for (i=0; i<16; i++) {
		outerTargets[i] = new RectangleTarget();
	}
	centerTarget = new RectangleTarget();
	target_index=0;
	//set the target types for use during display
	correct_type=16;
	center_type=16;
	distractor_type=17;
}
void VisualSearchBehavior::doPreTrial(SimStruct *S) {
	int i;
	float theta;
	
	//set the current target index
	target_index++;

	//set the outer target positions
	for (i=0; params->num_targets; i++){
		theta = (float)( PI/2 - i * 2*PI / params->num_targets);
		outerTargets[i]->left   = cos(theta) * params->target_radius - params->target_size / 2;
		outerTargets[i]->right  = cos(theta) * params->target_radius + params->target_size / 2;
		outerTargets[i]->top    = sin(theta) * params->target_radius + params->target_size / 2;
		outerTargets[i]->bottom = sin(theta) * params->target_radius - params->target_size / 2;
	}
	//set the center target position
	centerTarget->left      = - params->target_size / 2;
	centerTarget->right     =   params->target_size / 2;
	centerTarget->top       =   params->target_size / 2;
	centerTarget->bottom    = - params->target_size / 2;

	//select the correct target for this trial
	correct_target = random->getInteger(0,(int)params->num_targets-1);

	//set up the databurst
	db->reset();
	db->addByte(DATABURST_VERSION);
	db->addByte(BEHAVIOR_VERSION_MAJOR);
	db->addByte(BEHAVIOR_VERSION_MINOR);
	db->addByte((BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8);
	db->addFloat((float)(inputs->offsets.x));
	db->addFloat((float)(inputs->offsets.y));
	db->addInt((int)params->num_targets);
	db->addFloat((float)params->target_radius);
	db->addInt((int)target_index);
	db->addFloat((float)params->target_size);
	db->addFloat((float)cos(correct_target * 2*PI / params->num_targets ) * params->target_radius );
	db->addFloat((float)sin(correct_target * 2*PI / params->num_targets ) * params->target_radius );
	db->start();
}
void VisualSearchBehavior::update(SimStruct *S) {
	//Declarations
	int i;
	//State machine
	switch (this->getState()){
		case STATE_PRETRIAL:
			updateParameters(S);
			doPreTrial(S);
			setState(STATE_DATA_BLOCK);
			break;
		case STATE_DATA_BLOCK:
			//wait until the datablock is done streaming and then change
			//to the center on state (CT_ON)
			if (db->isDone()) {
				setState(STATE_CT_ON);
			}
			break;
		case STATE_CT_ON:
			//center target is on. If the cursor is in the center target
			//change to the center hold state
			if (centerTarget->cursorInTarget(inputs->cursor)) {
				setState( STATE_CENTER_HOLD);
			}
			break;
		case STATE_CENTER_HOLD:
			//hold in the center target for the delay period, then change
			//to the movement state
			if(stateTimer->elapsedTime(S)>params->center_hold_H){
				setState(STATE_OT_ON);
			}
			else if (!centerTarget->cursorInTarget(inputs->cursor)) {
				if(params->disable_abort){
					setState(STATE_CT_ON);
				}else {
					setState(STATE_ABORT);
				}
			}
			break;
		case STATE_OT_ON:
			//outer targets are on. If the cursor leaves the start target
			//change state to reach, if the cusor sits for too long, change
			//state to 
			if(stateTimer->elapsedTime(S)>params->search_delay){
				setState(STATE_INCOMPLETE);
			}else if(!centerTarget->cursorInTarget(inputs->cursor)) {
				setState(STATE_REACH);
			}
			break;
		case STATE_REACH:
			//cursor has left the center target. If there is a time out
			// change state to incomplete. If the cursor is in an outer 
			// target check the target type. If the correct target change
			// state to outer_hold, if the type is distractor, change state
			// to fail
			if(stateTimer->elapsedTime(S)>params->reach_time){
				setState(STATE_INCOMPLETE);
			}else {

				for(i=1;i<params->num_targets;i++) {
					if(outerTargets[i]->cursorInTarget(inputs->cursor)){
						if (i==correct_target||params->disable_abort){
							setState(STATE_OUTER_HOLD);
							current_target=i;
						}else {
							setState(STATE_FAIL);
						}
					}
				}
			break;
		case STATE_OUTER_HOLD:
			if (stateTimer->elapsedTime(S)>params->outer_hold_H){
				if(current_target==correct_target){
					setState(STATE_REWARD);
				} else {
					setState(STATE_FAIL);
				}
			}else if (!outerTargets[current_target]->cursorInTarget(inputs->cursor)){
				if (params->disable_abort){
					setState(STATE_REACH);
				}else {
					setState(STATE_INCOMPLETE);
				}
			}
			break;
		case STATE_ABORT:
			//wait for the abort time out
			if(stateTimer->elapsedTime(S)>params->abort_timeout){
				setState(STATE_PRETRIAL);
			}
			break;
		case STATE_FAIL:
			//wait for the failure time out
			if(stateTimer->elapsedTime(S)>params->failure_timeout){
				setState(STATE_PRETRIAL);
			}
			break;
		case STATE_INCOMPLETE:
			//wait for the incomplete time out
			if(stateTimer->elapsedTime(S)>params->incomplete_timeout){
				setState(STATE_PRETRIAL);
			}
			break;
		case STATE_REWARD:
			//wait for the reward time out
			if(stateTimer->elapsedTime(S)>params->reward_timeout){
				setState(STATE_PRETRIAL);
			}
			break;
		default:
			//change state to pretrial
			setState(STATE_PRETRIAL);
        }
    }
}
void VisualSearchBehavior::calculateOutputs(SimStruct *S) {
    int i;
	/* status (1) */
	outputs->status[0] = getState();
	outputs->status[1] = trialCounter->successes;
	outputs->status[2] = trialCounter->aborts;
	outputs->status[3] = trialCounter->failures;
	outputs->status[4] = trialCounter->incompletes;
	/* word (2) */
	if (db->isRunning()){
		outputs->word=db->getByte();
	}else if(isNewState()){
		switch(getState()){
			case STATE_PRETRIAL:
				outputs->word=WORD_START_TRIAL;
				break;
			case STATE_CT_ON:
				outputs->word=WORD_CT_ON;
				break;
			case STATE_CENTER_HOLD:
				outputs->word=WORD_CENTER_TARGET_HOLD;
				break;
			case STATE_OT_ON:
				//set the OT_ON word, with the target number as the variable parameter
				outputs->word=WORD_OT_ON(target_index);
				break;
			case STATE_REACH:
				//all reaches in the VS paradigm are the same so the REACH word is hardcoded 0
				outputs->word=WORD_REACH(0);
				break;
			case STATE_OUTER_HOLD:
				outputs->word=WORD_OUTER_TARGET_HOLD;
				break;
			case STATE_ABORT:
				outputs->word=WORD_ABORT_END_CODE;
				break;
			case STATE_FAIL:
				outputs->word=WORD_FAIL_END_CODE;
				break;
			case STATE_INCOMPLETE:
				outputs->word=WORD_INCOMPLETE_END_CODE;
				break;
			case STATE_REWARD:
				outputs->word=WORD_REWARD_END_CODE;
				break;
			default:
				outputs->word=0;
            }
	}else {
		//we are not in a new state and the databurst is off
		outputs->word=0;
	}
	/* target pos (3) */
	//center target on
	if ( (getState() == STATE_CENTER_HOLD ||
          getState() == STATE_OT_ON) &&
		  params->green_hold ) 
	{
		centerTarget->type=3;
		outputs->targets[0]=(Target*)centerTarget;
	} else if( getState() == STATE_CT_ON ||
              getState() == STATE_CENTER_HOLD ||
			  getState() == STATE_OT_ON )
	{
		centerTarget->type=center_type;
		outputs->targets[0]=(Target*)centerTarget;
	}

	//outer targets on
	if ( getState() == STATE_OT_ON ||
         getState() == STATE_REACH ||
         getState() == STATE_OUTER_HOLD ) 
    {
		for (i=1;i<params->num_targets+1;i++){
			//set the correct display type for the current outer target
			if (i==correct_target+1){
				outerTargets[i-1]->type=distractor_type;
			}else{
				outerTargets[i-1]->type=correct_type;
			}
			//add the current outer target to the outputs
			outputs->targets[i]=outerTargets[i-1];
		}
	}
	/* reward (4) */
	outputs->reward = (isNewState() && (getState() == STATE_REWARD));

	/* tone (5) */
	this->outputs->tone_counter = this->tone_counter;
	this->outputs->last_tone_id = this->last_tone_id;

	/* version (6) */
	outputs->version[0] = BEHAVIOR_VERSION_MAJOR;
	outputs->version[1] = BEHAVIOR_VERSION_MINOR;
	outputs->version[2] = BEHAVIOR_VERSION_MICRO;
	outputs->version[3] = BEHAVIOR_VERSION_BUILD;
	/* position (7) */
	outputs->position = inputs->cursor;

}
/*
 * Include at bottom of your behavior code
 */
#include "common_footer.cpp"