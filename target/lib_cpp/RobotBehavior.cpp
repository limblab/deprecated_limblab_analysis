/**
 * $Id: RobotBehavior.cpp 875 2012-04-18 16:37:37Z brian $
 *
 * Parent class for all robot based c++ behaviors.
 */

#ifndef __COMMON_HEADER_CPP
#error "This file is meant to be included through common_header.cpp."
#endif

/*
 * Inputs/Outputs
 *********************************************/

/**
 * This class holds a representation of the inputs to the master control block.
 * One instance of this class is created at Behavior::inputs and is automatically
 * filled prior to each call to update or setOutputs.
 */
class RobotInputs {
public:
	Point cursor; 	  /**< The current cursor location. */
	Point offsets;    /**< The offsets (position of workspace zero relative to motor axes). */	
    Point force;      /**< The input force from the selected force generator. */
    Point catchForce; /**< The input force from the selected catch-force generator. */
};

/**
 * This class holds a representation of the outputs of the master control block.
 * One instance of this class is created at Behavior::outputs and must be filled
 * during the subclass' setOutputs function.  The contents of this are then written
 * to simulink output fields after setOutputs returns.  See the reference implementation
 * in random walk for an example.
 */
class RobotOutputs {
public:
	Point force; 	     /**< Requested output force. */
	int status[5];       /**< Five status numbers to be displayed. */
	int word;            /**< 8-bit word to be output. */
	Target *targets[17]; /**< Targets to be displayed. */
	int reward;          /**< Set true to pulse the reward line. */
	int tone_counter;    /**< Tone counter (see Behavior::playTone).  */
	int last_tone_id;    /**< Id of last requested tone (see: Behavior::playTone). */
	int version[4];      /**< Four numbers indicating the version of the currently running behavior. */
	Point position;      /**< The position to draw the cursor. */
};

/**
 * A behavior deisnged to run on the robot.  Contains the inputs and outputs for the robot model.
 */
class RobotBehavior : public Behavior {
protected:
	/**
	 * Stores the values of the inputs to the master control block.
	 * These fields are updated automatically prior to calls to calculateOutputs or update.
	 */
    RobotInputs *inputs;

	/**
	 * Set these fields to the desired outputs of the master control block.
	 */
	RobotOutputs *outputs;

	/**
	 * A predefined null target that will not be draw, provided for Convenience.
	 */
	Target *nullTarget;

public:
	RobotBehavior();
	virtual void readInputs(SimStruct *S);
	virtual void writeOutputs(SimStruct *S);
};

/**
 * Default constructor. Initializes inputs, outputs and calls Robot().
 */
RobotBehavior::RobotBehavior() : Behavior() { 
    this->inputs = new RobotInputs();
	this->outputs = new RobotOutputs();

	this->nullTarget = (Target *)(new RectangleTarget(0, 0, 0, 0, TARGET_TYPE_NULL));
	for (int i = 0; i < 17; i++) {
		this->outputs->targets[i] = nullTarget;
	}
}

/**
 * Reads the inputs of the master control block into the RobotBehavior::inputs structure.
 * Called automatically prior to calculateOutputs or update.
 * @param S the current SimStruct.
 */
void RobotBehavior::readInputs(SimStruct *S) {
	InputRealPtrsType uPtrs;

	/* cursor */
	uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
	inputs->cursor.x = *uPtrs[0];
	inputs->cursor.y = *uPtrs[1];

    /* offsets */
    uPtrs  = ssGetInputPortRealSignalPtrs(S, 1);
	inputs->offsets.x = *uPtrs[0];
	inputs->offsets.y = *uPtrs[1];
    
	/* input force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
    inputs->force.x = *uPtrs[0];
    inputs->force.y = *uPtrs[1];
    
    /* catch input force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 3);
    inputs->catchForce.x = *uPtrs[0];
    inputs->catchForce.y = *uPtrs[1];
}

/**
 * Write the contents of RobotBehavior::outputs to the SimStruct (automatically called).
 */
void RobotBehavior::writeOutputs(SimStruct *S) {
	int i;
	real_T *uPtrs;

	// force
	uPtrs = ssGetOutputPortRealSignal(S, 0);
	writePoint(uPtrs, &(outputs->force));

	// status
	uPtrs = ssGetOutputPortRealSignal(S, 1);
	for (i = 0; i<5; i++) {
		uPtrs[i] = (real_T)outputs->status[i];
	}

	// word
	uPtrs = ssGetOutputPortRealSignal(S, 2);
	uPtrs[0] = (real_T)outputs->word;

	// targets
	uPtrs = ssGetOutputPortRealSignal(S, 3);
	for (i = 0; i<17; i++) {
		outputs->targets[i]->copyToOutputs(uPtrs, i*5);
	}

	// reward
	uPtrs = ssGetOutputPortRealSignal(S, 4);
	uPtrs[0] = (real_T)(outputs->reward ? 1.0 : 0.0);

	// tone
	uPtrs = ssGetOutputPortRealSignal(S, 5);
	uPtrs[0] = (real_T)outputs->tone_counter;
	uPtrs[1] = (real_T)outputs->last_tone_id;

	// version
	uPtrs = ssGetOutputPortRealSignal(S, 6);
	for (i = 0; i<4; i++) {
		uPtrs[i] = outputs->version[i];
	}

	// position
	uPtrs = ssGetOutputPortRealSignal(S, 7);
	writePoint(uPtrs, &(outputs->position));
}
