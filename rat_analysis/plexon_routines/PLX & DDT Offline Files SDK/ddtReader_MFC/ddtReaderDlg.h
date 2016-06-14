/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// ddtReaderDlg.h : header file
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_ddtReaderDLG_H__A5521970_EFBA_4B0D_9EB8_804D4E2E9A12__INCLUDED_)
#define AFX_ddtReaderDLG_H__A5521970_EFBA_4B0D_9EB8_804D4E2E9A12__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "stdafx.h"
#include <afxtempl.h>
#include <stdio.h>
#include <windows.h>
#include "..\plexon.h"

// Maximum number of samples read by this application
#define MAX_SAMPLES (5000)

/////////////////////////////////////////////////////////////////////////////
// CDdtReaderDlg dialog
/////////////////////////////////////////////////////////////////////////////

class CDdtReaderDlg : public CDialog
{
// Construction
public:
	CDdtReaderDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CDdtReaderDlg)
	enum { IDD = IDD_DDTREADER_DIALOG };
	CButton	m_buttonHeader;
	CScrollBar	m_scrollbarChannel;
	CListBox	m_listFileHeader;
	CListBox	m_listData;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDdtReaderDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON		m_hIcon;

	// DDT file name and path
	CString		m_fileName;
	CString     m_filePath;

	bool m_bOpen ;

	// Open DDT file
	CFile	m_ddtFile;

	// DDT File header
	DigFileHeader	m_fileHeader;

	// Courier font used by the button that displays the data header
	CFont m_fontHeader ;

	// Courier font used by the list box that displays the data items
	CFont m_fontData ;

	// Start channel used to horizontally scroll channels
	int m_startChannel ;

  // Map of the channels that were enabled / recorded
  int m_iChannelMap[64]; 

  // Conversion factor from raw integer samples to voltage  
  float m_fScaleRawSampleValueToVoltage;


	// Dumps data samples to the lower list box
	void DumpData(bool bReport) ;

	// Generated message map functions
	//{{AFX_MSG(CDdtReaderDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnClose();
	afx_msg void OnBnClickedBrowse();
	afx_msg void OnBnClickedReadFile();
	afx_msg void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ddtReaderDLG_H__A5521970_EFBA_4B0D_9EB8_804D4E2E9A12__INCLUDED_)
