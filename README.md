# zvm-simplestats
A simple web page displaying stats from z/VM.

## Background
This tool was initially developed as part of my "science experiment" into large-scale Linux cloning using DCSS and NSS on z/VM.
The main interface into that system was via the IRC bot that controlled it, or via z/VM commands.
As part of showcasing the experiment as part of the former Brisbane TEC, I created the original version.
That version used the IRC bot as a backend to write files that were read by Javascript in the browser.

With the FastVM project we required a simple page to show basic z/VM stats so I decided to include the tool from the IRC bot.
The file-writing part was broken out of the IRC bot and made standalone.
Later, I also changed from writing discrete files for each statistic to a single file in JSON format.

This version is essentially the one from FastVM, only with the IBM-internal presentation layer support removed (reverted to simple CSS).  Dependency on Apache Server-Side Includes (SSI) has also been removed.

## Components
The components of the tool are as follows:
* HTTP server (not part of this distributable - any server is usable after the Apache SSI dependency was removed)
* Perl script (invoked by `cron`) to generate JSON and text files
* HTML page served by Apache and containing Javascript code to query and process JSON file and draw the dials.

### Dependencies
The tool is dependent on the following code:
* JustGage 
* Raphael vector image library (version 2.1.4 supplied)

These dependencies are included under the terms of their respective licences (MIT License)

To get full information display the z/VM guest in which the Perl script runs must have z/VM command authority to issue the following:
* `INDICATE LOAD`
* `QUERY STORAGE`
* `QUERY ALLOC PAGE`

This can be achieved simply using a z/VM privilege override.
The following commands will create a new class "K" containing the required commands:
```
 Modify Cmd INDICATE                         IBMclass E PRIVclass EK
 Modify Cmd QUERY         Subcmd ALLOC       IBMclass D PRIVclass DK
 Modify Cmd QUERY         Subcmd STORAGE     IBMclass E PRIVclass EK
```
This class can be added to the existing class "G" used for the guest.

## Installation
* Download the release file
* Copy the Perl script to `/usr/local/sbin` (or equivalent)
* Modify the `httpdir` path in the script as necessary
* Copy the `zvm-stats` directory to the `httpdir`
* Set up to run `metrics.pl` at regular intervals (sample crontab file could be installed as `/etc/cron.d/metrics` in many cron implementations, to execute the script every minute)

The page will be available at http://your.web.server/zvm-stats
