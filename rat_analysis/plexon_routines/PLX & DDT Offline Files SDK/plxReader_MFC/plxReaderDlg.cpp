/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// plxReaderDlg.cpp : implementation file that contains functionality for 
// reading and displaying a PLX file.
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "plxReader.h"
#include "plxReaderDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// CPlxReaderDlg dialog
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

CPlxReaderDlg::CPlxReaderDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CPlxReaderDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CPlxReaderDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	m_fileName		= "Test1.plx";
	m_filePath      = "..\\SampleData\\";
	m_bOpen = false ;
}	

void CPlxReaderDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CPlxReaderDlg)
	DDX_Control(pDX, IDC_BUTTON_HEADER, m_buttonHeader);
	DDX_Control(pDX, IDC_CHECK_SPIKE, m_buttonCheckSpike);
	DDX_Control(pDX, IDC_CHECK_SLOW, m_buttonCheckSlow);
	DDX_Control(pDX, IDC_CHECK_EVENT, m_buttonCheckEvent);
	DDX_Control(pDX, IDC_LIST_HEADER, m_listHeader);
	DDX_Control(pDX, IDC_LIST, m_listData);
	DDX_Control(pDX, IDC_EXTRACT, m_buttonExtract);
	DDX_Control(pDX, IDC_PROGRESS, m_progress);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CPlxReaderDlg, CDialog)
	//{{AFX_MSG_MAP(CPlxReaderDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_CLOSE()
	ON_BN_CLICKED(IDC_BROWSE, OnBnClickedBrowse)
	ON_BN_CLICKED(IDC_READ_FILE, OnBnClickedReadFile)
	ON_BN_CLICKED(IDC_EXTRACT, OnExtract)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// Initilize the main dialog
/////////////////////////////////////////////////////////////////////////////

BOOL CPlxReaderDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// Update the file name edit control
	m_fileName = m_filePath + m_fileName;
	SetDlgItemText(IDC_FILENAME,m_fileName);

	// Check the show spike, event, and slow check boxes	
	m_buttonCheckSpike.SetCheck(1) ;
	m_buttonCheckEvent.SetCheck(1) ;
	m_buttonCheckSlow.SetCheck(1) ;

	// Send a courier font to the button for the data block header.
	m_fontHeader.CreateFont(14, 0, 0, 0, 800, 0, 0, 0, 0, 0, 0, 0, 0, "Courier New") ;
	m_buttonHeader.SetFont(&m_fontHeader) ;
	m_buttonHeader.SetWindowText(" Type       Time(s)  Time(ticks) Channel Unit Data") ;

	// Send the courier font to the list box for the data block items.
	m_fontData.CreateFont(14, 0, 0, 0, 400, 0, 0, 0, 0, 0, 0, 0, 0, "Courier New") ;
	m_listData.SetFont(&m_fontData) ;

	// Have the controls on the main dialog indicate that there is not PLX file loaded.
	EnableControlsToLoad () ;
	return TRUE;  // return TRUE  unless you set the focus to a control
}

/////////////////////////////////////////////////////////////////////////////

void CPlxReaderDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
// to draw the icon.  For MFC applications using the document/view model,
// this is automatically done for you by the framework.

void CPlxReaderDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CPlxReaderDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

/////////////////////////////////////////////////////////////////////////////
// FileOpen dialog to allow the user to browse for a PLX file to open.
/////////////////////////////////////////////////////////////////////////////

void CPlxReaderDlg::OnBnClickedBrowse()
{
	CString filter;

	filter = "Plexon Files (*.plx)|*.plx|";

	CFileDialog dlg(TRUE, NULL, NULL, OFN_HIDEREADONLY, filter);
	if(dlg.DoModal() == IDOK)
	{
		m_fileName = dlg.GetPathName();
		SetDlgItemText(IDC_FILENAME,m_fileName);

		EnableControlsToLoad () ;
	}	
}

/////////////////////////////////////////////////////////////////////////////
// Reads the file header and all of the channel headers.  The function returns
// 0 if no error detected, otherwise, it returns a 1.
/////////////////////////////////////////////////////////////////////////////

int CPlxReaderDlg :: ReadHeaders ()
{
	int iChannel ;

	if (m_file.Read((void*)&m_fileHeader, sizeof(m_fileHeader)) != sizeof (m_fileHeader)) return 1 ;

	if (m_fileHeader.MagicNumber != 0x58454C50) return 1 ;

	for (iChannel = 0 ; iChannel < m_fileHeader.NumDSPChannels ; iChannel++)
	{
		if (m_file.Read((void*)&m_spikeChannels[iChannel], sizeof(PL_ChanHeader)) != sizeof (PL_ChanHeader)) return 1 ;
	}

	for (iChannel = 0 ; iChannel < m_fileHeader.NumEventChannels ; iChannel++)
	{
		if (m_file.Read((void*)&m_eventChannels[iChannel], sizeof(PL_EventHeader)) != sizeof (PL_EventHeader)) return 1 ;
	}

	for (iChannel = 0 ; iChannel < m_fileHeader.NumSlowChannels ; iChannel++)
	{
		if (m_file.Read((void*)&m_slowChannels[iChannel], sizeof(PL_SlowChannelHeader)) != sizeof (PL_SlowChannelHeader)) return 1 ;
	}

	// save the position in the file where the data blocks begin.
	m_dataPosition = (DWORD)m_file.GetPosition() ;
	return 0 ;
}

/////////////////////////////////////////////////////////////////////////////
// Dump the contents of the header to the header list box for display.  The
// put method is a helper function to make the DumpHeaders function more
// readable.
/////////////////////////////////////////////////////////////////////////////

void CPlxReaderDlg::Put(LPCTSTR lpszFormat, ...)
{
	CString str ;
	ASSERT(AfxIsValidString(lpszFormat));

	va_list argList;
	va_start(argList, lpszFormat);
	str.FormatV(lpszFormat, argList);
	
	va_end(argList);

	m_listHeader.AddString(str) ;
}

void CPlxReaderDlg::DumpHeaders()
{
	int iChannel ;
	int iUnit ;
	CString str ;
	CString s ;
	
	Put("PLX File Version(%d) Date: %d/%d/%d %d:%d:%d: %s",
		m_fileHeader.Version,
		m_fileHeader.Month,
		m_fileHeader.Day,
		m_fileHeader.Year,
		m_fileHeader.Hour,
		m_fileHeader.Minute,
		m_fileHeader.Second,
		m_fileHeader.Comment) ;

	Put ("  ADFrequency %d", m_fileHeader.ADFrequency) ;
	Put ("  WaveformFreq %d", m_fileHeader.WaveformFreq) ;
	Put ("  NumPointsWave %d", m_fileHeader.NumPointsWave) ;
	Put ("  NumPointsPerThr %d", m_fileHeader.NumPointsPreThr) ;

	Put ("  LastTimestamp %.0lf", m_fileHeader.LastTimestamp) ;

	if (m_fileHeader.Version >= 103)
	{
		Put ("  Trodalness %d", m_fileHeader.Trodalness) ;
		Put ("  DataTrodalness %d", m_fileHeader.DataTrodalness) ;
		Put ("  BitsPerSpikeSample %d", m_fileHeader.BitsPerSpikeSample) ;
		Put ("  BitsPerSlowSample %d", m_fileHeader.BitsPerSlowSample) ;
		Put ("  NumDSPChannels %d", m_fileHeader.NumDSPChannels) ;
		Put ("  NumEventChannels %d", m_fileHeader.NumEventChannels) ;
		Put ("  NumSlowChannels %d", m_fileHeader.NumSlowChannels) ;

		Put ("  SpikeMaxMagitudeMV %d", m_fileHeader.SpikeMaxMagnitudeMV) ;
		Put ("  SlowMaxMagnitudeMV %d", m_fileHeader.SlowMaxMagnitudeMV) ;
	}

	Put (" ") ;
	Put ("Spike Counts") ;
	for (iChannel = 0 ; iChannel < 130 ; iChannel++)
	{
		for (iUnit = 0 ; iUnit < 5 ; iUnit++)
		{
			int count = m_fileHeader.TSCounts[iChannel][iUnit] ;
			if (count > 0)
			{
				int countWF = m_fileHeader.WFCounts [iChannel][iUnit] ;
				Put("  Channel %d, Unit %d: Time Stamp %d, Waveform %d", iChannel, iUnit, count, countWF) ;
			}
		}
	}

	Put (" ") ;
	Put ("Event Counts") ;
	for (iChannel = 0 ; iChannel < 300 ; iChannel++)
	{
		int count = m_fileHeader.EVCounts[iChannel] ;
		if (count > 0)
		{
			Put ("  Index %d Event Channel %d: Count %d", iChannel, iChannel, count) ;
		}
	}
	for (iChannel = 300 ; iChannel < 512 ; iChannel++)
	{
		int count = m_fileHeader.EVCounts[iChannel] ;
		if (count > 0)
		{
			Put ("  Index %d Slow Channel %d: Count %d", iChannel, iChannel-300+1, count) ;
		}
	}

	Put (" ") ;
	Put ("Spike Data Channels") ;
	for (iChannel = 0 ; iChannel < m_fileHeader.NumDSPChannels ; iChannel++)
	{
		PL_ChanHeader * pSpikeChannel = & m_spikeChannels[iChannel] ;

		Put ("  Channel %d Name(%s) Sig(%s): WFRate %d, SIG %d Ref %d Gain %d Filter %d Threshold %d", 
			pSpikeChannel->Channel,
			pSpikeChannel->Name,
			pSpikeChannel->SIGName,
			pSpikeChannel->WFRate, 
			pSpikeChannel->SIG,
			pSpikeChannel->Ref, 
			pSpikeChannel->Gain, 
			pSpikeChannel->Filter, 
			pSpikeChannel->Threshold) ;

		if (pSpikeChannel->Method == 1)
		{
			int nUnits = pSpikeChannel->NUnits ;
			if (nUnits > 0)
			{
				Put ("    Method: %d - Boxes  NUnits %d", 
					pSpikeChannel->Method,
					nUnits) ;

				for (iUnit = 1 ; iUnit < (nUnits+1) ; iUnit++)
				{
					Put("    Boxes[%d][2][4]: (%d,%d,%d,%d) and (%d,%d,%d,%d)", iUnit, 
						pSpikeChannel->Boxes[iUnit][0][0],
						pSpikeChannel->Boxes[iUnit][0][1],
						pSpikeChannel->Boxes[iUnit][0][2],
						pSpikeChannel->Boxes[iUnit][0][3],
						pSpikeChannel->Boxes[iUnit][1][0],
						pSpikeChannel->Boxes[iUnit][1][1],
						pSpikeChannel->Boxes[iUnit][1][2],
						pSpikeChannel->Boxes[iUnit][1][3]) ;
				}
			}
		}
		else if (pSpikeChannel->Method == 2)
		{
			int nUnits = pSpikeChannel->NUnits ;
			if (nUnits > 0)
			{
				Put ("    Method: %d - Templates  NUnits %d SortBeg %d SortWidth %d", 
					pSpikeChannel->Method,
					nUnits,
					pSpikeChannel->SortBeg,
					pSpikeChannel->SortWidth) ;
	
				for (iUnit = 1 ; iUnit < (nUnits+1) ; iUnit++)
				{
					str.Format("    Template[%d][]", iUnit) ;

					for (int iSample = 0 ; iSample < m_fileHeader.NumPointsWave ; iSample++)
					{
						s.Format(" %d", pSpikeChannel->Template[iUnit][iSample]) ;
						str += s ;
					}
					Put(str) ;
				} 
				for (iUnit = 1 ; iUnit < (nUnits+1) ; iUnit++)
				{
					Put("    Fit[%d]: %d", iUnit, pSpikeChannel->Fit[iUnit]) ;
				} 
			}
		}
		else
		{
			Put("    Method: %d - Unknown", pSpikeChannel->Method) ;
			Put("    NUnits: %d", pSpikeChannel->NUnits) ;
		}
	}

	// Dump the event channel headers
	Put (" ") ;
	Put("Event Channel Headers") ;
	for (iChannel = 0 ; iChannel < m_fileHeader.NumEventChannels ; iChannel++)
	{
		PL_EventHeader * pEventChannel = & m_eventChannels [iChannel] ;

		Put("  Channel %d Name(%s)", 
			pEventChannel->Channel,
			pEventChannel->Name) ; 
			//pEventChannel->IsFrameEvent) ;
	}

	// Dump the slow A/D channel headers
	Put (" ") ;
	Put ("Slow A/D Channel Headers") ;
	for (iChannel = 0 ; iChannel < m_fileHeader.NumSlowChannels ; iChannel++)
	{
		PL_SlowChannelHeader * pSlowChannel = & m_slowChannels [iChannel] ;

		Put ("  Channel %d Name(%s): ADFreq %d Gain %d Enabled %d PreAmpGain %d", 
			pSlowChannel->Channel+1,  // report to the UI 1-based even though internally it is zero-based
			pSlowChannel->Name,
			pSlowChannel->ADFreq,
			pSlowChannel->Gain,
			pSlowChannel->Enabled,
			pSlowChannel->PreAmpGain) ; 
	}	
}


/////////////////////////////////////////////////////////////////////////////
// Opens, reads, and displays a PLX file specified by m_fileName.  
/////////////////////////////////////////////////////////////////////////////

void CPlxReaderDlg::OnBnClickedReadFile() {

	CWaitCursor wait;

	// Have the controls on the main dialog box reflect that a PLX file is not currently loaded.
	EnableControlsToLoad () ;

	// Retrieve the file name (including path) of the PLX file to be read.
	GetDlgItemText(IDC_FILENAME,m_fileName);

	// make sure any previously open files are closed
	if (m_bOpen)
	{
		m_file.Close() ;
		m_bOpen = false ;
	}

	// Open the PLX file using the built-in file exception logic to log any errors.
	CFileException ex;
	if (!m_file.Open(m_fileName, CFile::shareDenyNone | CFile::modeRead, &ex))
	{
		ex.ReportError() ;
		return ;
	}
	m_bOpen = true ;

	// Read the file header and the channel headers.
	int error = ReadHeaders () ;


	if (error == 0)
	{
		// Dump a text version of the headers to the upper list box.
		DumpHeaders () ;
	
		// Have the controls on the main dialog box reflect that a valid file has been loaded.
		EnableControlsToExtract () ;
	}
	else
	{
		AfxMessageBox ("Invalid PLX file.") ;
	}
}

/////////////////////////////////////////////////////////////////////////////
// Sets the controls on the main dialog box to indicate that there is no 
// currently loaded PLX file.  
/////////////////////////////////////////////////////////////////////////////

void CPlxReaderDlg :: EnableControlsToLoad ()
{
	// The upper list box containing the header information is cleared.
	m_listHeader.ResetContent() ;
	// The lower list box containing the data is cleared.
	m_listData.ResetContent() ;
	// The extract button is disabled since there is no file to extract data from.
	m_buttonExtract.EnableWindow(false) ;
	// The progress bar is reset to 0% compelete.
	m_progress.SetPos (0) ;
}

/////////////////////////////////////////////////////////////////////////////
// Sets the controls on the main dialog box to indicate that a valid PLX file
// has been loaded.
/////////////////////////////////////////////////////////////////////////////

void CPlxReaderDlg :: EnableControlsToExtract () 
{
	// The extract button is enable since there is a file loaded to extract data from.
	m_buttonExtract.EnableWindow(true) ;
	// The progress bar is reset to 0% complete.
	m_progress.SetPos (0) ;
}

/////////////////////////////////////////////////////////////////////////////
// This message handler is called when the application is closing.
/////////////////////////////////////////////////////////////////////////////

void CPlxReaderDlg::OnClose() 
{	
	CDialog::OnClose();
}

/////////////////////////////////////////////////////////////////////////////
// Extracts data from the PLX file and displays it in the lower list box.
// The data extracted and displayed is dependent on the Show Spike, Event, 
// and Slow checkboxes.
/////////////////////////////////////////////////////////////////////////////

void CPlxReaderDlg::OnExtract() 
{
	CWaitCursor wait;

	// See if the user wants to extract the spike data blocks
	int bShowSpike = m_buttonCheckSpike.GetCheck() ;
	// See if the user wants to extract the event data blocks 
	int bShowEvent = m_buttonCheckEvent.GetCheck() ;
	// See if the user wants to extract the slow A/D data blocks
	int bShowSlow = m_buttonCheckSlow.GetCheck() ;

	// If no boxes are checked, assume the user want to extract only spike data blocks.
	if ((bShowSpike == false) && (bShowEvent == false) && (bShowSlow == false))
	{
		m_buttonCheckSpike.SetCheck(1) ;
		bShowSpike = m_buttonCheckSpike.GetCheck() ;
	}

	// Disable the list box from redrawing until all of the items have been added.
	m_listData.SetRedraw(false) ;
	// Clear all of the previously added data blocks.
	m_listData.ResetContent () ;

	// Get the total length of the PLX file in bytes for updating the progress bar.
	DWORD fileLength = (DWORD)m_file.GetLength() ;

	// Allocate a buffer for the waveform samples
	short waveformSamples [MAX_SAMPLES_PER_WAVEFORM] ;

	int iBlock ;
	CString str ;
	CString s ;

	// Go to the beginning of the datablocks in the open PLX file.
	m_file.Seek(m_dataPosition, 0) ;
	
	// Rip through the remaining file examining data blocks.
	for (iBlock = 0 ; ; iBlock++)
	{
		// Reserve space for the current data block header.
		PL_DataBlockHeader dataBlock ;

		// Read the next data block header in the file.
		if (m_file.Read((void*)&dataBlock, sizeof(dataBlock)) != sizeof(dataBlock)) break ;

		// Read the waveform samples if present.
		int nWords = dataBlock.NumberOfWaveforms * dataBlock.NumberOfWordsInWaveform ;
		if (m_file.Read(waveformSamples, nWords*sizeof(short)) != nWords*sizeof(short)) break ;


		// Add an item in the lower list box for any data blocks.  Only show the data blocks that 
		// have Types selected by the user.
		if ((bShowSpike && (dataBlock.Type == PL_SingleWFType)) ||
			(bShowEvent && (dataBlock.Type == PL_ExtEventType)) ||
			(bShowSlow && (dataBlock.Type == PL_ADDataType)))
		{
			CString strType ;
			CString strTimeStamp ;
			CString strTimeStampTicks ;
			CString strChannel ;
			CString strUnit ;
			CString strData ;

			// Display the type using a label instead of just a number.
			if (dataBlock.Type == PL_SingleWFType)
			{
				strType = "Spike" ;
				strChannel.Format("%d", dataBlock.Channel) ;
			}
			else if (dataBlock.Type == PL_ExtEventType)
			{
				strType = "Event" ;
				strChannel.Format("%d", dataBlock.Channel) ;
			}
			else if (dataBlock.Type == PL_ADDataType)
			{
				strType = "Slow" ;
				strChannel.Format("%d", dataBlock.Channel+1) ;  // report to the UI 1-based even though internally 0-based
			}
			else
			{
				strType = "???" ;
			}

			// Convert the timestamp of the current blcok to seconds for display.
			LONGLONG ts = ((static_cast<LONGLONG>(dataBlock.UpperByteOf5ByteTimestamp)<<32) + static_cast<LONGLONG>(dataBlock.TimeStamp)) ;
			double seconds = (double) ts / (double) m_fileHeader.ADFrequency ;
			strTimeStamp.Format("%12.6f", seconds) ;
			strTimeStampTicks.Format("%12ld", ts) ;//ticks
		

			// Display the unit number
			strUnit.Format("%d", dataBlock.Unit) ;

			// Display the waveform samples as a list of values.
			strData = " " ;
			if (nWords > 0)
			{
				CString strSample ;
				for (int iWord = 0 ; iWord < nWords ; iWord++)
				{
					strSample.Format(" %d", waveformSamples[iWord]) ;
					strData += strSample ;
				}
			}

			// Format and add the description of the data block to the list box.
			str.Format("%6s%13s%13s%8s%5s", strType, strTimeStamp, strTimeStampTicks, strChannel, strUnit) ;
			str += strData ;
			m_listData.AddString(str) ;
		}

		// Update the progress bar using percent file read.
		float file_pos = (float) m_file.GetPosition() ;
		float file_len = (float) fileLength ;

		int percent = (int) (file_pos * 100.0f / file_len) ;
		m_progress.SetPos(percent) ;

		// Quit reading data blocks when the maximum number of blocks is read.  A real 
		// application normally reads all of the data blocks.
		if ((iBlock+1) > MAX_DATA_BLOCKS)
		{
			CString msg ;
			msg.Format("Only the first %d data blocks were extracted.", MAX_DATA_BLOCKS) ;
			m_listData.AddString(msg) ;
			AfxMessageBox(msg) ;
			break ;
		}
	}

	// reset the progress bar back to 0%
	m_progress.SetPos(0) ;
	// Allow the list box containing the data block items to redraw.
	m_listData.SetRedraw(true) ;
}

/////////////////////////////////////////////////////////////////////////////
// END
/////////////////////////////////////////////////////////////////////////////
