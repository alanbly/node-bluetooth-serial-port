/*
 * Copyright (c) 2012-2013, Eelco Cramer
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

#import "BluetoothDeviceResources.h"
#import <IOBluetooth/objc/IOBluetoothSDPServiceRecord.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>

@implementation BluetoothDeviceResources

@synthesize producer;
@synthesize device;
@synthesize channel;

+ (void)publishService:(BluetoothRFCOMMChannelID*)mServerChannelID :(BluetoothSDPServiceRecordHandle*)mServerHandle
{
    std::cout << "publishService 1" << std::endl;
    NSString            *dictionaryPath = nil;
    NSString            *serviceName = nil;
    NSMutableDictionary *sdpEntries = nil;

    // Create a string with the new service name.
    serviceName = @"%@ BitStream";

    // Get the path for the dictionary we wish to publish.
    dictionaryPath = [[NSBundle mainBundle]
                      pathForResource:@"ServiceInfo" ofType:@"plist"];

    if ( ( dictionaryPath != nil ) && ( serviceName != nil ) )
    {
        std::cout << "publishService 2" << std::endl;
        // Initialize sdpEntries with the dictionary from the path.
        sdpEntries = [NSMutableDictionary
                      dictionaryWithContentsOfFile:dictionaryPath];

        if ( sdpEntries != nil )
        {
            std::cout << "publishService 3" << std::endl;
            IOBluetoothSDPServiceRecordRef  serviceRecordRef;

            [sdpEntries setObject:serviceName forKey:@"0100 - ServiceName*"];

            // Create a new IOBluetoothSDPServiceRecord that includes both
            // the attributes in the dictionary and the attributes the
            // system assigns. Add this service record to the SDP database.

            if (IOBluetoothAddServiceDict( (CFDictionaryRef) sdpEntries,
                                          &serviceRecordRef ) == kIOReturnSuccess)
            {
                std::cout << "publishService 4" << std::endl;
                IOBluetoothSDPServiceRecord *serviceRecord;

                serviceRecord = [IOBluetoothSDPServiceRecord
                                 withSDPServiceRecordRef:serviceRecordRef];

                // Preserve the RFCOMM channel assigned to this service.
                // A header file contains the following declaration:
                // IOBluetoothRFCOMMChannelID mServerChannelID;
                [serviceRecord getRFCOMMChannelID:mServerChannelID];

                // Preserve the service-record handle assigned to this
                // service.
                // A header file contains the following declaration:
                // IOBluetoothSDPServiceRecordHandle mServerHandle;
                [serviceRecord getServiceRecordHandle:mServerHandle];

                // Now that we have an IOBluetoothSDPServiceRecord object,
                // we no longer need the IOBluetoothSDPServiceRecordRef.
                //IOBluetoothObjectRelease( serviceRecordRef );


                std::cout << "publishService 5 " << *mServerChannelID << " " << *mServerHandle << std::endl;
                
            }
        }
    }
}

@end
