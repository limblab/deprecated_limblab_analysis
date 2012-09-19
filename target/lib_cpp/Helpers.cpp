/* $Id: Helpers.cpp 986 2012-09-05 19:08:45Z ricardo $
 *
 * Contains simple helper classes for the behavior
 */

#ifndef __COMMON_HEADER_CPP
#error "This file is meant to be included through common_header.cpp."
#endif

/***************************************************
 * Point
 ***************************************************/

/** 
 * A 2d vector point.
 * Point is a helper class that represents a point in 2D space.
 */
class Point {
public:
    Point();
    Point(real_T x, real_T y);
    
	Point & operator+=(const Point &p);
	Point & operator-=(const Point &p);
	
	const Point operator+(const Point &p);
	const Point operator-(const Point &p);

	real_T x; /**< The x coordinate of the point. */
	real_T y; /**< The y coordinate of the point. */
};

/**
 * Default constructor sets x and y to zero
 */
Point::Point() {
    this->x = 0.0;
    this->y = 0.0;
}

/**
 * Constructor, sets x and y to the requested values 
 */
Point::Point(real_T x, real_T y) {
    this->x = x;
    this->y = y;
}


Point & Point::operator+=(const Point &p) {
	this->x = this->x + p.x;
	this->y = this->y + p.y;
	return *this;
}

Point & Point::operator-=(const Point &p) {
	this->x = this->x - p.x;
	this->y = this->y - p.y;
	return *this;
}

const Point Point::operator+(const Point &p) {
	Point a = *this;
	a += p;
	return a;
}

const Point Point::operator-(const Point &p) {
	Point a = *this;
	a -= p;
	return a;
}

/***************************************************
 * Trial Counter
 ***************************************************/

/**
 * Implements a trial counter to keep track of the successes, failures, etc.
 */
class TrialCounter {
public:
	int successes;   /**< The count of the number of success trials. */
	int failures;    /**< The count of the number of failure trials. */
	int aborts;      /**< The count of the number of abort trials */
	int incompletes; /**< The count of the number of incomplete trials */

	TrialCounter();
	void reset();
};

/**
 * Default constructor sets all counters to zero.
 */
TrialCounter::TrialCounter() {
	this->reset();
}

/**
 * Resets all of the trial counters to zero.
 */
void TrialCounter::reset() {
	this->successes = 0;
	this->failures = 0;
	this->incompletes = 0;
	this->aborts = 0;
}




/*********************************************
 * Random
 *********************************************/

/**
 * XPC Safe pseduo-random number generator.
 * This class grants access to a pseudo-random number generator.
 * It should not have to be created directly since there will be
 * one included in Behavior::random which you can utilize with the
 * methods described below.
 */
class Random {
public:
	Random();
	double getDouble(double low, double high);
	double getDouble(); // defaults zero to one
	double getGaussian(double mean, double var); 
	double getGaussian(); // mean zero, var one
	int getInteger(int low, int high);
	bool getBool();
	unsigned long getUL();
    void permute(void **input, int length);
private:
	unsigned long z, w, jsr, jcong;
	unsigned long kiss();
};

/**
 * Initilizes the pRNG to a pre-defined seed.
 */
Random::Random() {
	z = 362436069;
	w = 521288629;
	jsr = 123456789;
	jcong = 380116160;
}

/*
 * Internal private function.
 */
unsigned long Random::kiss() {
	unsigned long mwc, cong, shr3;

	this->w = 18000*(w&65535)+(w>>16);
	this->z = 36969*(z&65535)+(z>>16);
	mwc = ((this->z)<<16) + this->w;

	this->jcong = 69069 * this->jcong + 1234567;
	cong = this->jcong;

	this->jsr = (this->jsr)^((this->jsr)<<17);
	this->jsr = (this->jsr)^((this->jsr)>>13);
	this->jsr = (this->jsr)^((this->jsr)<<5);
	shr3 = this->jsr;

	return ((mwc^cong)+shr3);
}

/**
 * A random double in the requested range.
 * Selects a random number from a uniform distribution between low and high.
 * @param low the lower bound.
 * @param high the upper bound.
 * @return a random number between low and high.
 */
double Random::getDouble(double low, double high) { 
	return (low + (high-low) * getDouble()); 
}

/**
 * A random double on the interval (0, 1).
 * Returns a random double from the uniform distribution between zero and one.
 * @return a random number between 0 and 1.
 */
double Random::getDouble() {
	return ( 2.328306e-10 * (double)kiss() );
}

/**
 * Returns a gaussian random number of the specified mean and variance.
 * @param mean the mean of the gaussian.
 * @param var the variance of the gaussian.
 * @return a double selected from the normal distribution with mean `mean` and variance `var`.
 */
double Random::getGaussian(double mean, double var) {
	return mean + var*getGaussian();
}

/**
 * Returns a random number from a gaussian distrbution with mean zero and variance one.
 * @return a double selected from the normal distribution with mean 0 and variance 1.
 */
double Random::getGaussian() {
	double a = getDouble();
	double b = getDouble();
	return sqrt(-2*log(a))*cos(2*3.141592654*b);
}

/**
 * Returns a random integer in the specified range.
 * This function returns an interger selected from the set of integers between `low` and `high` (inclusive).
 * Due to the way this function is implemented, it can sometimes give non-uniform probability over the requested
 * set of integers if the range is very large (anything less than a million or so should be fine).
 * @param low the lowest allowable value of the random number.
 * @param high the higest allowable value of the random number.
 * @return a random integer on the range [`low`, `high`].
 */
int Random::getInteger(int low, int high) {
	unsigned long range = high - low + 1;
	return low + (getUL() % range);
}

/**
 * Returns a random boolean value of true or false with equal probability.
 * @return a random boolean value.
 */
bool Random::getBool() {
	return (kiss() % 2 == 0);
}

/**
 * Returns a random 32 bit value as an `unsigned long`.
 * @returns 32 bit random number.
 */
unsigned long Random::getUL() {
	return kiss();
}

/** Returns a random permutation of the int array as an array of ints.
 * @ returns a random permutation of numbers between 1 and n.
 */
void Random::permute(void **input, int length){
    double *tmp_sort;
    int i, j; 
    double tmp_d;
    void *tmp;
    
    tmp_sort = (double *)malloc(length * sizeof(double));

    for (i=0; i<length; i++){
        tmp_sort[i] = rand();
    }
    
    for (i=0; i<length-1; i++){
        for (j=0; j<length-1; j++){
            if (tmp_sort[j] < tmp_sort[j+1]){
                tmp_d = tmp_sort[j];
                tmp_sort[j] = tmp_sort[j+1];
                tmp_sort[j+1] = tmp_d;

                tmp = input[j];
                input[j] = input[j+1];
                input[j+1] = tmp;
            }
        }
    }
    
    free(tmp_sort);
}      
