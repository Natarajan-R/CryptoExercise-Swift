//
//  CryptoClient.swift
//  CryptoExercise
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/4/18.
//
//
/*

 File: CryptoClient.h
 File: CryptoClient.m
 Abstract: Contains the client networking and cryptographic operations. It
 gets invoked by the ServiceController class when the connect button is
 pressed.

 Version: 1.2

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2008-2009 Apple Inc. All Rights Reserved.

 */

import UIKit

@objc(CryptoClientDelegate)
protocol CryptoClientDelegate {
    
    func cryptoClientDidCompleteConnection(cryptoClient: CryptoClient)
    func cryptoClientDidReceiveError(cryptoClient: CryptoClient)
    func cryptoClientWillBeginReceivingData(cryptoClient: CryptoClient)
    func cryptoClientDidFinishReceivingData(cryptoClient: CryptoClient)
    func cryptoClientWillBeginVerifyingData(cryptoClient: CryptoClient)
    func cryptoClientDidFinishVerifyingData(cryptoClient: CryptoClient, verified: Bool)
    
}

@objc(CryptoClient)
class CryptoClient: NSObject, NSStreamDelegate {
    var service: NSNetService?
    var istr: NSInputStream? = nil
    var ostr: NSOutputStream? = nil
    weak var delegate: protocol<CryptoClientDelegate, NSObjectProtocol>!
    var isConnected: Bool = false
    
    init(service serviceInstance: NSNetService?, delegate anObject: protocol<CryptoClientDelegate, NSObjectProtocol>) {
        self.service = serviceInstance
        self.delegate = anObject
        self.isConnected = false
        super.init()
        self.service?.getInputStream(&istr, outputStream: &ostr)
        
    }
    
    func stream(stream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            if self.ostr?.streamStatus == .Open && self.istr?.streamStatus == .Open && !self.isConnected {
                dispatch_async(dispatch_get_main_queue()) {
                    delegate?.cryptoClientDidCompleteConnection(self)
                }
                self.isConnected = true
            }
        case NSStreamEvent.HasSpaceAvailable:
            if stream === self.ostr {
                if (stream as! NSOutputStream).hasSpaceAvailable {
                    let publicKey = SecKeyWrapper.sharedWrapper().getPublicKeyBits()!
                    let retLen = self.sendData(publicKey)
                    assert(retLen == publicKey.length, "Attempt to send public key failed, only sent \(retLen) bytes.")
                    
                    self.ostr!.close()
                }
            }
        case NSStreamEvent.HasBytesAvailable:
            if stream === self.istr {
                dispatch_async(dispatch_get_main_queue()) {
                    delegate?.cryptoClientWillBeginReceivingData(self)
                }
                let theBlob = self.receiveData()
                self.istr?.close()
                dispatch_async(dispatch_get_main_queue()) {
                    delegate?.cryptoClientDidFinishReceivingData(self)
                }
                if let blob = theBlob {
                    dispatch_async(dispatch_get_main_queue()) {
                        delegate?.cryptoClientWillBeginVerifyingData(self)
                    }
                    let verify = self.verifyBlob(blob)
                    dispatch_async(dispatch_get_main_queue()) {
                        delegate?.cryptoClientDidFinishVerifyingData(self, verified: verify)
                    }
                } else {
                    assert(false, "Connected Server sent too large of a blob.")
                    delegate?.cryptoClientDidReceiveError(self)
                }
            }
        case NSStreamEvent.ErrorOccurred:
            // No debugging facility because we don't want to exit even in DEBUG.
            // It's annoying.
            NSLog("stream: %@", stream)
            delegate?.cryptoClientDidReceiveError(self)
        default:
            break
        }
    }
    
    func runConnection() {
        
        assert(self.istr != nil && self.ostr != nil, "Streams not set up properly.")
        
        if self.istr != nil && self.ostr != nil {
            self.istr!.delegate = self
            self.istr!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            self.istr!.open()
            self.ostr!.delegate = self
            self.ostr!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            self.ostr!.open()
        }
    }
    
    func receiveData() -> NSData? {
        var lengthByte: size_t = 0
        var retBlob: NSMutableData? = nil
        
        var len = withUnsafeMutablePointer(&lengthByte) {lengthBuffer in
            return self.istr?.read(UnsafeMutablePointer(lengthBuffer), maxLength: sizeof(size_t)) ?? 0
        }
        
        assert(len == sizeof(size_t), "Read failure errno: [\(errno)]")
        
        if lengthByte <= kMaxMessageLength && len == sizeof(size_t) {
            retBlob = NSMutableData(length: lengthByte)
            
            len = self.istr?.read(UnsafeMutablePointer(retBlob!.mutableBytes), maxLength: lengthByte) ?? 0
            
            assert(len == lengthByte, "Read failure, after buffer errno: [\(errno)]")
            
            if len != lengthByte {
                retBlob = nil
            }
        }
        
        return retBlob
    }
    
    func sendData(outData: NSData?) -> Int {
        var len: size_t = 0
        
        if let data = outData {
            len = data.length
            if len > 0 {
                let longSize = sizeof(size_t)
                
                let message = NSMutableData(capacity: (len + longSize))!
                message.appendBytes(&len, length: longSize)
                message.appendData(data)
                
                self.ostr?.write(UnsafePointer(message.bytes), maxLength: message.length)
            }
        }
        
        return len
    }
    
    func verifyBlob(blob: NSData) -> Bool {
        var verified = false
        var pad: CCOptions = 0
        
        let peerName = self.service!.name

        do {
            let message = try NSPropertyListSerialization.propertyListWithData(blob, options: NSPropertyListReadOptions(rawValue: NSPropertyListMutabilityOptions.MutableContainers.rawValue), format: nil) as! NSDictionary
        
            
            // Get the unwrapped symmetric key.
            let symmetricKey = SecKeyWrapper.sharedWrapper().unwrapSymmetricKey(message[kSymTag]! as! NSData)
            
            // Get the padding PKCS#7 flag.
            pad = (message[kPadTag]! as! NSNumber).unsignedIntValue
            
            // Get the encrypted message and decrypt.
            let plainText = SecKeyWrapper.sharedWrapper().doCipher(message[kMesTag]! as! NSData,
                key: symmetricKey!,
                context: CCOperation(kCCDecrypt),
                padding: &pad)
            
            // Add peer public key.
            let publicKeyRef = SecKeyWrapper.sharedWrapper().addPeerPublicKey(peerName,
                keyBits: message[kPubTag]! as! NSData)
            
            // Verify the signature.
            verified = SecKeyWrapper.sharedWrapper().verifySignature(plainText!,
                secKeyRef: publicKeyRef!,
                signature: message[kSigTag]! as! NSData)
            
            // Clean up by removing the peer public key.
            SecKeyWrapper.sharedWrapper().removePeerPublicKey(peerName)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        
        return verified
    }
    
    deinit {
        istr?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        ostr?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
    }
    
}