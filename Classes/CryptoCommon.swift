//
//  CryptoCommon.swift
//  CryptoExercise
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/4/18.
//
//
/*

 File: CryptoCommon.h
 Abstract: Common defines that are used between the Crypto-Client/Server.

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

let kBonjourServiceType = "_crypttest._tcp"
let kMessageBody = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do \n" +
    "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut \n" +
    "enim ad minim veniam, quis nostrud exercitation ullamco laboris \n" +
    "nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor \n" +
    "in reprehenderit in voluptate velit esse cillum dolore eu fugiat \n" +
    "nulla pariatur. Excepteur sint occaecat cupidatat non proident, \n" +
    "sunt in culpa qui officia deserunt mollit."

let kMesTag = "cryptoM"
let kSigTag = "cryptoS"
let kPubTag = "cryptoP"
let kSymTag = "cryptoK"
let kPadTag = "crypto7"
let kMaxMessageLength = 1024*1024*5
// Valid sizes are currently 512, 1024, and 2048.
let kAsymmetricSecKeyPairModulusSize = 512

//###Remove ALLOW_TO_CONNECT_TO_SELF from BuildSettings>Swift Compiler>Custom Flags to disallow the feature.
// Uncomment line below to allow connection to self.
//
// #define ALLOW_TO_CONNECT_TO_SELF 1
//