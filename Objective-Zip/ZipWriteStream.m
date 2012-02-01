//
//  ZipWriteStream.m
//  Objective-Zip v. 0.7.2
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright 2009-10 Flying Dolphin Studio. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions 
//  are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the name of Gianluca Bertani nor the names of its contributors 
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "ZipWriteStream.h"
#import "ZipException.h"

#include "zip.h"

@interface ZipWriteStream ()

- (void)writeBytes:(const void *)bytes length:(unsigned)length;

@end

@implementation ZipWriteStream

@synthesize delegate;

- (id) initWithZipFileStruct:(zipFile)zipFile fileNameInZip:(NSString *)fileNameInZip {
	if ((self= [super init])) {
		_zipFile= zipFile;
		_fileNameInZip= fileNameInZip;
	}
	
	return self;
}

- (void) writeData:(NSData *)data
{
    [self writeBytes:[data bytes] length:(unsigned)[data length]];
}

- (void)writeBytes:(const void *)bytes length:(unsigned)length
{
	int err = zipWriteInFileInZip(_zipFile, bytes, length);
	if (err < 0)
    {
		NSString *reason= [NSString stringWithFormat:@"Error in writing '%@' in the zipfile", _fileNameInZip];
        [self.delegate zipWriteStream:self didFinishSuccessfully:NO error:[NSError errorWithDomain:@"objective-zip" code:err userInfo:[NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey]]];
	}
}

- (void) finishedWriting
{
	int err= zipCloseFileInZip(_zipFile);
	if (err != ZIP_OK)
    {
		NSString *reason= [NSString stringWithFormat:@"Error in closing '%@' in the zipfile", _fileNameInZip];
        [self.delegate zipWriteStream:self didFinishSuccessfully:NO error:[NSError errorWithDomain:@"objective-zip" code:err userInfo:[NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey]]];
	}
    
    [self.delegate zipWriteStream:self didFinishSuccessfully:YES error:nil];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{    
    switch(eventCode)
    {
        case NSStreamEventErrorOccurred:
        {
            [self.delegate zipWriteStream:self didFinishSuccessfully:NO error:[stream streamError]];
            
            [stream close];
            [stream release];
            break;
        }

        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len)
            {
                [self writeBytes:buf length:len];
            }
            break;
        }

        case NSStreamEventEndEncountered:
        {
            // the class that created the input stream is responsible for closing etc. since
            // we don't even know what runloop was used etc.

            [self finishedWriting];
            
            break;
        }
    }
}


@end
