
local globals = require("robodoc.globals")

local string = string
local table = table
local tonumber = tonumber
local pairs = pairs
local string = string
local next = next

local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2
end

-- TODO Documentation */
function GenerateFalseLink(dest_doc, name )
    --Todo Ducumentation
    local switch = {
        ['TEST'] = function()
            TESTGenerateFalseLink( dest_doc, name )
        end,
        ['XMLDB'] = function()
            XMLDBGenerateFalseLink( dest_doc, name )
        end,
        ['HTML'] = function()

            HTMLGenerateFalseLink( dest_doc, name )
        end,
        ['LaTeX'] = function()
            LaTeXGenerateFalseLink( dest_doc, name )
        end,
        ['RTF'] = function()
            RTFGenerateFalseLink( dest_doc, name )
        end,
        ['ASCII'] = function()
            ASCIIGenerateFalseLink( dest_doc, name )
        end,
        ['TROFF'] = function()
            TROFFGenerateFalseLink( dest_doc, name )
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

--[[***f* Generator/RB_Generate_Item_Begin
 * FUNCTION
 *   Generate the begin of an item.  This should switch to some
 *   preformatted output mode, similar to HTML's <PRE>.
 * SYNOPSIS
 ]]
 function RB_Generate_Item_Begin(dest_doc, name )
--[[
 * INPUTS
 *   dest_doc -- file to be written to
 *   output_mode -- global with the current output mode
 * SOURCE
 ]]

    local switch = {
        ['TEST'] = function()
            TESTGenerateItemBegin( dest_doc )
        end,
        ['XMLDB'] = function()
            XMLDBGenerateItemBegin( dest_doc )
        end,
        ['HTML'] = function()

            HTMLGenerateItemBegin( dest_doc, name )
        end,
        ['LaTeX'] = function()
            LaTeXGenerateItemBegin( dest_doc )
        end,
        ['RTF'] = function()
            RTFGenerateItemBegin( dest_doc )
        end,
        ['ASCII'] = function()
            RTFGenerateItemBegin( dest_doc )
        end,
        ['TROFF'] = function()
            ASCIIGenerateItemBegin( dest_doc )
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

--[[***f* Generator/Generate_Label
 * FUNCTION
 *   Generate a label that can be used for a link.
 *   For instance in HTML this is <a name="label">
 * SYNOPSIS
 ]]
function Generate_Label(dest_doc, name )
--[[
 * INPUTS
 *   * dest_doc -- file to be written to
 *   * name -- the label's name.
 *   * output_mode -- global with the current output mode
 * SOURCE
 ]]
    local switch = {
        ['TEST'] = function()
            TESTGenerateLabel( dest_doc, name )
        end,
        ['XMLDB'] = function()
            XMLDBGenerateLabel( dest_doc, name )
        end,
        ['HTML'] = function()

            HTMLGenerateLabel( dest_doc, name )
        end,
        ['LaTeX'] = function()
            LaTeXGenerateLabel( dest_doc, name )
        end,
        ['RTF'] = function()
            RTFGenerateLabel( dest_doc, name )
        end,
        ['ASCII'] = function()
            -- Doesn't apply */
        end,
        ['TROFF'] = function()
            -- Doesn't apply */
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

--[[***f* Generator/RB_Generate_Item_End
 * FUNCTION
 *   Generate the end of an item.  This should switch back from the
 *   preformatted mode.  So in HTML it generates the </PRE> of a <PRE>
 *   </PRE> pair.
 * INPUTS
 *   * dest_doc -- file to be written to
 *   * output_mode -- global with the current output mode
 * SOURCE
]]

function GenerateItemEnd(dest_doc, name )
    local switch = {
        ['TEST'] = function()
            TESTGenerateItemEnd( dest_doc )
        end,
        ['XMLDB'] = function()
            XMLDBGenerateItemEnd( dest_doc );
        end,
        ['HTML'] = function()

            HTMLGenerateItemEnd( dest_doc, name );
        end,
        ['LaTeX'] = function()
                if ( piping == false ) then
                    fprintf( dest_doc, "\\begin{verbatim}\n" );  ----------------------------------take care
                    piping = true;
                end
        RB_LaTeX_Generate_Item_End( dest_doc );
        end,
        ['RTF'] = function()
            RTF_Generate_Item_End( dest_doc );
        end,
        ['ASCII'] = function()
            RB_ASCII_Generate_Item_End( dest_doc );
        end,
        ['TROFF'] = function()
             -- Doesn't apply
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

--[[***f Generator/RB_Get_Len_Extension
 * FUNCTION
 *   Compute the length of the filename extension for
 *   the current document type.
 *****
]]

--[[*x**f Generator/RB_Default_Len_Extension
 * FUNCTION
 *   Returns default extension for
 *   the current document type.
 *****
]]

function RB_Get_Default_Extension(doctype )
    local extension = nil
    local switch = {
        ['TEST'] = function()
            extension = RB_TEST_Get_Default_Extension(  )
        end,
        ['XMLDB'] = function()
            extension = RB_XMLDB_Get_Default_Extension(  )
        end,
        ['HTML'] = function()

            extension = RB_HTML_Get_Default_Extension(  )
        end,
        ['LaTeX'] = function()
            extension = RB_RTF_Get_Default_Extension(  )
        end,
        ['RTF'] = function()
            extension = RB_RTF_Get_Default_Extension(  )
        end,
        ['ASCII'] = function()
            extension = RB_ASCII_Get_Default_Extension(  )
        end,
        ['TROFF'] = function()
            extension = RB_TROFF_Get_Default_Extension(  )
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
    return extension
end
--*******--

--[[***f* Generator/RB_Generate_BeginSection
 * FUNCTION
 *   Generate a section of level depth in the current output mode.
 *   This is used for the --sections option.  Where each header is
 *   placed in a section based on the header hierarchy.
 * INPUTS
 *   * dest_doc    -- the destination file.
 *   * doctype     -- document type
 *   * depth       -- the level of the section
 *   * name        -- the name of the section
 *   * header      -- pointer to the header structure
 *   * output_mode -- global with the current output mode.
 *   * srcRoot	   -- Source root path ADDED by MILIND GUPTA 5/9/2010
 * SOURCE
]]

function GenerateBeginSection(dest_doc, depth, name, header, srcRoot)
    local switch = {
        ['TEST'] = function()
            TESTGenerateBeginSection( dest_doc, depth, name )
        end,
        ['XMLDB'] = function()
            XMLDBGenerateBeginSection( dest_doc, depth, name, header, srcRoot )
        end,
        ['HTML'] = function()

            HTMLGenerateBeginSection( dest_doc, depth, name, header )
        end,
        ['LaTeX'] = function()
            LaTeXGenerateBeginSection( dest_doc, depth, name, header )
        end,
        ['RTF'] = function()
            RTFGenerateBeginSection( dest_doc, depth, name )
        end,
        ['ASCII'] = function()
            ASCIIGenerateBeginSection( dest_doc, depth, name, header )
        end,
        ['TROFF'] = function()
           -- RB_TROFF_Generate_BeginSection( dest_doc, depth, name )
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

--[[***f* Generator/RB_Generate_EndSection
 * FUNCTION
 *   Generate the end of a section base on the current output mode.
 *   The functions is used for the --section option.
 *   It closes a section in the current output mode.
 * INPUTS
 *   * dest_doc -- the destination file.
 *   * doctype  --
 *   * depth    -- the level of the section
 *   * name     -- the name of the section
 *   * output_mode -- global with the current output mode.
 * SOURCE
]]

function GenerateEndSection(dest_doc, depth, name )
    local switch = {
        ['TEST'] = function()
            TESTGenerateEndSection( dest_doc, depth, name )
        end,
        ['XMLDB'] = function()
            XMLDBGenerateEndSection( dest_doc, depth, name )
        end,
        ['HTML'] = function()

            HTMLGenerateEndSection( dest_doc, depth, name )
        end,
        ['LaTeX'] = function()
            LaTeXGenerateEndSection( dest_doc, depth, name )
        end,
        ['RTF'] = function()
            RTFGenerateEndSection( dest_doc, depth, name )
        end,
        ['ASCII'] = function()
            HTMLGenerateEndSection( dest_doc, depth, name )   -----------HTT---------
        end,
        ['TROFF'] = function()
            -- doesn't apply */
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end


--[[***f* Generator/RB_Generate_Index_Entry
 * FUNCTION
 *   Generate an entry for an auto generated index.  This works only
 *   for output modes that support this, LaTeX for instance.   This
 *   has nothting to do with the master index.
 * SYNOPSIS
 ]]
function GenerateIndexEntry(dest_doc, doctype, header )
--[[
 * INPUTS
 *   * dest_doc -- the destination file.
 *   * header   -- pointer to the header the index entry is for.
 *   * output_mode -- global with the current output mode.
 * SOURCE
]]
        --NotForHTML
end

--[[***f* Generator/RB_Generate_TOC_2
 * FUNCTION
 *   Create a Table of Contents based on the headers found in
 *   _all_ source files.   There is also a function to create
 *   a table of contents based on the headers found in a single
 *   source file RB_Generate_TOC_1
 * SYNOPSIS
]]
function GenerateTOC2(dest_doc, headers, count, owner, dest_name )
--[[
 * INPUTS
 *   * dest_doc -- the destination file.
 *   * headers  -- an array of pointers to all the headers.
 *   * count    -- the number of pointers in the array.
 *   * output_mode -- global with the current output mode.
 *   * owner    -- The owner of the TOC. Only the headers that are owned
 *               by this owner are included in the TOC.  Can be NULL,
 *               in which case all headers are included.
 * SOURCE
]]
    local switch = {
        ['TEST'] = function()
        end,
        ['XMLDB'] = function()
        end,
        ['HTML'] = function()
            HTMLGenerateTOC2( dest_doc, headers, count, owner, dest_name )
        end,
        ['LaTeX'] = function()
        end,
        ['RTF'] = function()
            RTFGenerateTOC2( dest_doc, headers, count )
        end,
        ['ASCII'] = function()
        end,
        ['TROFF'] = function()
            -- //
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end


--[[***f* Generator/RB_Generate_Doc_Start
 * NAME
 *   RB_Generate_Doc_Start -- Generate document header.
 * SYNOPSIS
 ]]
function  GenerateDocStart(document, DestDoc, SrcName, title, toc, dest_name, charset )
--[[
 * FUNCTION
 *   Generates for depending on the output_mode the text that
 *   will be at the start of a document.
 *   Including the table of contents.
 * INPUTS
 *   o DestDoc - pointer to the file to which the output will
 *                be written.
 *   o SrcName - the name of the source file or directory.
 *   o name     - the name of this file.
 *   o output_mode - global variable that indicates the output
 *                   mode.
 *   o toc      - generate table of contens
 * SEE ALSO
 *   RB_Generate_Doc_End
 * SOURCE
 ]]
    local switch = {
        ['TEST'] = function()
            TESTGenerateDocStart(DestDoc, SrcName, title, toc)
        end,
        ['XMLDB'] = function()
            XMLDBGenerateDocStart( document, DestDoc, charset )
        end,
        ['HTML'] = function()

            html.GenerateDocStart( DestDoc, SrcName, title, dest_name,charset )
        end,
        ['LaTeX'] = function()
            LaTeXGenerateDocStart( DestDoc, SrcName, title, charset )
        end,
        ['RTF'] = function()
            RTFGenerateDocStart( DestDoc, SrcName, title, toc )
        end,
        ['ASCII'] = function()
            ASCIIGenerateDocStart( DestDoc, SrcName, title, toc )
        end,
        ['TROFF'] = function()
            -- //
        end
    }

    local f = switch[string.upper(globals.docformats.name)]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end


--[[***f* Generator/RB_Generate_Doc_End
 * NAME
 *   RB_Generate_Doc_End -- generate document trailer.
 * SYNOPSIS
 ]]
function GenerateDocEnd(DestDoc, name, SrcName )
--[[
 * FUNCTION
 *   Generates for depending on the output_mode the text that
 *   will be at the end of a document.
 * INPUTS
 *   o DestDoc - pointer to the file to which the output will
 *                be written.
 *   o name     - the name of this file.
 *   o output_mode - global variable that indicates the output
 *                   mode.
 * NOTES
 *   Doesn't do anything with its arguments, but that might
 *   change in the future.
 * BUGS
 * SOURCE
 ]]
    local switch = {
        ['TEST'] = function()
            TESTGenerateDocEnd(DestDoc, name);
        end,
        ['XMLDB'] = function()
            XMLDBGenerateDocEnd( document, name );
        end,
        ['HTML'] = function()

            html.GenerateDocEnd( DestDoc, name, SrcName );
        end,
        ['LaTeX'] = function()
            LaTeXGenerateDocEnd( DestDoc, name );
        end,
        ['RTF'] = function()
            -- RTFGenerateDocEnd( DestDoc,);
        end,
        ['ASCII'] = function()
           -- ASCIIGenerateDocEnd( DestDoc, );
        end,
        ['TROFF'] = function()
            -- //
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end


--[[***f* Generator/RB_Generate_Header_Start [3.0h]
 * NAME
 *   RB_Generate_Header_Start -- generate header start text.
 * SYNOPSIS
 ]]
function GenerateHeaderStart(dest_doc, cur_header,srcRoot)
--[[
 * FUNCTION
 *   Generates depending on the output_mode the text that
 *   will be at the end of each header.
 * INPUTS
 *   o dest_doc - pointer to the file to which the output will
 *                be written.
 *   o cur_header - pointer to a RB_header structure.
 *   o srcRoot - containing the Source files root path ADDED by MILIND GUPTA 5/9/2010 AmVed
 * SEE ALSO
 *   RB_Generate_Header_End
 * SOURCE
 ]]
    local switch = {
        ['TEST'] = function()
            TESTGenerateHeaderStart(DestDoc, cur_header);
        end,
        ['XMLDB'] = function()
            XMLDBGenerateHeaderStart( document, cur_header, srcRoot );
        end,
        ['HTML'] = function()

            html.GenerateHeaderStart( DestDoc, cur_header );
        end,
        ['LaTeX'] = function()
            LaTeXGenerateHeaderStart( DestDoc, cur_header );
        end,
        ['RTF'] = function()
            RTFGenerateHeaderStart( dest_doc, cur_header );
        end,
        ['ASCII'] = function()
            ASCIIGenerateHeaderStart( dest_doc, cur_header );
        end,
        ['TROFF'] = function()
            -- //
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end

    return dest_doc;
end

--[[***f* Generator/RB_Generate_Header_End [3.0h]
 * NAME
 *   RB_Generate_Header_End
 * SYNOPSIS
]]
function GenerateHeaderEnd(dest_doc, cur_header )
--[[
 * FUNCTION
 *   Generates for depending on the output_mode the text that
 *   will be at the end of a header.
 *   This function is used if the option --section is _not_
 *   used.
 * INPUTS
 *   o dest_doc - pointer to the file to which the output will
 *              be written.
 *   o cur_header - pointer to a RB_header structure.
 * SEE ALSO
 *   RB_Generate_Header_Start, RB_Generate_EndSection,
 *   RB_Generate_BeginSection
 * SOURCE
]]
    local switch = {
        ['TEST'] = function()
            TESTGenerateHeaderEnd( dest_doc, cur_header )
        end,
        ['XMLDB'] = function()
            XMLDBGenerateHeaderEnd( dest_doc, cur_header )
        end,
        ['HTML'] = function()

            html.GenerateHeaderEnd( dest_doc, cur_header )
        end,
        ['LaTeX'] = function()
            LaTeXGenerateHeaderEnd( dest_doc, cur_header )
        end,
        ['RTF'] = function()
            RTFGenerateHeaderEnd( dest_doc, cur_header )
        end,
        ['ASCII'] = function()
            ASCIIGenerateHeaderEnd( dest_doc, cur_header )
        end,
        ['TROFF'] = function()
            TROFFGenerateHeaderEnd( dest_doc, cur_header )
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

--[[***f* Generator/Generate_Item_Name [2.01]
 * NAME
 *   Generate_Item_Name -- fast&easy
 * SYNOPSIS
]]
function GenerateItemName(dest_doc, item_type )
--[[
 * FUNCTION
 *   write the item's name to the doc
 * INPUTS
 *   o FILE* dest_doc      -- destination file
 *   o int item_type       -- the type of item
 * AUTHOR
 *   Koessi
 * NOTES
 *   uses globals: output_mode
 * SOURCE
]]
    local name = configuration.items.name[item_type]
    local switch = {
        ['TEST'] = function()
            TESTGenerateItemName( dest_doc, name )
        end,
        ['XMLDB'] = function()
            XMLDBGenerateItemName( dest_doc, name )
        end,
        ['HTML'] = function()

            HTMLGenerateItemName( dest_doc, name )
        end,
        ['LaTeX'] = function()
            LaTeXGenerateItemName( dest_doc, name )
        end,
        ['RTF'] = function()
            RTFGenerateItemName( dest_doc, name )
        end,
        ['ASCII'] = function()
            ASCIIGenerateItemName( dest_doc, name )
        end,
        ['TROFF'] = function()
            TROFFGenerateItemName( dest_doc, name, item_type )
        end
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

function GenerateBeginContent(dest_doc )
    local switch = {
        ['HTML'] = function()
            HTMLGenerateBeginContent( dest_doc )
        end,
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

function GenerateEndContent(dest_doc )
    local switch = {
        ['HTML'] = function()
            html.GenerateEndContent( dest_doc )
        end,
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

function GenerateBeginNavigation(dest_doc )
    local switch = {
        ['HTML'] = function()
            html.GenerateBeginNavigation( dest_doc )
        end,
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

function GenerateEndNavigation(dest_doc )
    local switch = {
        ['HTML'] = function()
            html.GenerateEndNavigation( dest_doc )
        end,
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

function GenerateIndexMenu(dest_doc, filename, document )
    local switch = {
        ['HTML'] = function()
            html.GenerateIndexMenu( dest_doc, filename, document, nil )
        end,
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end


function GenerateBeginExtra(dest_doc )
    local switch = {
        ['HTML'] = function()
            html.GenerateBeginExtra( dest_doc )
        end,
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

function Generate_End_Extra(dest_doc )
    local switch = {
        ['HTML'] = function()
            HTMLGenerateEndExtra( dest_doc )
        end,
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

function GenerateIndex(document )
--[[
 * FUNCTION
 *   Create a master index file. It contains pointers to the
 *   documentation generated for each source file, as well as all
 *   "objects" found in the source files.
 * SOURCE
]]
    local switch = {
        ['HTML'] = function()
            HTMLGenerateEndExtra( dest_doc )
        end,
        ['LATEX'] = function()
            --Latex has a index by default
        end,

    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

--[[***f* Generator/Generate_Header
 * FUNCTION
 *   Generate the documentation for all the items found in
 *   a header except for any items specified in
 *   configuration.ignore_items.
 * SYNOPSIS
 ]]
function GenerateHeader(f, header, docname)
--[[
 * INPUTS
 *   * f -- destination file
 *   * header -- header to be searched.
 *   * srcname -- name of the source file the header was found in.
 *   * docname -- name of the documentation file.
 * BUGS
 *   This skips the first item body if the first item name was
 *   not correctly spelled.
 * SOURCE
]]
    for cur_item = 1, #header.items do
        if (false) then  -- condition = Is_Ignore_Item( name )
            --User does not want this item
        elseif (false) then --condition = Works_Like_SourceItem( item_type )
            --User does not want source items
        else
            GenerateItem(f, header, cur_item, docname)
        end
    end
end


--[[***f* Generator/Generate_Item
 * SYNOPSIS
 ]]
function GenerateItem(f, header, cur_item, docname)

--[[ FUNCTION
    *   Generate the documentation for a single item.
    *
    * NOTE
    *   This function is way too long...
    *
    * SOURCE
    ]]
    local dot_nr = 1
    local tool = nil
    item_type = cur_item.type
    GenerateItemName(f, item_type)
    GenerateItemBegin(f, name)
    for line_nr = 1, #cur_item.no_lines do
        local item_line = cur_item.lines[line_nr]
        local line = item_line.line
        --Plain item lines
        if((WorksLikeSourceItem(item_type)==false) and item_line.kind == "ITEM_LINE_PLAIN") then
            FormatLine(f, item_line.format)
            GenerateItemLine(f, line, item_type, docname, header)
        --Last line 
        elseif (item_line.kind == "ITEM_LINE_END") then
            FormatLine(f, item_line.format)
        --Normal Pipes
        elseif ((WorksLikeSourceItem(item_type)==false) and item_line.kind == "ITEM_LINE_PIPE") then
            FormatLine(f, item_line.format)
            -------TODO output mode -------
            if( item_line.pipe_mode == output_mode) then
                Pipe_Line(f, line)
            end 
        -- Tool start
        elseif((WorksLikeSourceItem(item_type)==false) and item_line.kind == "ITEM_LINE_TOOL_START") then
            FormatLine(f, item_line.format)

            --Chnage to docdir
            ChangeToDocdir(docname)
            
            --Open pipe to tool 
            tool = OpenPipe(line)

            -- Get back to working dir 
            ChangeBackToCWD()
        
        -- Tool (or DOT) body
        elseif ((WorksLikeSourceItem(item_type)==false) and item_type.kind == "ITEM_LINE_TOOL_BODY") then
            FormatLine(f, item_line.format)

            -- Get DOT file type 
            if ( tool ~= nil ) then
                tool:write(line.."\n")
            end
        -- Tool end
        elseif ((WorksLikeSourceItem(item_type)==false) and item_type.kind == "ITEM_LINE_TOOL_END") then
            ClosePipe(tool)
            tool = nil
        
        -- DOT start 
        elseif ((WorksLikeSourceItem(item_type)==false) and item_type.kind == "ITEM_LINE_DOT_START") then
            FormatLine(f, item_line.format)
            dot_type = GetDOTType()
            
            if(dot_type) then
                local pipe_str = ""
                ChangeToDocdir(docname)
                --TODO--
                tool = OpenPipe(pipe_str)
            end
        
        -- DOT end 
        elseif ((WorksLikeSourceItem(item_type)==false) and item_type.kind == "ITEM_LINE_DOT_END") then
            if(tool ~= nill) then
                --Close pipe
                ClosePipe(tool)
                tool = nil

                --Generate link to image
                GenerateDOTImageLink(f,dot_nr, dot_type)

                --Get back to working dir
                ChangeBackToCWD()

                --Increment dot file number 
                dot_nr = dot_nr + 1
            end
        
        -- DOT file include 
        elseif ((WorksLikeSourceItem(item_type)==false) and item_type.kind == "ITEM_LINE_DOT_FILE") then
            FormatLine(f, item_line.format)

            --Get DOT file type
            dot_type = GetDOTType()

            if(dot_type) then
                --TODO--
            end

        --Exec item
        elseif ((WorksLikeSourceItem(item_type)==false) and item_type.kind == "ITEM_LINE_EXEC") then
            FormatLine(f, item_line.format)
            
            --Change to docdir 
            ChangeTODocdir(document)
            
            --EXecute line 
            system(line)

            -- Get back to working dir  
            ChangeBackToCWD()
        
        -- Source linses
        elseif (WorksLikeSourceItem(item_type)==true) then
            FormatLine(f, item_line.format)

            --Generate line numbers for SOURCE like items
            GenerateItemLineNumber(f, item_line.line_number, cur_item.max_line_number)
            
            --Generate item line
            GenerateItemLine(f, line, item_type, docname, header)
        else
            -- This item line is ignored
        end

        
    end
    GenerateItemEnd(f, name)

end

function FormatLine(dest_doc, format)
    if ( format and RBILA_END_LIST_ITEM ) then
         Generate_End_List_Item( dest_doc )
    end
    if ( format and RBILA_END_LIST ) then
        Generate_End_List( dest_doc )
    end

    if ( format and RBILA_END_PRE ) then

        Generate_End_Preformatted( dest_doc )
    end
    if ( format and RBILA_BEGIN_PARAGRAPH ) then

        Generate_Begin_Paragraph( dest_doc )
    end
    if ( format and RBILA_END_PARAGRAPH ) then
        Generate_End_Paragraph( dest_doc )
    end
    if ( format and RBILA_BEGIN_PRE ) then

        Generate_Begin_Preformatted( dest_doc,( format & RBILA_BEGIN_SOURCE ) )
    end
    if ( format and RBILA_BEGIN_LIST ) then

        GenerateBeginList( dest_doc )
    end
    if ( format and RBILA_BEGIN_LIST_ITEM ) then

        GenerateBeginListItem( dest_doc );
    end

end

function GenerateBeginList(document )
    html.GenerateBeginList(dest_doc)
end

function GenerateEndList(dest_doc)
    html.GenerateEndList(dest_doc)
end

function GenerateBeginPreformatted(dest_doc)
    html.GenerateBeginPreformatted(dest_doc)
end

function GenerateEndPreformatted(dest_doc, source)
    html.GenerateEndPreformatted(dest_doc, source)
end

function GenerateEndParagraph(dest_doc)
    html.GenerateEndParagraph(dest_doc)
end

function GenerateBeginParagraph(dest_doc)
    html.GenerateBeginParagraph(dest_doc)
end



--[[***f* Generator/RB_Generate_Part
 * FUNCTION
 *   Generate the documention for all the headers found in a single
 *   source file.
 * SYNOPSIS
 ]]
function GeneratePart(document_file, document, part)
    --[[
     * INPUTS
     *   * document_file -- The file were it stored.
     *   * document      -- All the documentation.
     *   * part          -- pointer to a RB_Part that contains all the headers found
     *                    in a single source file.
     * SOURCE
    ]]
        logger:info("Generating documentation for file ",srcname)
        if( document.actions.do_singledoc) then
            docname = document.singledoc_name
        elseif document.actions.do_multidoc then
            docname = document.parts.srcfile.path..document.parts.srcfile.file
        elseif document.actions.do_singlefile then
            docname = document.singledoc_name
        else
         -----------
        end

        -------Troff Mode -------

        for i_header = 0, #part.headers do
            logger:info("generating documentation for header",part.headers[i_header].name)
            document_file = generator.GenerateHeaderStart(document_file, part.headers[i_header],document.srcroot.name)
            generator.GenerateNavBar(document, document_file, part.headers[i_header])
            --RB_html_Generate_index_entry is not availabe in robodoc
            --generator.GenerateIndexEntry(document_file, document.doctype, part.headers[i_header])
            generator.GenerateHeader(document_file, part.headers[i_header], docname)
            generator.GenerateHeaderEnd(document_file, part.headers[i_header])
        end
end

function GenerateNavBar(document, current_doc, current_header)
    local switch = {
        ['HTML'] = function()
            html.GenerateNavBar( dest_doc )
        end,
    }

    local f = switch[output_mode]
    if (f) then
        f()
    else           --for default
        -- todo
    end
end

