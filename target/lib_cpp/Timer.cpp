/* $Id: Timer.cpp 864 2012-04-13 14:18:37Z brian $
 *
 * Defines a timer class for use in Behavior
 */

#ifndef __COMMON_HEADER_CPP
#error "This file is meant to be included through common_header.cpp."
#endif

/*
 * Timer
 *********************************************/

/**
 * A Timer with stopwatch like functionality.
 * Implements a simple timer to keep track of various running times within
 * the behavior.  Behavior by default maintains a Timer (stateTimer) that 
 * keeps track of the elapsed time since a state transition.
 *
 * @see Behavior::stateTimer
 */
class Timer {
public:
	Timer();
	void reset(SimStruct *S);
	void pause(SimStruct *S);
	void start(SimStruct *S);
	void stop(SimStruct *S);
	void stop();
	bool isRunning();
	real_T elapsedTime(SimStruct *S);
private:
	bool is_running;
	real_T start_time;
	real_T previously_elapsed_time;
};

/*****************************************
 * Timer
 ******************************************/

/**
 * Default construct create a timer that is not running and has an elapsed time of zero.
 */
Timer::Timer() {
	is_running = false;
	start_time = 0.0;
	previously_elapsed_time = 0.0;
}

/**
 * Resets the timer.
 * Sets the currently elapsed time to zero.  If the timer was running prior to calling
 * reset, it continues running from a time of zero. If the timer was not running it, a
 * call to reset will not start it.  You must call Timer::start(SimStruct *S) to do so.
 * @param S a pointer to the current SimStruct.
 */ 
void Timer::reset(SimStruct *S) {
	previously_elapsed_time = 0.0;
	start_time = ( is_running ? (real_T)ssGetT(S) : 0.0 );
}

/**
 * Returns the elapsed time.
 * If the timer is running, this funtion returns the currently elapsed time. If the timer
 * is not running, it returns the time that had been elapsed when the timer was paused
 * with Timer::pause(SimStruct *S).
 * @param S A pointer to the current SimStruct.
 * @return Elapsed time.
 */ 
real_T Timer::elapsedTime(SimStruct *S) {
	if (is_running) {
		return ((real_T)(ssGetT(S)) - this->start_time) + previously_elapsed_time;
	} else {
		return previously_elapsed_time;
	}
}

/**
 * Pause the timer.
 * Pauses the timer from counting, but does not reset elapsed time. A further call to 
 * Timer::start(SimStruct *S) will resume counting from the time at which it was paused.
 * @param S a pointer to the current SimStruct.
 */ 
void Timer::pause(SimStruct *S) {
	if (is_running) {
		is_running = false;
		previously_elapsed_time += (real_T)(ssGetT(S)) - this->start_time;
	}
}

/**
 * Starts the timer.
 * Cause the timer to begin (or continue if paused) counting.
 * @param S a pointer to the current SimStruct.
 */
void Timer::start(SimStruct *S) {
	if (!is_running) {
		is_running = true;
		start_time = (real_T)ssGetT(S);
	}
}

/**
 * Stops the timer.
 * Stop the timer and reset elapsed time to zero.
 * @param S a pointer to the current SimStruct.
 */
void Timer::stop(SimStruct *S) {
	is_running = false;
	start_time = 0.0;
	previously_elapsed_time = 0.0;
}

void Timer::stop() {
	is_running = false;
	start_time = 0.0;
	previously_elapsed_time = 0.0;
}

/**
 * Indicates whether the timer is currently running.
 * @return True if the timer is running, false if it is stopped or paused.
 */
bool Timer::isRunning() {
	return this->is_running;
}

