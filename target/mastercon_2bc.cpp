/* $Id: $
 *
 * Master Control block for behavior: bump psychophysics 2-bump choice
 */

#pragma warning(disable:4800)

#define S_FUNCTION_NAME mastercon_2bc
#define S_FUNCTION_LEVEL 2

// Our task code will be in the databurst
#define TASK_DB_DEFINED 1
#include "words.h"

#include "common_header.cpp"

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_CT_ON 1
#define STATE_CT_HOLD 2
#define STATE_CT_BLOCK 3
#define STATE_STIM 4
#define STATE_BUMP 5
#define STATE_MOVEMENT 6
#define STATE_PENALTY 7

/* 
 * STATE_REWARD STATE_ABORT STATE_FAIL STATE_INCOMPLETE STATE_DATA_BLOCK 
 * are all defined in Behavior.h Do not use state numbers above 64 (0x40)
 */

/* 
 * Current Databurst version: 0
 *
 * Note that all databursts are encoded half a byte at a time as a word who's 
 * high order bits are all 1 and who's low order bits represent the half byte to
 * be transmitted.  Low order bits are transmitted first.  Thus to transmit the
 * two bytes 0xCF 0x07, one would send 0xFF 0xFC 0xF7 0xF0.
 *
 * Databurst version descriptions
 * ==============================
 *
 * Version 0 (0x00)
 * ----------------
 * byte 0: uchar      => number of bytes to be transmitted
 * byte 1: uchar      => version number (in this case zero)
 * byte 2: uchar      => task code (0x01)
 * bytes 3-6:         => version code
 * byte 7: uchar      => staircase id
 * bytes 8-11: int    => staircase iteration
 * bytes 12-15: float  => bump direction
 * bytes 16-19: float => target angle
 * bytes 20-23: float => bump magnitude
 * bytes 24-27: float => bump duration
 */

#define DATABURST_VERSION ((byte)0x00) 
#define DATABURST_TASK_CODE ((byte)0x01)

// This must be custom defined for your behavior
struct LocalParams {
	real_T master_reset;
	real_T soft_reset;
	real_T target_size;
	real_T target_radius;
	real_T big_target;
	real_T target_angle;
	real_T bump_magnitude;
	real_T bump_duration;
    real_T bump_ramp;
	real_T ct_hold_time;
	real_T ot_delay_time;
	real_T bump_hold_time;
	real_T intertrial_time;
	real_T run_staircase;
	real_T sc_step_size;
	real_T use_bottom_sc;
	real_T green_prim_targ;
	real_T hide_cursor;
	real_T use_limits;
	real_T stim_prob;
	real_T penalty_time;
	real_T staircase_start;
	real_T staircase_ratio;
	real_T use_single_sc;
    real_T recenter_cursor;
};

/**
 * This is the behavior class.  You must extend "Behavior" and implement
 * at least a constructor and the functions:
 *   void update(SimStruct *S)
 *   void calculateOutputs(SimStruct *S)
 *
 * You must also update the definition below with the name of your class
 */
#define MY_CLASS_NAME TwoBumpChoiceBehavior
class TwoBumpChoiceBehavior : public RobotBehavior {
public:
	// You must implement these three public methods
	TwoBumpChoiceBehavior(SimStruct *S);
	void update(SimStruct *S);
	void calculateOutputs(SimStruct *S);	

private:
	// Your behavior's instance variables
	CircleTarget *centerTarget;
	CircleTarget *primaryTarget;
	CircleTarget *secondaryTarget;
	SquareTarget *errorTarget;
    
	Staircase *stairs[8];
	int staircase_id;
	bool stim_trial;
	bool step_sc_together;

	double bump_dir;
    
    Point cursorOffset;

	CosineBumpGenerator *bump;

	LocalParams *params;
	real_T last_soft_reset;

	// any helper functions you need
	void doPreTrial(SimStruct *S);
	void setupStaircase(int i, double angle, double step, double fl, double bl);
	int chooseStaircase();

	void stepAllSCForward();
	void stepAllSCBackward();
};

TwoBumpChoiceBehavior::TwoBumpChoiceBehavior(SimStruct *S) : RobotBehavior() {
    int i;

	/* 
	 * First, set up the parameters to be used 
	 */
	// Create your *params object
	params = new LocalParams();

	// Set up the number of parameters you'll be using
	this->setNumParams(25);
	// Identify each bound variable 
	this->bindParamId(&params->master_reset,	 0);
	this->bindParamId(&params->soft_reset,		 1);
	this->bindParamId(&params->target_size,		 2);
	this->bindParamId(&params->target_radius,	 3);
	this->bindParamId(&params->big_target,		 4);
	this->bindParamId(&params->target_angle,	 5);
	this->bindParamId(&params->bump_magnitude,	 6);
	this->bindParamId(&params->bump_duration,	 7);
    this->bindParamId(&params->bump_ramp,        8);
	this->bindParamId(&params->ct_hold_time,	 9);
	this->bindParamId(&params->ot_delay_time,	10);
	this->bindParamId(&params->bump_hold_time,	11);
	this->bindParamId(&params->intertrial_time, 12);
	this->bindParamId(&params->run_staircase,	13);
	this->bindParamId(&params->sc_step_size,	14);
	this->bindParamId(&params->use_bottom_sc,   15);
	this->bindParamId(&params->green_prim_targ, 16);
	this->bindParamId(&params->hide_cursor,		17);
	this->bindParamId(&params->use_limits,		18);
	this->bindParamId(&params->stim_prob,       19);
	this->bindParamId(&params->penalty_time,    20);
	this->bindParamId(&params->staircase_start, 21);
	this->bindParamId(&params->staircase_ratio, 22);
	this->bindParamId(&params->use_single_sc,   23);
	this->bindParamId(&params->recenter_cursor, 24);

	// declare which already defined parameter is our master reset 
	// (if you're using one) otherwise omit the following line
	this->setMasterResetParamId(0);

	// This function now fetches all of the parameters into the variables
	// as defined above.
	//this->updateParameters(S);
	
	last_soft_reset = -1; // force a soft reset of first trial

	centerTarget = new CircleTarget();
	primaryTarget = new CircleTarget(); 
	secondaryTarget = new CircleTarget(); 

	centerTarget->color = Target::Color(128, 128, 128);
	primaryTarget->color = Target::Color(160, 255, 0);
	secondaryTarget->color = Target::Color(255, 0, 160);

	errorTarget = new SquareTarget(0, 0, 100, Target::Color(255, 255, 255));

	for (i=0; i<8; i++) {
		stairs[i] = new Staircase();
	}

	this->stim_trial = false;
	this->staircase_id = -1;
	this->bump_dir = 0.0;
	this->bump = new CosineBumpGenerator();
}

void TwoBumpChoiceBehavior::setupStaircase(
	int i, double angle, double step, double fl, double bl) 
{
	// We do two staircases here because there are two stiarcases with similar
	// starting points, one with stim and one without.
	stairs[i]->setStartValue( angle );
	stairs[i]->setRatio( (int)params->staircase_ratio );
	stairs[i]->setStep( step );
	stairs[i]->setUseForwardLimit( (bool)params->use_limits );
	stairs[i]->setUseBackwardLimit( (bool)params->use_limits );
	stairs[i]->setForwardLimit( fl );
	stairs[i]->setBackwardLimit( bl );
	stairs[i]->setUseSoftLimit( true );
	stairs[i]->restart();

	stairs[i+4]->setStartValue( angle );
	stairs[i+4]->setRatio( (int)params->staircase_ratio );
	stairs[i+4]->setStep( step );
	stairs[i+4]->setUseForwardLimit( false );
	stairs[i+4]->setUseBackwardLimit( false );
	stairs[i+4]->setForwardLimit( fl );
	stairs[i+4]->setBackwardLimit( bl );
	stairs[i+4]->setUseSoftLimit( true );
	stairs[i+4]->restart();
}

int TwoBumpChoiceBehavior::chooseStaircase() {
	int stim = (this->random->getDouble() < this->params->stim_prob);
	int sc_dir = (params->use_bottom_sc ? random->getInteger(0,3) : random->getInteger(0,1));
	return (stim ? sc_dir + 4 : sc_dir);
}

void TwoBumpChoiceBehavior::doPreTrial(SimStruct *S) {
	// Set up target locations, etc.
	centerTarget->radius = params->target_size;

	primaryTarget->radius = params->target_size;
	primaryTarget->centerX = params->target_radius*cos(params->target_angle);
	primaryTarget->centerY = params->target_radius*sin(params->target_angle);
	
	secondaryTarget->radius = params->target_size;
	secondaryTarget->centerX = params->target_radius*cos(PI + params->target_angle);
	secondaryTarget->centerY = params->target_radius*sin(PI + params->target_angle);

    // Reset cursor offset
    cursorOffset.x = 0;
    cursorOffset.y = 0;
    
	if (last_soft_reset != params->soft_reset) {
		// load parameters to the staircases and reset them.
		last_soft_reset = params->soft_reset;
		step_sc_together = params->use_single_sc;

		setupStaircase(0, params->target_angle+params->staircase_start, params->sc_step_size, params->target_angle+90, params->target_angle);
		setupStaircase(1, params->target_angle-params->staircase_start+180 , -params->sc_step_size, params->target_angle+90, params->target_angle+180);
		setupStaircase(2, params->target_angle+params->staircase_start+180 , params->sc_step_size, params->target_angle+270, params->target_angle+180);
		setupStaircase(3, params->target_angle-params->staircase_start+360 , -params->sc_step_size, (bool)params->use_limits, params->target_angle+270);
	}

	// Pick which staircase to use
	this->staircase_id = this->chooseStaircase();
	this->bump_dir = stairs[staircase_id]->getValue();
	this->stim_trial = (staircase_id > 3);

	// Set up the bump itself
	this->bump->hold_duration = params->bump_duration;
	this->bump->peak_magnitude = params->bump_magnitude;
	this->bump->rise_time = params->bump_ramp;
	this->bump->direction = params->target_angle + PI * this->bump_dir / 180;

	// Reset primary target color if needed
	if ((int)params->green_prim_targ) {
		primaryTarget->color = Target::Color(160, 255, 0);
	} else {
		primaryTarget->color = Target::Color(255, 0, 160);
	}

	/* setup the databurst */
	db->reset();
	db->addByte(DATABURST_VERSION);
	db->addByte('2');
	db->addByte('B');
	db->addByte('C');
	db->addByte(BEHAVIOR_VERSION_MAJOR);
    db->addByte(BEHAVIOR_VERSION_MINOR);
	db->addByte((BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8);
	db->addByte(BEHAVIOR_VERSION_MICRO & 0x00FF);
	db->addByte(staircase_id);
	db->addInt(stairs[staircase_id]->getIteration());
	db->addFloat((float)bump_dir);
	db->addFloat((float)params->target_angle);
	db->addFloat((float)params->bump_magnitude);
	db->addFloat((float)params->bump_duration);
	db->addFloat((float)params->bump_ramp);
	db->addByte(this->stim_trial);
    db->start();
}

void TwoBumpChoiceBehavior::stepAllSCForward() {
	for (int i = 0; i < 7; i++)
		this->stairs[i]->stepForward();
}

void TwoBumpChoiceBehavior::stepAllSCBackward() {
	for (int i = 0; i < 7; i++)
		this->stairs[i]->stepBackward();
}

void TwoBumpChoiceBehavior::update(SimStruct *S) {

	Target *correctTarget;
	Target *incorrectTarget;

	if (staircase_id == 0 || staircase_id ==3) {
		// want to be in primary target
		correctTarget = primaryTarget;
		incorrectTarget = secondaryTarget;
	} else {
		// staircase_id == 1
		// want to be in secondary target
		correctTarget = secondaryTarget;
		incorrectTarget = primaryTarget;
	}


	// State machine
	switch (this->getState()) {
		case STATE_PRETRIAL:
			updateParameters(S);
			doPreTrial(S);
			setState(STATE_DATA_BLOCK);
			break;
		case STATE_DATA_BLOCK:
			if (db->isDone()) {
				setState(STATE_CT_ON);
			}
			break;
		case STATE_CT_ON:
			/* first target on */
			if (centerTarget->cursorInTarget(inputs->cursor)) {
				setState(STATE_CT_HOLD);
			}
			break;
		case STATE_CT_HOLD:
			if (!centerTarget->cursorInTarget(inputs->cursor)) {
				playTone(TONE_ABORT);
				setState(STATE_ABORT);
			} else if (stateTimer->elapsedTime(S) > params->ct_hold_time) {
                centerTarget->radius = params->big_target;
				setState(STATE_CT_BLOCK);
			}
			break;
		case STATE_CT_BLOCK:
			if (!centerTarget->cursorInTarget(inputs->cursor)) {
				playTone(TONE_ABORT);
				setState(STATE_ABORT);
			} else if (stateTimer->elapsedTime(S) > params->ot_delay_time) {
				bump->start(S);
				setState(STATE_BUMP);
			}
			break;
		case STATE_BUMP:
			if (!centerTarget->cursorInTarget(inputs->cursor)) {
				playTone(TONE_ABORT);
				setState(STATE_ABORT);
			} else if (stateTimer->elapsedTime(S) > params->bump_hold_time) {
				playTone(TONE_GO);
				if (this->stim_trial) {
					setState(STATE_STIM);
				} else {
                    if (params->recenter_cursor) {
                        cursorOffset = inputs->cursor;
                    }   
					setState(STATE_MOVEMENT);
				}
			}
			break;
		case STATE_STIM:
			setState(STATE_BUMP);
			break;
		case STATE_MOVEMENT:
			if (correctTarget->cursorInTarget(inputs->cursor - cursorOffset)) {
				if (params->run_staircase && step_sc_together) {
					stepAllSCForward();
				} else if (params->run_staircase && !step_sc_together) {
					this->stairs[staircase_id]->stepForward();
				}
				playTone(TONE_REWARD);
				setState(STATE_REWARD);
			} else if (incorrectTarget->cursorInTarget(inputs->cursor - cursorOffset)) {
				if (params->run_staircase && step_sc_together) {
					stepAllSCBackward();
				} else if (params->run_staircase && !step_sc_together) {
					this->stairs[staircase_id]->stepBackward();
				}
				playTone(TONE_ABORT);
				if (this->params->penalty_time > 0) {
					setState(STATE_PENALTY);
				} else {
					setState(STATE_FAIL);
				}
			}
			break;
		case STATE_PENALTY:
			if (stateTimer->elapsedTime(S) > params->penalty_time) {
				setState(STATE_FAIL);
			}
			break;
		case STATE_ABORT:
        case STATE_REWARD:
		case STATE_FAIL:
        case STATE_INCOMPLETE:
			this->bump->stop();
			if (stateTimer->elapsedTime(S) > params->intertrial_time) {
				setState(STATE_PRETRIAL);
			}
			break;
		default:
			setState(STATE_PRETRIAL);
	}

}

void TwoBumpChoiceBehavior::calculateOutputs(SimStruct *S) {
    /* declarations */
    Point bf;

	/* force (0) */
	if (bump->isRunning(S)) {
		bf = bump->getBumpForce(S);
		outputs->force.x = inputs->force.x + bf.x;
		outputs->force.y = inputs->force.y + bf.y;
	} else {
		outputs->force = inputs->force;
	}

	/* status (1) */
	outputs->status[0] = getState();
	outputs->status[1] = trialCounter->successes;
	outputs->status[2] = trialCounter->failures;
	outputs->status[3] = (int)stairs[0]->getValue();
	outputs->status[4] = (int)stairs[1]->getValue();

	/* word(2) */
	if (db->isRunning()) {
		outputs->word = db->getByte();
	} else if (isNewState()) {
		switch (getState()) {
			case STATE_PRETRIAL:
				outputs->word = WORD_START_TRIAL;
				break;
			case STATE_CT_BLOCK:
				outputs->word = WORD_OT_ON(0);
				break;
			case STATE_STIM:
				outputs->word = WORD_STIM(0);
				break;
			case STATE_BUMP:
				outputs->word = WORD_BUMP(0);
				break;
			case STATE_MOVEMENT:
				outputs->word = WORD_GO_CUE;
				break;
			case STATE_REWARD:
				outputs->word = WORD_REWARD;
				break;
			case STATE_ABORT:
				outputs->word = WORD_ABORT;
				break;
			case STATE_FAIL:
				outputs->word = WORD_FAIL;
				break;
			case STATE_INCOMPLETE:
				outputs->word = WORD_INCOMPLETE;
				break;
			default:
				outputs->word = 0;
		}
	} else {
		outputs->word = 0;
	}

	/* target_pos (3) */
	// Center Target
	if (getState() == STATE_CT_ON || 
	    getState() == STATE_CT_HOLD || 
        getState() == STATE_CT_BLOCK ||
        getState() == STATE_BUMP) 
	{
		outputs->targets[0] = (Target *)centerTarget;
		outputs->targets[1] = nullTarget;
	} else if (getState() == STATE_MOVEMENT) {
		outputs->targets[0] = (Target *)(this->primaryTarget);
		outputs->targets[1] = (Target *)(this->secondaryTarget);
	} else if (getState() == STATE_PENALTY) {
		outputs->targets[0] = (Target *)(this->errorTarget);
		outputs->targets[1] = nullTarget;
	} else {
		outputs->targets[0] = nullTarget;
		outputs->targets[1] = nullTarget;
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
    if ((getState() == STATE_CT_BLOCK || getState() == STATE_BUMP) && (params->hide_cursor > .1))
    {
        outputs->position = Point(1E6, 1E6);
    } else { //if ( (params->recenter_cursor) && (getState() == STATE_MOVEMENT) ) {
        outputs->position = inputs->cursor - cursorOffset;
//    } else {
//    	outputs->position = inputs->cursor;
    } 
}

/*
 * Include at bottom of your behavior code
 */
#include "common_footer.cpp"


