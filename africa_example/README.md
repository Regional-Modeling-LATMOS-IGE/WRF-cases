This folder contai.ns scripts to launch a WRF run on ciclad.

Léo Clauzel (leo.clauzel@univ-grenoble-alpes.fr)
20/05/2022

**Case description**
One week simulation (from 2010-04-01 to 2010-04-07) forced by ERA5 hourly data
2 nested domains over West Africa

**Prerequistes:** WRF and WPS installed and compiled and WPS data downloaded.


**Configuration and compilation:**
WRF:
- Run configure_wrf.sh then compile_wrf.sh

WPS:
- Run configure_wps.sh then compile WPS

**Instructions:**
- Configure your WPS namelist options.
- Set your directory paths in the WPS jobscript and then run the WPS script.
- Configure your WRF namelist options and make sure it is consistent with the WPS options.
- Set the directory paths to your compiled WRF model, WPS outputs, and desired output directory
  in the WRF jobscript and then launch.
- Check that you are getting output in your output directory.

**Files:** 
- namelist.wps.africa : Namelist file for WPS
- namelist.input.africa : Namelist file for WRF
- jobscript_wps.sh : Jobscript to run WPS
- jobscript_wrf.sh : Jobscript to run real.exe and wrf.exe.

