/*
 * $Id: $
 *
 * Classes to set up and run bumps
 */

/**
 * Abstract bump generator class with common functions.
 */
class BumpGenerator {
public:
	BumpGenerator();
	Point getBumpForce(SimStruct *S);
	void start(SimStruct *S);
	void stop();
	virtual double getBumpMagnitude(SimStruct *S) = 0;	
	virtual bool isRunning(SimStruct *S) = 0;

	double direction; /**< Gets or sets the direction the bump will act in. */

protected:
	Timer *timer;    /**< Tracks how long the bump has been running. */
private:
	bool is_running; /**< keeps track of whether the bump is running */
};

/** Default constructor */
BumpGenerator::BumpGenerator() {
	this->timer = new Timer();
	this->is_running = false;
}

/**
 * Calculates the x and y components of the force to be output. 
 * This function calls BumpGenerator::getBumpMagnitude() to find
 * the magnitude and reads BumpGenerator::direction.
 */
Point BumpGenerator::getBumpForce(SimStruct *S) {
	Point p;

	if (is_running) {
		double m = this->getBumpMagnitude(S);
		p.x = m * cos(this->direction);
		p.y = m * sin(this->direction);
	} else {
		p = Point(0,0);
	}

	return p;
}

void BumpGenerator::start(SimStruct *S) {
	is_running = true;
	timer->reset(S);
	timer->start(S);
}

void BumpGenerator::stop() {
	is_running = false;
	timer->stop();
}

/**
 * Generates a square wave bump.
 */
class SquareBumpGenerator : public BumpGenerator {
public:
	SquareBumpGenerator();
	virtual double getBumpMagnitude(SimStruct *S);	
	virtual bool isRunning(SimStruct *S);

	double duration;
	double magnitude;
};

/**
 * Constructs a square wave bump generator with defautl duration and 
 * magnitude of zero.
 */
SquareBumpGenerator::SquareBumpGenerator() {
	duration = 0.0;
	magnitude = 0.0;
}

/**
 * Required isRunning method. 
 * @return whether the bump is running (active).
 */
bool SquareBumpGenerator::isRunning(SimStruct *S) {
	return timer->isRunning() && timer->elapsedTime(S) < duration;
}

/**
 * Required getBumpMagnitude method. 
 * @return the magnitude of the bump for the current time step.
 */
double SquareBumpGenerator::getBumpMagnitude(SimStruct *S) {
	return ( this->isRunning(S) ? this->magnitude : 0.0f );
}

/**
 * Generates a trapezoidal wave bump.
 */
class TrapBumpGenerator : public BumpGenerator {
public:
	TrapBumpGenerator();

	virtual double getBumpMagnitude(SimStruct *S);	
	virtual bool isRunning(SimStruct *S);
	
	double rise_time;
	double hold_duration;
	double peak_magnitude;
};

/**
 * Constructs a trapezoid wave bump generator with defautl duration and 
 * magnitude of zero.
 */
TrapBumpGenerator::TrapBumpGenerator() {
	rise_time = 0;
	hold_duration = 0;
	peak_magnitude = 0;
}

/**
 * Required isRunning method. 
 * @return whether the bump is running (active).
 */
bool TrapBumpGenerator::isRunning(SimStruct *S) {
	return timer->isRunning() && timer->elapsedTime(S) < 2*rise_time+hold_duration;
}

/**
 * Required getBumpMagnitude method. 
 * @return the magnitude of the bump for the current time step.
 */
double TrapBumpGenerator::getBumpMagnitude(SimStruct *S) {
	double et;   // Elapsed time
	double efet; // Elapsed falling-edge time.

	if (!this->isRunning(S)) { // get stupid case out of the way
		return 0.0;
	}

	et = (double)timer->elapsedTime(S);

	if (et < rise_time) {
		return et * peak_magnitude / rise_time;
	} else if (et < rise_time + hold_duration) {
		return peak_magnitude;
	} else if (et < 2 * rise_time + hold_duration) {
		efet = et - rise_time - hold_duration;
		return (rise_time - efet) * peak_magnitude / rise_time;
	} else {
		return 0.0;
	}
}

/**********************************************
 * Sine wave generator
 **********************************************/ 

/**
 * This class is not working correctly.
 */
class CosineBumpGenerator : public BumpGenerator {
public:
	CosineBumpGenerator();

	virtual double getBumpMagnitude(SimStruct *S);	
	virtual bool isRunning(SimStruct *S);
	
	double rise_time;
	double hold_duration;
	double peak_magnitude;
};


/**
 * Constructs a trapezoid wave bump generator with defautl duration and 
 * magnitude of zero.
 */
CosineBumpGenerator::CosineBumpGenerator() {
	rise_time = 0;
	hold_duration = 0;
	peak_magnitude = 0;
}

/**
 * Required isRunning method. 
 * @return whether the bump is running (active).
 */
bool CosineBumpGenerator::isRunning(SimStruct *S) {
	return timer->isRunning() && timer->elapsedTime(S) < 2*rise_time+hold_duration;
}

/**
 * Required getBumpMagnitude method. 
 * @return the magnitude of the bump for the current time step.
 */
double CosineBumpGenerator::getBumpMagnitude(SimStruct *S) {
	double et;   // Elapsed time
	double efet; // Elapsed falling-edge time.

	if (!this->isRunning(S)) { // get stupid case out of the way
		return 0.0;
	}

	et = (double)timer->elapsedTime(S);
	efet = et - rise_time - hold_duration;
	
	if (et < rise_time) {
		return peak_magnitude * (1 - cos(PI * et / rise_time)) / 2;
	} else if (et < rise_time + hold_duration) {
		return peak_magnitude;
	} else if (et < 2 * rise_time + hold_duration) {
		return  peak_magnitude * (1 + cos(PI * efet / rise_time)) / 2;
	} else {
		return 0.0;
	}
}
