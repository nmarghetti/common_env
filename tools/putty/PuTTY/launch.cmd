@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\PuTTY"
START /B PUTTY.EXE

::https://the.earth.li/~sgtatham/putty/0.73/htmldoc/Chapter4.html#config-file
::
::4.30 Storing configuration in a file
::
::PuTTY does not currently support storing its configuration in a file instead of the Registry. However, you can work around this with a couple of batch files.
::
::You will need a file called (say) PUTTY.BAT which imports the contents of a file into the Registry, then runs PuTTY, exports the contents of the Registry back into the file, and deletes the Registry entries. This can all be done using the Regedit command line options, so it's all automatic. Here is what you need in PUTTY.BAT:
::
::@ECHO OFF
::regedit /s putty.reg
::regedit /s puttyrnd.reg
::start /w putty.exe
::regedit /ea new.reg HKEY_CURRENT_USER\Software\SimonTatham\PuTTY
::copy new.reg putty.reg
::del new.reg
::regedit /s puttydel.reg
::
::This batch file needs two auxiliary files: PUTTYRND.REG which sets up an initial safe location for the PUTTY.RND random seed file, and PUTTYDEL.REG which destroys everything in the Registry once it's been successfully saved back to the file.
::
::Here is PUTTYDEL.REG:
::
::REGEDIT4
::
::[-HKEY_CURRENT_USER\Software\SimonTatham\PuTTY]
::
::Here is an example PUTTYRND.REG file:
::
::REGEDIT4
::
::[HKEY_CURRENT_USER\Software\SimonTatham\PuTTY]
::"RandSeedFile"="a:\\putty.rnd"
::
::You should replace a:\putty.rnd with the location where you want to store your random number data. If the aim is to carry around PuTTY and its settings on one USB stick, you probably want to store it on the USB stick.
