/*****************************************************************************
 XVector C interface: typedefs and defines
 -----------------------------------------

   The XVector C interface is split in 2 files:
     1. XVector_defines.h (this file): contains the typedefs and defines
        of the interface.
     2. XVector_interface.h (in this directory): contains the prototypes
        of the XVector C routines that are part of the interface.

   Please consult XVector_interface.h for how to use this interface in your
   package.

 *****************************************************************************/
#ifndef XVECTOR_DEFINES_H
#define XVECTOR_DEFINES_H

#include "IRanges_defines.h"

#include <Rdefines.h>
#include <R_ext/Rdynload.h>


typedef struct xvector_list_holder {
	const char *classname;
	const char *element_type;
	SEXP xp_list;
	int length;
	const int *start;
	const int *width;
	const int *group;
} XVectorList_holder;

#endif
