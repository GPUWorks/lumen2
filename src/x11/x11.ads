
-- Chip Richards, NiEstu, Phoenix AZ, Spring 2010

-- Lumen would not be possible without the support and contributions of a cast
-- of thousands, including and primarily Rod Kay.

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

with System;

package X11 is

   -- Xlib stuff needed by more than one of the routines below
   type Data_Format_Type is (Invalid, Bits_8, Bits_16, Bits_32);
   for  Data_Format_Type use
      (Invalid  => 0,
       Bits_8   => 8,
       Bits_16  => 16,
       Bits_32  => 32);

   type Atom            is new Long_Integer;

   -- Values used to compute record rep clause values that are portable
   -- between 32- and 64-bit systems
   Is_32      : constant := Boolean'Pos (System.Word_Size = 32);
   Is_64      : constant := 1 - Is_32;
   Word_Bytes : constant := Integer'Size / System.Storage_Unit;
   Word_Bits  : constant := Integer'Size - 1;
   Long_Bytes : constant := Long_Integer'Size / System.Storage_Unit;
   Long_Bits  : constant := Long_Integer'Size - 1;

   -- Xlib types needed only by Create
   subtype Dimension is Short_Integer;
   subtype Pixel     is Long_Integer;
   subtype Position  is Short_Integer;

   -- Used to simulate "out" param for C function
   type Int_Ptr is access all Integer;
   -- Actually an array, but only ever one element
   type FB_Config_Ptr is access all System.Address;

   -- OpenGL context ("visual") attribute specifiers
   type X11Context_Attribute_Name is
      (
       Attr_None,
       Attr_Use_GL,             -- unused
       Attr_Buffer_Size,        -- color index buffer size, ignored if TrueColor
       Attr_Level,              -- buffer level for over/underlays
       Attr_RGBA,               -- set by Depth => TrueColor
       Attr_Doublebuffer,       -- set by Animate => True
       Attr_Stereo,             -- wow, you have stereo visuals?
       Attr_Aux_Buffers,        -- number of auxiliary buffers
       Attr_Red_Size,           -- bit depth, red
       Attr_Green_Size,         -- bit depth, green
       Attr_Blue_Size,          -- bit depth, blue
       Attr_Alpha_Size,         -- bit depth, alpha
       Attr_Depth_Size,         -- depth buffer size
       Attr_Stencil_Size,       -- stencil buffer size
       Attr_Accum_Red_Size,     -- accumulation buffer bit depth, red
       Attr_Accum_Green_Size,   -- accumulation buffer bit depth, green
       Attr_Accum_Blue_Size,    -- accumulation buffer bit depth, blue
       Attr_Accum_Alpha_Size    -- accumulation buffer bit depth, alpha
      );

   type X11Context_Attribute (Name  : X11Context_Attribute_Name := Attr_None) is
   record
      case Name is
         when Attr_None | Attr_Use_GL | Attr_RGBA |
              Attr_Doublebuffer | Attr_Stereo =>
            null;  -- present or not, no value
         when Attr_Level =>
            Level : Integer := 0;
         when Attr_Buffer_Size | Attr_Aux_Buffers | Attr_Depth_Size |
              Attr_Stencil_Size | Attr_Red_Size | Attr_Green_Size |
              Attr_Blue_Size | Attr_Alpha_Size | Attr_Accum_Red_Size |
              Attr_Accum_Green_Size | Attr_Accum_Blue_Size |
              Attr_Accum_Alpha_Size =>
            Size : Natural := 0;
      end case;
   end record;

   type X11Context_Attributes is array (Positive range <>) of
      X11Context_Attribute;

   Max_GLX_Attributes : constant := 2 +
      (X11Context_Attribute_Name'Pos (X11Context_Attribute_Name'Last) + 1) * 2;

   type GLX_Attribute_List     is array (1 .. Max_GLX_Attributes) of Integer;
   type GLX_Attribute_List_Ptr is new System.Address;

   ------------------------------------------------------------------------

   type Display_Pointer is new System.Address;

   -- The maximum length of an event data record
   type Padding is array (1 .. 23) of Long_Integer;

   type Screen_Depth    is new Natural;
   type Screen_Number   is new Natural;
   type Visual_ID       is new Long_Integer;
   type Window_ID       is new Long_Integer;

   type Alloc_Mode               is (Alloc_None, Alloc_All);
   type Atom_Array               is array (Positive range <>) of Atom;
   type Colormap_ID              is new Long_Integer;
   type X_Window_Attributes_Mask is mod 2 ** Integer'Size;
   type Window_Class            is (Copy_From_Parent, Input_Output, Input_Only);
   type X_Event_Mask             is mod 2 ** Long_Integer'Size;

   -- An extremely abbreviated version of the XSetWindowAttributes
   -- structure, containing only the fields we care about.
   --
   -- NOTE: offset multiplier values differ between 32-bit and 64-bit
   -- systems since on 32-bit systems long size equals int size and the
   -- record has no padding.  The byte and bit widths come from Internal.
   Start_32 : constant := 10;
   Start_64 : constant :=  9;
   Start    : constant := (Is_32 * Start_32) + (Is_64 * Start_64);
   ------------------------------------------------------------------------

   Null_Display_Pointer : constant Display_Pointer :=
      Display_Pointer (System.Null_Address);

   type X_Set_Window_Attributes is record
      Event_Mask  : X_Event_Mask := 0;
      Colormap    : Colormap_ID  := 0;
   end record;

   for X_Set_Window_Attributes use record
      Event_Mask  at (Start + 0) * Long_Bytes range 0 .. Long_Bits;
      Colormap    at (Start + 3) * Long_Bytes range 0 .. Long_Bits;
   end record;

   -- The GL rendering context type
   type GLX_Context is new System.Address;

   type X_Visual_Info is record
      Visual        : System.Address;
      Visual_Ident  : Visual_ID;
      Screen        : Screen_Number;
      Depth         : Screen_Depth;
      Class         : Integer;
      Red_Mask      : Long_Integer;
      Green_Mask    : Long_Integer;
      Blue_Mask     : Long_Integer;
      Colormap_Size : Natural;
      Bits_Per_RGB  : Natural;
   end record;
   type X_Visual_Info_Pointer is access all X_Visual_Info;

   type X_Class_Hint is record
      Instance_Name : System.Address;
      Class_Name    : System.Address;
   end record;

   type X_Text_Property is record
      Value    : System.Address;
      Encoding : Atom;
      Format   : Data_Format_Type;
      NItems   : Long_Integer;
   end record;

   ---------------------------------------------------------------------------

   -- X modifier mask and its values
   type Modifier_Mask is mod 2 ** Integer'Size;

   -- Xlib constants needed only by Create
   Configure_Event_Mask : constant X_Window_Attributes_Mask :=
      2#00_1000_0000_0000#;  -- 11th bit
   Configure_Colormap   : constant X_Window_Attributes_Mask :=
      2#10_0000_0000_0000#;  -- 13th bit

   -- Atom names
   WM_Del          : String := "WM_DELETE_WINDOW" & ASCII.NUL;

   Null_Context : constant GLX_Context := GLX_Context (System.Null_Address);

   -- X event type codes
   -- we don't actually use this, just there to define bounds
   X_Error            : constant :=  0;
   X_Key_Press        : constant :=  2;
   X_Key_Release      : constant :=  3;
   X_Button_Press     : constant :=  4;
   X_Button_Release   : constant :=  5;
   X_Motion_Notify    : constant :=  6;
   X_Enter_Notify     : constant :=  7;
   X_Leave_Notify     : constant :=  8;
   X_Focus_In         : constant :=  9;
   X_Focus_Out        : constant := 10;
   X_Expose           : constant := 12;
   X_Unmap_Notify     : constant := 18;
   X_Map_Notify       : constant := 19;
   X_Configure_Notify : constant := 22;
   X_Client_Message   : constant := 33;
   -- we don't actually use this, just there to define bounds
   X_Generic_Event    : constant := 35;

   X_First_Event    : constant := X_Error;
   X_Last_Event     : constant := X_Generic_Event + 1;

   -- Our "delete window" atom value
   Delete_Window_Atom : Atom;

   ------------------------------------------------------------------------

   Shift_Mask    : constant Modifier_Mask := 2#0000_0000_0000_0001#;
   Lock_Mask     : constant Modifier_Mask := 2#0000_0000_0000_0010#;
   Control_Mask  : constant Modifier_Mask := 2#0000_0000_0000_0100#;
   Mod_1_Mask    : constant Modifier_Mask := 2#0000_0000_0000_1000#;
   Mod_2_Mask    : constant Modifier_Mask := 2#0000_0000_0001_0000#;
   Mod_3_Mask    : constant Modifier_Mask := 2#0000_0000_0010_0000#;
   Mod_4_Mask    : constant Modifier_Mask := 2#0000_0000_0100_0000#;
   Mod_5_Mask    : constant Modifier_Mask := 2#0000_0000_1000_0000#;
   Button_1_Mask : constant Modifier_Mask := 2#0000_0001_0000_0000#;
   Button_2_Mask : constant Modifier_Mask := 2#0000_0010_0000_0000#;
   Button_3_Mask : constant Modifier_Mask := 2#0000_0100_0000_0000#;
   Button_4_Mask : constant Modifier_Mask := 2#0000_1000_0000_0000#;
   Button_5_Mask : constant Modifier_Mask := 2#0001_0000_0000_0000#;

   type X_Event_Code is new Integer range X_First_Event .. X_Last_Event;

   Bytes     : constant := Word_Bytes;
   Bits      : constant := Word_Bits;
   Atom_Bits : constant := Atom'Size - 1;
   Base_1_32 : constant :=  8;
   Base_2_32 : constant :=  5;
   Base_3_32 : constant :=  6;
   Base_4_32 : constant :=  7;
   Base_1_64 : constant := 16;
   Base_2_64 : constant := 10;
   Base_3_64 : constant := 12;
   Base_4_64 : constant := 14;
   Base_1    : constant := (Base_1_32 * Is_32) + (Base_1_64 * Is_64);
   Base_2    : constant := (Base_2_32 * Is_32) + (Base_2_64 * Is_64);
   Base_3    : constant := (Base_3_32 * Is_32) + (Base_3_64 * Is_64);
   Base_4    : constant := (Base_4_32 * Is_32) + (Base_4_64 * Is_64);

   type X_Event_Data (X_Event_Type : X_Event_Code := X_Error) is record
      case X_Event_Type is
         when X_Key_Press | X_Key_Release =>
            Key_X      : Natural;
            Key_Y      : Natural;
            Key_Root_X : Natural;
            Key_Root_Y : Natural;
            Key_State  : Modifier_Mask;
            Key_Code   : Natural;
         when X_Button_Press | X_Button_Release =>
            Btn_X      : Natural;
            Btn_Y      : Natural;
            Btn_Root_X : Natural;
            Btn_Root_Y : Natural;
            Btn_State  : Modifier_Mask;
            Btn_Code   : Natural;
         when X_Motion_Notify =>
            Mov_X      : Natural;
            Mov_Y      : Natural;
            Mov_Root_X : Natural;
            Mov_Root_Y : Natural;
            Mov_State  : Modifier_Mask;
         when X_Enter_Notify | X_Leave_Notify =>
            Xng_X      : Natural;
            Xng_Y      : Natural;
            Xng_Root_X : Natural;
            Xng_Root_Y : Natural;
         when X_Expose =>
            Xps_X      : Natural;
            Xps_Y      : Natural;
            Xps_Width  : Natural;
            Xps_Height : Natural;
            Xps_Count  : Natural;
         when X_Configure_Notify =>
            Cfg_X      : Natural;
            Cfg_Y      : Natural;
            Cfg_Width  : Natural;
            Cfg_Height : Natural;
         when X_Client_Message =>
            Msg_Value  : Atom;
         when others =>
            Pad        : Padding;
      end case;
   end record;

   for X_Event_Data use record
      X_Event_Type at  0 * Bytes range 0 .. Bits;

      Key_X        at (Base_1 + 0) * Bytes range 0 .. Bits;
      Key_Y        at (Base_1 + 1) * Bytes range 0 .. Bits;
      Key_Root_X   at (Base_1 + 2) * Bytes range 0 .. Bits;
      Key_Root_Y   at (Base_1 + 3) * Bytes range 0 .. Bits;
      Key_State    at (Base_1 + 4) * Bytes range 0 .. Bits;
      Key_Code     at (Base_1 + 5) * Bytes range 0 .. Bits;

      Btn_X        at (Base_1 + 0) * Bytes range 0 .. Bits;
      Btn_Y        at (Base_1 + 1) * Bytes range 0 .. Bits;
      Btn_Root_X   at (Base_1 + 2) * Bytes range 0 .. Bits;
      Btn_Root_Y   at (Base_1 + 3) * Bytes range 0 .. Bits;
      Btn_State    at (Base_1 + 4) * Bytes range 0 .. Bits;
      Btn_Code     at (Base_1 + 5) * Bytes range 0 .. Bits;

      Mov_X        at (Base_1 + 0) * Bytes range 0 .. Bits;
      Mov_Y        at (Base_1 + 1) * Bytes range 0 .. Bits;
      Mov_Root_X   at (Base_1 + 2) * Bytes range 0 .. Bits;
      Mov_Root_Y   at (Base_1 + 3) * Bytes range 0 .. Bits;
      Mov_State    at (Base_1 + 4) * Bytes range 0 .. Bits;

      Xng_X        at (Base_1 + 0) * Bytes range 0 .. Bits;
      Xng_Y        at (Base_1 + 1) * Bytes range 0 .. Bits;
      Xng_Root_X   at (Base_1 + 2) * Bytes range 0 .. Bits;
      Xng_Root_Y   at (Base_1 + 3) * Bytes range 0 .. Bits;

      Xps_X        at (Base_2 + 0) * Bytes range 0 .. Bits;
      Xps_Y        at (Base_2 + 1) * Bytes range 0 .. Bits;
      Xps_Width    at (Base_2 + 2) * Bytes range 0 .. Bits;
      Xps_Height   at (Base_2 + 3) * Bytes range 0 .. Bits;
      Xps_Count    at (Base_2 + 4) * Bytes range 0 .. Bits;

      Cfg_X        at (Base_3 + 0) * Bytes range 0 .. Bits;
      Cfg_Y        at (Base_3 + 1) * Bytes range 0 .. Bits;
      Cfg_Width    at (Base_3 + 2) * Bytes range 0 .. Bits;
      Cfg_Height   at (Base_3 + 3) * Bytes range 0 .. Bits;

      Msg_Value    at (Base_4 + 0) * Bytes range 0 .. Atom_Bits;
   end record;

   ------------------------------------------------------------------------

   GL_TRUE : constant Character := Character'Val (1);

                     -----------------------------
                     -- Imported Xlib functions --
                     -----------------------------

   function GLX_Create_Context (Display    : in Display_Pointer;
                                Visual     : in X_Visual_Info_Pointer;
                                Share_List : in GLX_Context;
                                Direct     : in Character)
     return GLX_Context
     with Import => True, Convention => StdCall,
          External_Name => "glXCreateContext";

   function GLX_Make_Current (Display  : in Display_Pointer;
                              Drawable : in Window_ID;
                              Context  : in GLX_Context)
     return Character
     with Import => True, Convention => StdCall,
          External_Name => "glXMakeCurrent";

   function GLX_Make_Context_Current (Display  : in Display_Pointer;
                                      Draw     : in Window_ID;
                                      Read     : in Window_ID;
                                      Context  : in GLX_Context)
     return Character
     with Import => True, Convention => StdCall,
          External_Name => "glXMakeContextCurrent";

   function X_Intern_Atom (Display        : in Display_Pointer;
                           Name           : in System.Address;
                           Only_If_Exists : in Natural)
     return Atom
     with Import => True, Convention => StdCall, External_Name => "XInternAtom";

   procedure X_Set_Class_Hint (Display : in Display_Pointer;
                               Window  : in Window_ID;
                               Hint    : in X_Class_Hint)
     with Import => True, Convention => StdCall,
          External_Name => "XSetClassHint";

   procedure X_Set_Icon_Name (Display : in Display_Pointer;
                              Window  : in Window_ID;
                              Name    : in System.Address)
     with Import => True, Convention => StdCall,
          External_Name => "XSetIconName";

   procedure X_Set_WM_Icon_Name (Display   : in Display_Pointer;
                                 Window    : in Window_ID;
                                 Text_Prop : in System.Address)
     with Import => True, Convention => StdCall,
          External_Name => "XSetWMIconName";

   procedure X_Set_WM_Name (Display   : in Display_Pointer;
                            Window    : in Window_ID;
                            Text_Prop : in System.Address)
     with Import => True, Convention => StdCall,
          External_Name => "XSetWMName";

   function GLX_Choose_Visual (Display        : in Display_Pointer;
                               Screen         : in Screen_Number;
                               Attribute_List : in GLX_Attribute_List_Ptr)
     return X_Visual_Info_Pointer
     with Import => True, Convention => StdCall,
          External_Name => "glXChooseVisual";

   function GLX_Choose_FB_Config (Display        : in Display_Pointer;
                                  Screen         : in Screen_Number;
                                  Attribute_List : in GLX_Attribute_List_Ptr;
                                  Num_Found      : in Int_Ptr)
     return FB_Config_Ptr
     with Import => True, Convention => StdCall,
          External_Name => "glXChooseFBConfig";

   function GLX_Get_Visual_From_FB_Config (Display : in Display_Pointer;
                                           Config  : in System.Address)
     return X_Visual_Info_Pointer
     with Import => True, Convention => StdCall,
          External_Name => "glXGetVisualFromFBConfig";

   procedure X_Next_Event (Display : in Display_Pointer;
                           Event   : in System.Address)
     with Import => True, Convention => StdCall, External_Name => "XNextEvent";

   procedure GLX_Destroy_Context (Display : in Display_Pointer;
                                  Context : in GLX_Context)
     with Import => True, Convention => StdCall,
          External_Name => "glXDestroyContext";

   function X_Create_Colormap (Display : in Display_Pointer;
                               Window  : in Window_ID;
                               Visual  : in System.Address;
                               Alloc   : in Alloc_Mode)
     return Colormap_ID
     with Import => True, Convention => StdCall,
          External_Name => "XCreateColormap";

   function X_Create_Window (Display      : in Display_Pointer;
                             Parent       : in Window_ID;
                             X            : in Position;
                             Y            : in Position;
                             Width        : in Dimension;
                             Height       : in Dimension;
                             Border_Width : in Natural;
                             Depth        : in Screen_Depth;
                             Class        : in Window_Class;
                             Visual       : in System.Address;
                             Valuemask    : in X_Window_Attributes_Mask;
                             Attributes   : in System.Address)
     return Window_ID
     with Import => True, Convention => StdCall,
          External_Name => "XCreateWindow";

   function X_Default_Screen (Display : in Display_Pointer)
     return Screen_Number
     with Import => True, Convention => StdCall,
          External_Name => "XDefaultScreen";

   procedure X_Map_Window (Display  : in Display_Pointer;
                           Window   : in Window_ID)
     with Import => True, Convention => StdCall,
          External_Name => "XMapWindow";

   function X_Open_Display
      (Display_Name : in System.Address := System.Null_Address)
     return Display_Pointer
     with Import => True, Convention => StdCall,
          External_Name => "XOpenDisplay";

   function X_Root_Window (Display    : in Display_Pointer;
                           Screen_Num : in Screen_Number)
     return Window_ID
     with Import => True, Convention => StdCall, External_Name => "XRootWindow";

   procedure X_Set_WM_Protocols (Display   : in Display_Pointer;
                                 Window    : in Window_ID;
                                 Protocols : in System.Address;
                                 Count     : in Integer)
     with Import => True, Convention => StdCall,
          External_Name => "XSetWMProtocols";

   function X_Lookup_String (Event   : in System.Address;
                             Buffer  : in System.Address;
                             Limit   : in Natural;
                             Keysym  : in System.Address;
                             Compose : in System.Address)
     return Natural
     with Import => True, Convention => StdCall,
          External_Name => "XLookupString";

   function X_Pending (Display : in Display_Pointer)
     return Natural
     with Import => True, Convention => StdCall, External_Name => "XPending";

   procedure X_Resize_Window (Display : in Display_Pointer;
                              Window  : in Window_ID;
                              Width   : in Positive;
                              Height  : in Positive)
     with Import => True, Convention => StdCall,
          External_Name => "XResizeWindow";

   procedure X_Warp_Pointer (Display       : in Display_Pointer;
                             Source_W      : in Window_ID;
                             Dest_W        : in Window_ID;
                             Source_X      : in Integer;
                             Source_Y      : in Integer;
                             Source_Width  : in Natural;
                             Source_Height : in Natural;
                             Dest_X        : in Integer;
                             Dest_Y        : in Integer)
     with Import => True, Convention => StdCall,
          External_Name => "XWarpPointer";

   procedure X_Move_Window  (Display : in Display_Pointer;
                             Window  : in Window_ID;
                             X       : in Natural;
                             Y       : in Natural)
     with Import => True, Convention => StdCall,
          External_Name => "XMoveWindow";

   procedure X_Query_Pointer (Display : in Display_Pointer;
                              Window  : in Window_ID;
                              Root    : in System.Address;
                              Child   : in System.Address;
                              Root_X  : in System.Address;
                              Root_Y  : in System.Address;
                              Win_X   : in System.Address;
                              Win_Y   : in System.Address;
                              Mask    : in System.Address)
     with Import => True, Convention => StdCall,
          External_Name => "XQueryPointer";

   procedure X_Raise_Window (Display : in Display_Pointer;
                             Window  : in Window_ID)
     with Import => True, Convention => StdCall,
          External_Name => "XRaiseWindow";

   procedure X_Lower_Window (Display : in Display_Pointer;
                             Window  : in Window_ID)
     with Import => True, Convention => StdCall,
          External_Name => "XLowerWindow";

   ---------------------------------------------------------------------------

end X11;
