/*
  Part of: Vicare/Tcl
  Contents: Tcl for Vicare
  Date: Wed Jul  8, 2015

  Abstract

	Version functions.

  Copyright (C) 2015 Marco Maggi <marco.maggi-ipsu@poste.it>

  This program is  free software: you can redistribute  it and/or modify
  it under the  terms of the GNU General Public  License as published by
  the Free Software Foundation, either  version 3 of the License, or (at
  your option) any later version.

  This program  is distributed in the  hope that it will  be useful, but
  WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
  MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See  the GNU
  General Public License for more details.

  You  should have received  a copy  of the  GNU General  Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


/** --------------------------------------------------------------------
 ** Headers.
 ** ----------------------------------------------------------------- */

#include "vicare-tcl-internals.h"


/** --------------------------------------------------------------------
 ** Version functions.
 ** ----------------------------------------------------------------- */

ikptr_t
ikrt_tcl_version_interface_current (void)
{
  return IK_FIX(vicare_tcl_VERSION_INTERFACE_CURRENT);
}
ikptr_t
ikrt_tcl_version_interface_revision (void)
{
  return IK_FIX(vicare_tcl_VERSION_INTERFACE_REVISION);
}
ikptr_t
ikrt_tcl_version_interface_age (void)
{
  return IK_FIX(vicare_tcl_VERSION_INTERFACE_AGE);
}
ikptr_t
ikrt_tcl_version (ikpcb_t * pcb)
{
  return ika_bytevector_from_cstring(pcb, vicare_tcl_VERSION_INTERFACE_STRING);
}

/* end of file */
