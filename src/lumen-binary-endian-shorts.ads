
-- Lumen.Binary.Endian.Shorts -- Byte re-ordering routines for "short"
--                               (16-bit) values
--
--
-- Chip Richards, NiEstu, Phoenix AZ, Summer 2010

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

generic
   type Short_Type is (<>);
package Lumen.Binary.Endian.Shorts is

   ---------------------------------------------------------------------------
   -- Swap the bytes, no matter the host ordering
   function Swap_Bytes  (Value : in Short_Type) return Short_Type
     with Inline => True;

   -- Swap bytes if host is little-endian, or no-op if it's big-endian
   function To_Big      (Value : in Short_Type) return Short_Type
     with Inline => True;

   -- Swap bytes if host is big-endian, or no-op if it's little-endian
   function To_Little   (Value : in Short_Type) return Short_Type
     with Inline => True;

   ---------------------------------------------------------------------------
   -- Swap the bytes in place, no matter the host ordering
   procedure Swap_Bytes  (Value : in out Short_Type)
     with Inline => True;

   -- Swap bytes in place if host is little-endian, or no-op if it's big-endian
   procedure To_Big      (Value : in out Short_Type)
     with Inline => True;

   -- Swap bytes in place if host is big-endian, or no-op if it's little-endian
   procedure To_Little   (Value : in out Short_Type)
     with Inline => True;

   ---------------------------------------------------------------------------

end Lumen.Binary.Endian.Shorts;
