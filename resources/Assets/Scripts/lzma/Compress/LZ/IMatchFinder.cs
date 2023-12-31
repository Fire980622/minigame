/*  
    This file is part of SevenZipSharpMobile.

    SevenZipSharpMobile is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SevenZipSharpMobile is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SevenZipSharpMobile.  If not, see <http://www.gnu.org/licenses/>.
*/

using System;
using System.IO;

    public interface IInWindowStream
    {
        void SetStream(Stream inStream);
        void Init();
        void ReleaseStream();
        Byte GetIndexByte(Int32 index);
        UInt32 GetMatchLen(Int32 index, UInt32 distance, UInt32 limit);
        UInt32 GetNumAvailableBytes();
    }

    public interface IMatchFinder : IInWindowStream
    {
        void Create(UInt32 historySize, UInt32 keepAddBufferBefore,
                    UInt32 matchMaxLen, UInt32 keepAddBufferAfter);

        UInt32 GetMatches(UInt32[] distances);
        void Skip(UInt32 num);
    }
