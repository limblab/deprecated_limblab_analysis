/* =STS=> BStimulator.h[4661].aa02   open     SMID:2 */
//////////////////////////////////////////////////////////////////////////////
//
// (c) Copyright 2010 - 2011 Blackrock Microsystems
//
// $Workfile: BStimulator.h $
// $Archive: /BStimAPI/BStimulator.h $
// $Revision: 2 $
// $Date: 6/20/11 1:10p $
// $Author: Rudy & Ehsan $
//
// $NoKeywords: $
//
//////////////////////////////////////////////////////////////////////////////
//
// PURPOSE:
//
// Blackrock Stim SDK
// This header file is distributed as part of the SDK
//

#if !defined(BSTIMULATOR)
#define BSTIMULATOR

#ifdef BSTIM_EXPORTS
#define BSTIMAPI __declspec(dllexport)
#else
#ifndef STATIC_BSTIM_LINK
#define BSTIMAPI __declspec(dllimport)
#else
#define BSTIMAPI
#endif
#endif

// ----------------------------- BStimulator Defines -------------------------------------- //

#ifndef INT8
typedef signed char     INT8;
#endif
#ifndef UINT8
typedef unsigned char   UINT8;
#endif
#ifndef INT16
typedef signed short    INT16;
#endif
#ifndef UINT16
typedef unsigned short  UINT16;
#endif
#ifndef INT32
typedef signed int      INT32;
#endif
#ifndef UINT32
typedef unsigned int    UINT32;
#endif

typedef UINT32 BStimHandle;					// Handle to the Blackrock Stimulator object


#define MAXMODULES			16				// Max number of modules in CereStim 96
#define MAXCHANNELS			101				// Max number of channels in CereStim 96 Channel 0 is internal 1-100 are external
#define MAXCONFIGURATIONS	16				// Number of pattern configurations.
#define MAX_STIMULATORS		5				// Max number of BStimulator objects that can be defined at once
#define BSTIM_USBVID		0x04d8			// Default USB VID
#define BSTIM_USBPID		0x003f			// Default USB PID
#define BSTIM_RS232COM		1				// Default RS232 Com Port
#define BSTIM_RS232BAUD		8000			// Default RS232 Baud Rate

// ----------------------------- BStimulator Enumerations ------------------------------------- //
/* BStim Interfaces */
enum BInterfaceType
{
    BINTERFACE_DEFAULT	= 0,	// Default interface (windows USB)
    BINTERFACE_WUSB,			// Windows USB interface
    BINTERFACE_WRS232,			// Windows RS232 interface
	BINTERFACE_UUSB,			// Unix USB interface
	BINTERFACE_URS232,			// Unix RS232 interface
	BINTERFACE_MUSB,			// Mac USB interface
	BINTERFACE_MRS232,			// Mac RS232 interface
	BINTERFACE_COUNT			// Always the last one
};

/* Anodic Cathodic Type */
enum BWFType
{
    BWF_ANODIC_FIRST = 0,
    BWF_CATHODIC_FIRST,
    BWF_INVALID // Allways the last value
};

/* Sequence State */
enum BSeqType
{
    BSEQ_STOP = 0,
    BSEQ_PAUSE,
	BSEQ_PLAYING,
    BSEQ_WRITING,
	BSEQ_TRIGGER,
    BSEQ_INVALID // Allways the last value
};

/* Trigger Modes */
enum BTriggerType
{
	BTRIGGER_DISABLED = 0,
	BTRIGGER_RISING,
	BTRIGGER_FALLING,
	BTRIGGER_CHANGE,
	BTRIGGER_INVALID	// Always the last value
};

/* Module Status */
enum BModuleStatus
{
	BMODULE_UNAVAILABLE = 0,
	BMODULE_ENABLED,
	BMODULE_DISABLED,
	BMODULE_OK,
	BMODULE_VOLTAGELIMITATION,
	BMODULE_COUNT
};

/* Configuration Patterns */
enum BConfig
{
	BCONFIG_0 = 0,
	BCONFIG_1,
	BCONFIG_2,
	BCONFIG_3,
	BCONFIG_4,
	BCONFIG_5,
	BCONFIG_6,
	BCONFIG_7,
	BCONFIG_8,
	BCONFIG_9,
	BCONFIG_10,
	BCONFIG_11,
	BCONFIG_12,
	BCONFIG_13,
	BCONFIG_14,
	BCONFIG_15,
	BCONFIG_COUNT
};

/* Output Compliance Voltage Values */
enum BOCVolt
{
	BOCVOLT3_5 = 5,
	BOCVOLT4_1,
	BOCVOLT4_7,
	BOCVOLT5_3,
	BOCVOLT5_9,
	BOCVOLT6_5,
	BOCVOLT7_1,
	BOCVOLT7_7,
	BOCVOLT8_3,
	BOCVOLT8_9,
	BOCVOLT9_5,
	BOCVOLT_INVALID
};

/* BStim enum values and types */
enum BEventType
{
    BEVENT_DEVICE_ATTACHED = 0,
    BEVENT_DEVICE_DETACHED,
    BEVENT_COUNT // Allways the last value
};

enum BCallbackType
{
    BCALLBACK_ALL = 0, // Monitor all events
    BCALLBACK_DEVICE_ATTACHMENT, // Monitor device attachment
    BCALLBACK_COUNT // Allways the last value
};
typedef void (* BCallback)(BEventType type, void* pCallbackData);

/* BStimulator Return Values */
enum BResult
{
    //----- Errors returned (software side) --------------------------- //
    BRETURN                 =     1, // Early returned warning
    BSUCCESS                =     0, // Successful operation
    BNOTIMPLEMENTED         =    -1, // Not implemented
    BUNKNOWN                =    -2, // Unknown error
    BINVALIDHANDLE          =    -3, // Invalid handle
    BNULLPTR                =    -4, // Null pointer
    BINVALIDINTERFACE       =    -5, // Invalid intrface specified or interface not supported
    BINTERFACETIMEOUT       =    -6, // Timeout in creating the interface
	BDEVICEREGISTERED		=	 -7, // Device with that address already connected.
    BINVALIDPARAMS          =    -8, // Invalid parameters
    BDISCONNECTED           =    -9, // Stim is disconnected, invalid operation
    BCONNECTED              =   -10, // Stim is connected, invalid operation
	BSTIMATTACHED			=	-11, // Stim is attached, invalid operation
	BSTIMDETACHED			=	-12, // Stim is detached, invalid operation
    BDEVICENOTIFY           =   -13, // Cannot register for device change notification
    BINVALIDCOMMAND         =   -14, // Invalid command
    BINTERFACEWRITE         =   -15, // Cannot open interface for write
    BINTERFACEREAD          =   -16, // Cannot open interface for read
    BWRITEERR               =   -17, // Cannot write command to the interface
    BREADERR                =   -18, // Cannot read command from the interface
    BINVALIDMODULENUM       =   -19, // Invalid module number specified
    BINVALIDCALLBACKTYPE    =   -20, // Invalid callback type
    BCALLBACKREGFAILED      =   -21, // Callback register/unregister failed

    //----- Errors returned (hardware side) --------------------------- //
	BNOK					=  -100, // Comamnd result not OK
	BSEQUENCEERROR			=  -102, // Sequence Error
	BINVALIDTRIGGER			=  -103, // Invalid Trigger
	BINVALIDCHANNEL			=  -104, // Invalid Channel
	BINVALIDCONFIG			=  -105, // Invalid Configuration
	BINVALIDNUMBER			=  -106, // Invalid Number
	BINVALIDRWR				=  -107, // Invalid Read/Write
	BINVALIDVOLTAGE			=  -108, // Invalid Voltage
	BINVALIDAMPLITUDE		=  -109, // Invalid Amplitude
	BINVALIDAFCF			=  -110, // Invalid AF/CF
	BINVALIDPULSES			=  -111, // Invalid Pulses
	BINVALIDWIDTH			=  -112, // Invalid Width
	BINVALIDINTERPULSE		=  -113, // Invalid Interpulse
	BINVALIDINTERPHASE		=  -114, // Invalid Interphase
	BINVALIDFASTDISCH		=  -115, // Invalid Fast Discharge
	BINVALIDMODULE			=  -116, // Invalid Module
	BSTIMULIMODULES			=  -117, // More Stimuli than Modules
	BMODULEUNAVAILABLE		=  -118, // Module not Available
	BCHANNELUSEDINGROUP		=  -119, // Channel already used in Group
	BCONFIGNOTACTIVE		=  -120, // Configuration not Active
	BEMPTYCONFIG			=  -121, // Empty Config
	BPHASENOTBALANCED		=  -122, // Phases not Balanced
	BPHASEGREATMAX			=  -123, // Phase Charge Greater than Max
	BAMPGREATMAX			=  -124, // Amplitude Greater than Max
	BWIDTHGREATMAX			=  -125, // Width Greater than Max
	BVOLTGREATMAX			=  -126, // Voltage Greater than Max
	BMODULEDISABLED			=  -127, // Module already disabled can't disable it
	BMODULEENABLED			=  -128, // Module already enabled can't reenable it
	BFREQUENCYRANGE			=  -129, // Frequency is out of range
	BINVALIDFREQUENCY		=  -130, // Invalid Frequency
	BFREQUENCYEXCEEDED		=  -131, // The frequency is to great for the other stimulation parameters and causing the interpulse to be invalid
	BNOPARTNUMBER			=  -132, // Device not programed with a valid part number
	BPARTNUMHARDMISMATCH	=  -133, // Devices part number doesnt match number of current modules installed
	BECHOERROR				=  -134	 // Command didn't return same command sent
};

// --------------------------------- BStimulator Structures ---------------------------------------- //

// One-byte packing
#pragma pack(push, 1)
/* Required USB Parameters */
struct BUsbParams{
    UINT32 size;					// sizeof(BStimUsbParams)
    UINT32 timeout;					// How long to try before timeout (mS)
    UINT32 vid;						// vendor ID
    UINT32 pid;						// product ID
};

/* Required RS232 Parameters */
struct BRs232Params{
    UINT32 size;					// sizeof(BStimRs232Params)
    UINT32 timeout;					// How long to try before timeout (mS)
    UINT32 com;						// COM port
    UINT32 baud;					// baud rate
};
#pragma pack(pop)

/* Library Version Information. */
struct  BVersion{
    UINT32 major;
    UINT32 minor;
    UINT32 release;
    UINT32 beta;
};

/* Measure Output Voltage Results */
struct BOutputMeasurement
{
    INT16	measurement[5];			// Signed int (mV)
};

/* Maximum output voltage results */
struct BMaxOutputVoltage
{
	UINT16 miliVolts;
};

/* Read Device Information Results */
struct BDeviceInfo
{
    UINT32	serialNo;				// Hardware part number and serial number 0xPN 00 SN SN
    UINT16	mainboardVersion;		// MSB = version , LSB = subversion (i.e. 0x020A = version 2.10)
    UINT16	protocolVersion;		// MSB = version , LSB = subversion (i.e. 0x020A = version 2.10)
    UINT8	moduleStatus[16];		// 0x00 = Not available.   0x01 = Enabled.   0x02 = Disabled
    UINT16	moduleVersion[16];		// MSB = version , LSB = subversion (i.e. 0x020A = version 2.10)
};

/* Read Stimulus Configuration Pattern Results */
struct BStimulusConfiguration
{
    UINT8	anodicFirst;			// 0x01 = anodic first, 0x00 = cathodic first
    UINT8	pulses;					// Number of biphasic pulses (from 1 to 255)
    UINT16	amp1;					// Amplitude first phase (uA)
    UINT16	amp2;					// Amplitude second phase (uA)
    UINT16	width1;					// Width first phase (us)
    UINT16	width2;					// Width second phase (us)
    UINT16	interpulse;				// Width between pulses (uS)
    UINT16	interphase;				// Time between phases (us)
    UINT8	fastDischarge;			// Fast discharge during interphases and interpulses 0x01 = yes 0x00 = no
};

/* Read sequence Status */
struct BSequenceStatus
{
	UINT8	status;					// 0x00 = Stopped, 0x01 = Playing, 0x02 = Paused, 0x03 = Writing Sequence
};

/* Read Maximum Values Results */
struct BMaximumValues
{
	UINT8	voltage;				// Max voltage value see voltage table
	UINT16	amplitude;				// Amplitude (uA)
	UINT16	width;					// Phase width (uS)
	UINT32	phaseCharge;			// Charge per phase (pC)
	UINT32	frequency;				// Frequency (Hz)
};

/* Test Module Results */
struct BTestModules
{
	INT16 modulesMV[16][5];			// Voltage in mV
	BModuleStatus   modulesStatus[16];	// BMODULE_UNAVAILABLE, BMODULE_DISABLED, BMODULE_OK, BMODULE_VOLTAGELIMITATION
};

/* Test Electrodes Results */
struct BTestElectrodes
{
	INT16 electrodes[MAXCHANNELS][5];			// Signed int (mV)
};

/* Group Stimulus Channel Configuration */
struct BGroupStimulus
{
	UINT8 channel[16];			// Channel to stimulate
	UINT8 pattern[16];			// Configuration Patter to use with coresponding channel
};

struct BReadEEpromOutput
{
	UINT8 eeprom[256];			// eeprom values
};

struct BReadHardwareValuesOutput
{
	UINT16 width;				// Max width based on hardware in uS
	UINT32 charge;				// Max charge based on hardware in pC
	UINT32 maxFreq;				// Max Frequency based on hardware in Hz
	UINT32 minFreq;				// Min Frequency based on hardware in Hz
	UINT8  modules;				// Number of modules installed in device
};

/*-------------------------------BStimulator class for interfacing with CereStim 96---------------------------------------------*/
class BStimulator
{
protected:

	static UINT32 m_iStim100Objects;
	struct BStim100Data;
	BStim100Data	*m_psData;			// Private data members

public:
	// Exception class that is thrown when there are to many objects of BStimulator.  This will need to be caught when creating an object
	BSTIMAPI class maxStimulatorError{};

	BSTIMAPI BStimulator();			// Constructor
	BSTIMAPI ~BStimulator();		// Destructor
	BSTIMAPI BResult connect(BInterfaceType stimInterface, void * params);	// Sets up what interface the PC will talk to the CereStim 96 over
	BSTIMAPI BResult disconnect();	// Removes the connection from PC to the CereStim 96
	BSTIMAPI BResult libVersion(BVersion * output);	// Gets the SDK library version

	// Calls that are made to the CereStim 96
	BSTIMAPI BResult manualStimulus(UINT8 channel, BConfig configID);
	BSTIMAPI BResult measureOutputVoltage(BOutputMeasurement * output, UINT8 module, UINT8 channel);
	BSTIMAPI BResult beginningOfSequence();
	BSTIMAPI BResult endOfSequence();
	BSTIMAPI BResult beginningOfGroup();
	BSTIMAPI BResult endOfGroup();
	BSTIMAPI BResult autoStimulus(UINT8 channel, BConfig configID);
	BSTIMAPI BResult wait(UINT16 miliSeconds);
	BSTIMAPI BResult play(UINT16 times);
	BSTIMAPI BResult stop();
	BSTIMAPI BResult pause();
	BSTIMAPI BResult maxOutputVoltage(BMaxOutputVoltage * output, UINT8 rw, BOCVolt voltage);
	BSTIMAPI BResult readDeviceInfo(BDeviceInfo * output);
	BSTIMAPI BResult enableModule(UINT8 module);
	BSTIMAPI BResult disableModule(UINT8 module);
	BSTIMAPI BResult configureStimulusPattern(BConfig configID, BWFType afcf, UINT8 pulses, UINT16 amp1, UINT16 amp2,
									 UINT16 width1, UINT16 width2, UINT16 interpulse, UINT16 interphase, UINT8 fastDischarge);
	BSTIMAPI BResult configureStimulusPattern(BConfig configID, BWFType afcf, UINT8 pulses, UINT16 amp1, UINT16 amp2,
									 UINT16 width1, UINT16 width2, UINT32 frequency, UINT16 interphase);
	BSTIMAPI BResult readStimulusPattern(BStimulusConfiguration * output, BConfig configID);
	BSTIMAPI BResult readSequenceStatus(BSequenceStatus * output);
	BSTIMAPI BResult stimulusMaxValues(BMaximumValues * output, UINT8 rw, BOCVolt voltage, UINT16 amplitude, UINT16 width, UINT32 phaseCharge, UINT32 frequency);
	BSTIMAPI BResult groupStimulus(UINT8 beginSeq, UINT8 play, UINT16 times, UINT8 number, BGroupStimulus * input);
	BSTIMAPI BResult testElectrodes(BTestElectrodes * output);
	BSTIMAPI BResult testModules(BTestModules * output);
	BSTIMAPI BResult triggerStimulus(BTriggerType edge);
	BSTIMAPI BResult stopTriggerStimulus();
	BSTIMAPI BResult updateElectrodeChannelMap(UINT8 (&map)[100]);

	BSTIMAPI INT8 isConnected();							// Returns true if you currently have an interface established between the PC and CereStim 96
	BSTIMAPI BInterfaceType getInterface();					// Returns the type of interface that is establishded between PC and CereStim 96
	BSTIMAPI void *	getParams();							// Returns the parameters that the interface is using.
	BSTIMAPI UINT32 getSerialNumber();						// Returns the CereStim 96 Serial Number
	BSTIMAPI UINT16 getMotherboardFirmwareVersion();		// Returns the CereStim 96 motherboard firmware version
	BSTIMAPI UINT16 getProtocolVersion();					// Returns the CereStim 96 protocol version
	BSTIMAPI UINT32 getMinMaxAmplitude();					// Returns the max amplitude in upper two bytes and min amplitude in lower two bytes
	BSTIMAPI void getModuleFirmwareVersion(UINT16* output); // Pass in the address of an UINT16 output[MAXMODULES]
	BSTIMAPI void getModuleStatus(UINT8* output);			// Pass in the address of an UINT8 output[MAXMODULES]
	BSTIMAPI UINT32 getUSBAddress();						// Returns the address of the USB line its plugged into Address of 0 means not connected or not plugged in
	BSTIMAPI UINT32 getMaxHardCharge();						// Returns the Maximum charge that the hardware will allow
	BSTIMAPI UINT32 getMinHardFrequency();					// Returns the minimum Frequency that the hardware will allow
	BSTIMAPI UINT32 getMaxHardFrequency();					// Returns the maximum Frequency that the Hardware will allow
	BSTIMAPI UINT16 getMaxHardWidth();						// Returns the maximum phase width the hardware will allow
	BSTIMAPI UINT8  getNumberModules();						// Returns the number of modules installed

	BSTIMAPI BResult SetSerialNumber(UINT8 part_number, UINT16 serial_number);
	BSTIMAPI BResult ReadEeprom(BReadEEpromOutput * output);
	BSTIMAPI BResult EraseEeprom();
	BSTIMAPI BResult DisableStimulusConfiguration(UINT8 config_id);
	BSTIMAPI BResult ReadHardwareValues(BReadHardwareValuesOutput * output);
};

#endif

