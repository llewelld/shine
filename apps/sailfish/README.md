# Scintillon

Scintillon is a Philips Hue compatible smart home app that lets you control your Hue lighting using your Sailfish OS phone.

## Building from source

Scintillon uses libhue which is included in the same repository. The library and app can be built using the Sailfish SDK. To get it to work you need to edit the `apps/apps.pro` file to replace the `SUBDIRS += qtcontrols2` line with `SUBDIRS += sailfish`. Then load the root `shine.pro` project into the Sailfish SDK and build as normal.

## Compatibility

Scintillon has been tested on an Xperia XA2 runnning Sailfish OS 3.1.0. It still needs some work to accommodate light ambiences, but functionality isn't affected. The app is still very much in beta state so comes with no guarantees that it'll work correctly, although I'd be grateful for any bug reports.

## Licence

Scintillon and libhue are both released under the GPLv2 licence. See the LICENSE file for the full details.

## Contact and Links

More information about the app can be found at: http://www.flypig.co.uk/?to=scintillon

The source code can be obtained from GitHub: https://github.com/llewelld/shine

A packaged binary can be downloaded from the Jolla store or OpenRepos: https://openrepos.net/content/flypig/scintillon

I can be contacted via one of the following.

- Website: https://www.flypig.co.uk
- Email: david@flypig.co.uk

## Contributors

David Llewellyn-Jones <david@flypig.co.uk>, Scintillon app
Michael Zanetti <michael_zanetti@gmx.net>, libhue
Rui Kon <dashinfantry@gamil.com>, Chinese localisation
Francesco Vaccaro <fravaccaro90@gmail.com>, Italian localisation
