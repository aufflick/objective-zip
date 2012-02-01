This is a copy of [objective-zip library](http://code.google.com/p/objective-zip/) developed by [Flying Dolphin Studio](http://www.flyingdolphinstudio.com). 

The following changes were made by AgileBits:

* Test application was moved into its own folder. Simply add MiniZip and Objective-Zip folders to your project.
* ZLib source code was removed and replaced with the shared libz.dylib library available on both Mac OS X and iOS.
* Weak encryption code in MiniZip library was explicitly disabled by removing crypt.h and defining NOCRYPT and NOUNCRYPT.
* Compiler warnings reported by LLVM 2.0 compiler (Xcode 4) were fixed.

The following changes were made by Mark Aufflick:

* Enable direct use of ZipWriteStream as an NSStream delegate
* Start of removing exceptions and replacing with BOOL return/NSError

Code license

* Objective-Zip: [New BSD License](http://www.opensource.org/licenses/bsd-license.php)
* MiniZip: [See MiniZip website](http://www.winimage.com/zLibDll/minizip.html)

