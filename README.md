# zvm-simplestats
A simple web page displaying stats from z/VM.

## Background
This tool was initially developed as part of my "science experiment" into large-scale Linux cloning using DCSS and NSS on z/VM.
The main interface into the system was via the IRC bot that controlled it, or via z/VM commands.
As part of showcasing the experiment as part of the former Brisbane TEC, I created the original version.
That version used the IRC bot as a backend to write files that were read by Javascript in the browser.

With the FastVM project, I decided to make the tool standalone.
The file-writing part was broken out of the IRC bot and converted to Bash (from Perl).
Later, I also changed from writing discrete files for each statistic to a single file in JSON format.

## Components
The components of the tool are as follows:
* Apache web server (not part of this distributable)
* Bash script (invoked by `cron`) to generate JSON file
* HTML page served by Apache and containing Javascript code to query and process JSON file and draw the dials.

### Dependencies
The tool is dependent on the following libraries:
* Justgage

To get full information display the z/VM guest in which the Bash script runs must have z/VM command authority to issue the following:
* `INDICATE LOAD`
* `QUERY ALLOC PAGE`

## Installation
* Download the release file
* Copy the Bash script to `/usr/local/sbin` (or equivalent)
* Modify the WEBROOT path in the script if necessary
* Copy the `zvm-stats` directory to the webroot

The page will be available at http://your.web.server/zvm-stats

