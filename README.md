<p align="center" >
  <img src="http://www.efa-project.org/wp-content/uploads/2012/10/logo-2-55px.png" alt="EFA" title="EFA">
</p>

E.F.A stands for Email Filter Appliance.
E.F.A is born out of a need for a cost-effective email virus & spam scanning solution after the ESVA project died.

We try to create a complete package using existing open-source anti-spam projects and combine them to a single easy to use (virtual) appliance.

For more information go to http://www.efa-project.org

Current available version: 0.3
Current development version: see https://github.com/E-F-A

Latest development is done on the https://github.com/E-F-A repository
#------------------------------------------#
# Changes in 0.4
- Fixed hostname change.
- Kernel 3.2.0 from backports for hyper-v support
- Fixed EFA-Update get_version bug
- Fixed baruwa DEFAULT_MAIL_FROM configuration value

#------------------------------------------#
# Changes in 0.3

- Postfix mydestination was not updated during configuration.
- EFA-Update in 0.2 was the wrong version, correct version added to 0.3
  (Manual update will be needed from 0.2 to 0.3)
- EFA-Configure is moved to EFA-Init (to be run once for initial config)
- apt-get questions pre-answered during install.
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
