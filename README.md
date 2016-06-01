# simpleserver
Simple Server Template

Project structure:

	bin – compiler output directory
	client – client application
	common – common files
	cplapplet – applet for windows control panel 
	manager - server settings manager
	server – server application
	service – server guardian (windows service)

How to compile:

	A. Open Project Group from IDE and Build All Projects
	-or-
	B. Execute build_all.cmd (console compiler required and/or use settings in setpaths.cmd)

How to run:

	* Use manager.exe for change settings and state of server
	* Use client.exe (and hosts.txt) on client side
