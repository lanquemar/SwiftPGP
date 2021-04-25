// MIT License
//
// Copyright (c) 2021 Adrien Vasseur
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

struct SwiftPGPPacket {
    
    enum PacketValidationError: Error {
        case Empty
        case CorruptedFile
        case NotImplemented(name: String)
    }
    
    public let tag: UInt8
    public let newFormat: Bool
    public let headerLength: UInt32
    public let packetLength: UInt32
    public let content: Data
    
    public init(tag: UInt8, newFormat: Bool, headerLength: UInt32, packetLength: UInt32, content: Data) {
        self.tag = tag
        self.newFormat = newFormat
        self.headerLength = headerLength
        self.packetLength = packetLength
        self.content = content
    }
    
    public static func parse(content: Data) throws -> SwiftPGPPacket {
        guard content.count > 0 else {
            throw PacketValidationError.Empty
        }

        let tagBit7: UInt8 = content[0] & 0x80

        // MUST be set
        guard tagBit7 == 0x80 else {
            throw PacketValidationError.CorruptedFile
        }

        let tagBit6: UInt8 = content[0] & 0x40
        
        // new format packet is used
        if (tagBit6 != 0) {
            throw PacketValidationError.NotImplemented(name: "New format packet not implemented")
        } else {
            let tagNumber: UInt8 = (content[0] & 0x3C) >> 2
            let lengthType: UInt8 = content[0] & 0x03
            var headerLength: UInt32
            var packetLength: UInt32
            
            switch (lengthType) {
            case 0:
                // packet header is 2 bytes long
                guard content.count > 1 else {
                    throw PacketValidationError.CorruptedFile
                }
                headerLength = 2
                packetLength = UInt32(content[1])
                
                break;
            case 1:
                // packet header is 3 bytes long
                guard content.count > 2 else {
                    throw PacketValidationError.CorruptedFile
                }
                headerLength = 3
                packetLength = (UInt32(content[1]) << 8) | UInt32(content[2])
                break;
            case 2:
                // packet header is 5 bytes long
                guard content.count > 4 else {
                    throw PacketValidationError.CorruptedFile
                }
                headerLength = 5
                packetLength = (UInt32(content[1]) << 24) | (UInt32(content[2]) << 16) | (UInt32(content[3]) << 8) | UInt32(content[4])
                break;
            default:
                throw PacketValidationError.NotImplemented(name: "Packet has indeterminate length")
            }
            
            guard content.count > (headerLength + packetLength) else {
                throw PacketValidationError.CorruptedFile
            }
            
            return SwiftPGPPacket(tag: tagNumber, newFormat: false, headerLength: headerLength, packetLength: packetLength, content: content.subdata(in: Int(headerLength)..<Int(packetLength)))
        }
    }
}
