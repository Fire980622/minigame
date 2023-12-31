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

using System.IO;

    public class OutBuffer
    {
        private readonly byte[] m_Buffer;
        private readonly uint m_BufferSize;
        private uint m_Pos;
        private ulong m_ProcessedSize;
        private Stream m_Stream;

        /// <summary>
        /// Initializes a new instance of the OutBuffer class
        /// </summary>
        /// <param name="bufferSize"></param>
        public OutBuffer(uint bufferSize)
        {
            m_Buffer = new byte[bufferSize];
            m_BufferSize = bufferSize;
        }

        public void SetStream(Stream stream)
        {
            m_Stream = stream;
        }

        public void FlushStream()
        {
            m_Stream.Flush();
        }

        public void CloseStream()
        {
            m_Stream.Close();
        }

        public void ReleaseStream()
        {
            m_Stream = null;
        }

        public void Init()
        {
            m_ProcessedSize = 0;
            m_Pos = 0;
        }

        public void WriteByte(byte b)
        {
            m_Buffer[m_Pos++] = b;
            if (m_Pos >= m_BufferSize)
                FlushData();
        }

        public void FlushData()
        {
            if (m_Pos == 0)
                return;
            m_Stream.Write(m_Buffer, 0, (int) m_Pos);
            m_Pos = 0;
        }

        public ulong GetProcessedSize()
        {
            return m_ProcessedSize + m_Pos;
        }
    }
