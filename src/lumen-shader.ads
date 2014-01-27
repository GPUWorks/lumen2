
-- Lumen.Shader -- Helper routines to fetch shader source, load it, and compile it
--
-- Chip Richards, NiEstu, Phoenix AZ, Winter 2013

-- This code is covered by the ISC License:
--
-- Copyright © 2010, NiEstu
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- The software is provided "as is" and the author disclaims all warranties
-- with regard to this software including all implied warranties of
-- merchantability and fitness. In no event shall the author be liable for any
-- special, direct, indirect, or consequential damages or any damages
-- whatsoever resulting from loss of use, data or profits, whether in an
-- action of contract, negligence or other tortious action, arising out of or
-- in connection with the use or performance of this software.

with Lumen.GL;

package Lumen.Shader is

   Read_Error    : exception;

   -- Read shader source from a disk file
   procedure From_File (Shader_Type : in GL.Enum;
                        Name        : in String;
                        ID          : out GL.UInt;
                        Success     : out Boolean);

   -- Use shader source provided in a string
   procedure From_String (Shader_Type : in GL.Enum;
                          Source      : in String;
                          ID          : out GL.UInt;
                          Success     : out Boolean);

   -- Fetch info log for given shader
   function Get_Info_Log (Shader : GL.UInt) return String;

end Lumen.Shader;
