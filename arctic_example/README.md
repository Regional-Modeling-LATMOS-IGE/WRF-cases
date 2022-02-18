This folder contains scripts to launch a WRF run on ciclad.

Shaddy Ahmed (shaddy.ahmed@univ-grenoble-alpes.fr)
18/02/2022

Prerequistes: WRF and WPS installed and compiled and WPS data downloaded.

Instructions:
- Configure your WPS namelist options.
- Set your directory paths in the WPS jobscript and then run the WPS script.
- Configure your WRF namelist options and make sure it is consistent with the WPS options.
- Set the directory paths to your compiled WRF model, WPS outputs, and desired output directory
  in the WRF jobscript and then launch.
- Check that you are getting output in your output directory.

Files: 
- namelist.wps.example : Namelist file for WPS
- namelist.input.example : Namelist file for WRF
- jobscript_wps.sh : Jobscript to run WPS
- jobscript_wrf.sh : Jobscript to run real.exe and wrf.exe.

