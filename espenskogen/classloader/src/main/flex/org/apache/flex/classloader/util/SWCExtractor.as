/*
 * ////////////////////////////////////////////////////////////////////////////////
 * //
 * //  Licensed to the Apache Software Foundation (ASF) under one or more
 * //  contributor license agreements.  See the NOTICE file distributed with
 * //  this work for additional information regarding copyright ownership.
 * //  The ASF licenses this file to You under the Apache License, Version 2.0
 * //  (the "License"); you may not use this file except in compliance with
 * //  the License.  You may obtain a copy of the License at
 * //
 * //      http://www.apache.org/licenses/LICENSE-2.0
 * //
 * //  Unless required by applicable law or agreed to in writing, software
 * //  distributed under the License is distributed on an "AS IS" BASIS,
 * //  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * //  See the License for the specific language governing permissions and
 * //  limitations under the License.
 * //
 * ////////////////////////////////////////////////////////////////////////////////
 */

/**
 *  CFPE
 */
package org.apache.flex.classloader.util
{
import flash.utils.ByteArray;
import flash.utils.Endian;

/**
 * Util to extract files from a SWC library
 *
 * @see http://www.pkware.com/documents/casestudies/APPNOTE.TXT
 */
public class SWCExtractor
{

    /**
     * Constructor
     */
    public function SWCExtractor(content:ByteArray)
    {
        this.content = content;
    }


    /**
     * Extract a file form the SWC
     *
     * @param name Filename to extract
     */
    public function extract(name:String):ByteArray
    {
        content.endian = Endian.LITTLE_ENDIAN;
        content.position = 0;

        var bytes:ByteArray = new ByteArray();
        bytes.endian = Endian.LITTLE_ENDIAN;


        while (content.bytesAvailable)
        {
            // read fixed metadata portion of local file header
            var fileHeader:FileHeader = readHeader(content);

            // Not a file or end of SWC content
            if (!fileHeader)
            {
                break;
            }

            // read compressed file to offset 0 of bytes; for uncompressed files
            if (fileHeader.compressedSize != 0)
            {
                content.readBytes(bytes, 0, fileHeader.compressedSize);
            }
            else if (fileHeader.uncompressedSize != 0)
            {
                content.readBytes(bytes, 0, fileHeader.uncompressedSize);
            }
            else // need to scan :-(
            {
                if (!scanForFileContent(bytes, content))
                {
                    break; // no content found
                }
            }

            if (fileHeader.filename == name)   // Got a match
            {
                // Decompress
                if (fileHeader.compressionMethod == 8)
                {
                    bytes.inflate();
                }

                return bytes;
            }
        }

        return null;
    }


    /* PRIVATE */

    private var content:ByteArray;

    private static const HEADER_SIGNATURE_BYTE:uint = 0x50;
    private static const FILE_HEADER_SIGNATURE:uint = 0x04034b50;
    private static const FILE_DATA_DESCRIPTOR_SIGNATURE:uint = 0x08074B50;


    /**
     * Read a File Header from the SWC content
     *
     * <p><code>content</code> ByteArray position must be at the beginning of a header</p>
     */
    private function readHeader(content:ByteArray):FileHeader
    {
        var bytes:ByteArray = new ByteArray();
        bytes.endian = Endian.LITTLE_ENDIAN;

        var fileHeader:FileHeader = new FileHeader();
        var offset:int;

        content.readBytes(bytes, 0, 30);
        bytes.position = 0;

        fileHeader.signature = bytes.readInt();
        if (fileHeader.signature != FILE_HEADER_SIGNATURE)
        {
            return null;
        }

        bytes.position = 8;
        fileHeader.compressionMethod = bytes.readByte();  // store compression method (8 == Deflate)

        bytes.position = 18;
        fileHeader.compressedSize = bytes.readUnsignedInt();  // store size of compressed portion
        bytes.position = 22;  // offset to uncompressed size
        fileHeader.uncompressedSize = bytes.readUnsignedInt();  // store uncompressed size

        offset = 0;    // stores length of variable portion of metadata
        bytes.position = 26;  // offset to file name length
        fileHeader.fileNameLength = bytes.readShort();    // store file name
        offset += fileHeader.fileNameLength;     // add length of file name
        bytes.position = 28;    // offset to extra field length
        fileHeader.extraFieldLength = bytes.readShort();
        offset += fileHeader.extraFieldLength;    // add length of extra field

        content.readBytes(bytes, 30, offset);
        bytes.position = 30;
        fileHeader.filename = bytes.readUTFBytes(fileHeader.fileNameLength); // read file name

        return fileHeader;
    }


    /**
     *  Scan the SWC content <code>source</code> for a files content and push into <code>content</code>
     *
     *  @return size of content
     */
    private function scanForFileContent(content:ByteArray, source:ByteArray):int
    {
        const contentPosition:uint = source.position;

        while (source.bytesAvailable)
        {
            if (source.readUnsignedByte() == HEADER_SIGNATURE_BYTE)
            {
                source.position--;
                if (source.readInt() == FILE_DATA_DESCRIPTOR_SIGNATURE)
                {
                    const size:uint = source.position - contentPosition - 4;
                    source.position = contentPosition;
                    source.readBytes(content, 0, size);

                    source.position += 16;    // Skip Data Descriptor
                    break;
                }
            }
        }

        return size;
    }

}
}


/**
 * Private Class defining the zip file header
 *
 * @see http://www.pkware.com/documents/casestudies/APPNOTE.TXT
 */
class FileHeader
{
    public var signature:int;
    public var compressionMethod:int;
    public var fileNameLength:int;
    public var extraFieldLength:int;
    public var filename:String;
    public var compressedSize:uint;
    public var uncompressedSize:uint;
}