# +--------------------------------------------------------------------+
# Copyright (C) 2012  http://www.efa-project.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# +--------------------------------------------------------------------+

E.F.A stands for Email Filter Appliance
E.F.A is born out of a need for a cost-effective email virus & spam scanning solution after the ESVA project died.

We try to create a complete package using existing open-source anti-spam projects and combine them to a single easy to use (virtual) appliance.

Current available version: 0.2
Current development version: 0.3

#------------------------------------------#
# Changes in 0.3

- Postfix mydestination was not updated during configuration.
- EFA-Update in 0.2 was the wrong version, correct version added to 0.3
  (Manual update will be needed from 0.2 to 0.3)
- EFA-Configure is moved to EFA-Init (to be run once for initial config)
- New EFA-Configure script to modify the system after initial config and to configure new features.
- - Option to change IP 
- - Option to change hostname
- - Option to enable relaying for specific hosts (internal LAN for example)
- - Option to enable outgoing smarthost
- - Option to change admin email adres
- - Option to change baruwa' s quarantine host report URL.

#------------------------------------------#
# 0.2

- First E.F.A release.