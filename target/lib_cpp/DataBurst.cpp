/* $Id: DataBurst.cpp 854 2012-04-05 19:20:03Z brian $
 *
 * Contains a class to set up and execute the databurst.
 */

#ifndef __COMMON_HEADER_CPP
#error "This file is meant to be included through common_header.cpp."
#endif

/**
 * Data burst helper class.
 * This class is used to set up and play out the data-burst. This should not 
 * need to be instantiated because there is a databurst available in Behavior::db.
 *
 * The general workflow for this class is as follows:
 *
 *     // This call is performed for you in the Behavior constructor.
 *     DataBurst *db = new DataBurst();
 *     
 *     // --- The following should be implemented in the specific behavior ---
 *     // In the pre-trial set up
 *     db->reset();               // get ready to fill with data
 *     db->addByte( someByte );   // fill db with the data that should be included in databurst
 *     db->addByte( someOtherByte );
 *     ...                        
 *     db->start();               // done adding data, get ready to spit it out
 *     
 *     // in outputs
 *     if (db->isRunning())               // if we're writing out the databurst
 *         outputs->word = db->getByte(); // then write out the next byte
 *
 * These functions allow databurst data to be set dynamically at run time and simplifies the playout process.
 * Typically, in the state machine you would use STATE_DATA_BLOCK as one of your states and call DataBurst::isDone()
 * to determine whether to advance to the first state of your trial.
 * 
 * The databurst is **currently limited to 255 bytes.**  Attempts to add more than this will silently fail and the outputed 
 * databurst will contain only 255 bytes.
 *
 * The first byte of the databurst is always its length in bytes.  This class handles that and you do not need to add it manually.
 */
class DataBurst {
public:
	DataBurst();
	byte getByte();
	bool isDone();
	bool isRunning();

	void reset();
	void addInt(int n);
	void addByte(byte b);
	void addFloat(float f);
	void addDouble(double d);

    void start();
private:
	byte *buffer;
	int currentInsertByte;
	int currentPlayingNibble;
    bool started;
};

/**
 * Default constructor.
 */
DataBurst::DataBurst() {
	buffer = new byte[255];
	this->reset();
}

/**
 * Resets the DataBurst.
 * This call resets the databurst to it's initial state. It is ready to recieve data through calls to addByte, addDouble, etc.
 */
void DataBurst::reset() {
	currentPlayingNibble = 0;
	currentInsertByte = 1;
    started = false;
	buffer[0] = 1;
}

/**
 * Starts the playback of the data contained in the databurst.
 * Puts the DataBurst into playout mode.  This is typically the last call made after calls to addByte, addDouble, etc. at the end
 * of the pre-trial initilization code.
 */
void DataBurst::start() {
    started = true;
}

/**
 * Gets the next byte in the databurst.
 * Called during play out to get the next byte of the databurst to write to the word.
 * The output will always be of the form *0xFz* where *z* is either the low or high 
 * four bits of one of the bytes in the databurst.  If called when not in playback mode
 * this function will always return *0xFF*.
 * @return the next byte of the data burst to be written out to the data collection system.
 */
byte DataBurst::getByte() {
	byte out;

	if (!started)
		return 0xFF;

	if (currentPlayingNibble % 2 == 0) {
		out = buffer[currentPlayingNibble / 2] | 0xF0; // low order bits
	} else {
		out = buffer[currentPlayingNibble / 2] >> 4 | 0xF0;
	}

	currentPlayingNibble++;
    
    if (this->isDone()) {
        started = false;
    }
    
	return out;
}

/**
 * Indicates whether the databurst has finished playing out its data and has no more.
 * This function will continue to return true until DataBurst::reset() is called.
 * @return true when done with play out, false otherwise.
 */
bool DataBurst::isDone() {
	return (currentPlayingNibble == currentInsertByte*2);
}

/**
 * Indicates whether the databurst play out has been started.
 * @return true if running, false if finished or not yet started.
 */
bool DataBurst::isRunning() {
	return (started);
}

/**
 * Adds an `int` into the data to be played out.
 * Appends the `int` to the DataBurst's internal buffer of data to be played out.
 * This function should be called after DataBurst::reset(), which resets the DataBurst
 * from the previous trial and makes it ready to recieve data, but before
 * DataBurst::start() which will cause it to enter playout mode.
 * @param n the `int` to be appended to the data burst content.
 */
void DataBurst::addInt(int n) {
	int *nt;
	if (started || currentInsertByte+4 >= 255) return;
	
	nt = (int *)(&buffer[currentInsertByte]);
	*nt = n;

	currentInsertByte += 4;
	buffer[0] += 4;
}

/**
 * Adds a `byte` into the data to be played out.
 * Appends a `byte` (unsigned char) to the DataBurst's internal buffer of data to be played out.
 * This function should be called after DataBurst::reset(), which resets the DataBurst
 * from the previous trial and makes it ready to recieve data, but before
 * DataBurst::start() which will cause it to enter playout mode.
 * @param b the `byte` to be appended to the data burst content.
 */
void DataBurst::addByte(byte b) {
	if (started || currentInsertByte >= 255) return;
	buffer[currentInsertByte++] = b;
	buffer[0]++;
}

/**
 * Adds a `float` into the data to be played out.
 * Appends a `float` to the DataBurst's internal buffer of data to be played out.
 * This function should be called after DataBurst::reset(), which resets the DataBurst
 * from the previous trial and makes it ready to recieve data, but before
 * DataBurst::start() which will cause it to enter playout mode.
 * @param f the `float` to be appended to the data burst content.
 */
void DataBurst::addFloat(float f) {
	float *ft;
	if (started || currentInsertByte+4 >= 255) return;
	
	ft = (float *)(&buffer[currentInsertByte]);
	*ft = f;

	currentInsertByte += 4;
	buffer[0] += 4;
}

/**
 * Adds a `double` into the data to be played out.
 * Appends a `double` to the DataBurst's internal buffer of data to be played out.
 * This function should be called after DataBurst::reset(), which resets the DataBurst
 * from the previous trial and makes it ready to recieve data, but before
 * DataBurst::start() which will cause it to enter playout mode.
 * @param d the `double` to be appended to the data burst content.
 */
void DataBurst::addDouble(double d) {
	double *dt;
	if (started || currentInsertByte+8 >= 255) return;

	dt = (double *)(&buffer[currentInsertByte]);
	*dt = d;

	currentInsertByte += 8;
	buffer[0] += 8;
}
