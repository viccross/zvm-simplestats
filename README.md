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
* Perl script (invoked by `cron`) to generate JSON and text files
* HTML page served by Apache and containing Javascript code to query and process JSON file and draw the dials.

### Dependencies
* HTTP server (any server is usable now that there is no Apache SSI dependency)
* Perl (whatever comes with your Linux should be fine)
* `vmcp` (to issue z/VM commands).  `vmcp` is usually run by UID 0, but you can run under a different user id if you prefer by doing the following:
  * Create a user for running the Perl script.  This user would require access to write to the `zvm-stats` directory under the webroot
  * Set up `sudo` to allow the user runing the script to issue `vmcp`
  * Either edit the script and replace `vmcp` with `sudo vmcp` or alias `vmcp` to `sudo vmcp` for the user

The following code is included under the terms of their respective licences (MIT License):
* JustGage 
* Raphael vector image library (version 2.1.4 supplied)

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
* Download and unwind the release file
* Copy the Perl script to `/usr/local/sbin` (or equivalent)
* Modify the `httpdir` path in the script as necessary
* Copy the `zvm-stats` directory to the `httpdir`
* Set up to run `metrics.pl` at regular intervals (sample crontab file could be installed as `/etc/cron.d/metrics` in many cron implementations, to execute the script every minute)
* (Optional) set up non-root execution as described above

The page will be available at http://your.web.server/zvm-stats

## Usage
The page shows five metrics of the z/VM system:
* Number of logged-on guests
* CPU utilisation (percent of total CPU available)
* Paging rate
* Page space utilised (percent)
* LPAR memory available

The non-percentage graphs rescale according to the value shown.
This is particularly relevant to the paging rate graph, which may give an impression of a high paging rate when in reality the system could sustain much greater rates of paging.
Because it is very difficult to determine how much paging is "too much", an appropriate way to scale this dial so that it conveys an appropriate sense of urgency at excessive paging is still a topic of debate.

The memory graph does not scale, but the maximum value on the graph reflects the total possible amount of memory (i.e. base plus reserved) the LPAR has access to.  So on an LPAR with 20G of base memory and 80G reserved memory, the graph maximum will be at 100G (and the needle pointing to 20G as you might expect).

### Detail views
Clicking on the CPU utilisation or Page space usage graphs shows an overlay that displays the z/VM command output that provides the data.
This allows some additional detail to be seen.
For CPU utilisation, the overlay shows the output of the z/VM `INDICATE LOAD` command which provides per-CPU utilisation as well as polarisation detail.
For Page space, the overlay shows the output of the `QUERY ALLOC PAGE` command and illustrates per-volume page space utilisation.

## Futures
Some possible future features include:
* "Virtual-to-real" graph, to show memory over-commitment
* Display of SMT factors (MT ratio, core utilisation, etc)
* Option to write data externally (RRDtool, Influx, etc) for more than just point-in-time view 
