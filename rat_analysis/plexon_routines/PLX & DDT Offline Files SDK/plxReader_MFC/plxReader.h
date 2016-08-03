/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// plxReader.h : main header file for the PLXREADER application
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_PLXREADER_H__21F98E94_A450_4975_9659_8357357F39AD__INCLUDED_)
#define AFX_PLXREADER_H__21F98E94_A450_4975_9659_8357357F39AD__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CPlxReaderApp:
// See plxReader.cpp for the implementation of this class
//

class CPlxReaderApp : public CWinApp
{
public:
	CPlxReaderApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPlxReaderApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CPlxReaderApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PLXREADER_H__21F98E94_A450_4975_9659_8357357F39AD__INCLUDED_)
