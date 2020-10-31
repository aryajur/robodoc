local globals = require("globals")
local html = require("outputs.html")

local stirng = string
local table = table
local tonumber = tonumber
local pairs = pairs
local next = next

local M = {}
if setfenv and type(setfenv) == "functon" then
    setfenv(1,M)         --Lua 5.1
else
    _ENV = M             --Lua 5.2+
end

ItemType = {

    POSSIBLE_ITEM = -2,
    NO_ITEM = -1,
    SOURCECODE_ITEM = 0,
    OTHER_ITEM
}

ItemLineKind = {
    "ITEM_LINE_RAW",              -- A line that does not start with a remark marker 
    "ITEM_LINE_PLAIN",            --A line that starts with a remark marker 
    "ITEM_LINE_PIPE",             --A line that starts with a remark marked and is followed by a pipe marker. 
    "ITEM_LINE_END",              --The last line of an item 
    "ITEM_LINE_TOOL_START",       --Start line of a tool item
    "ITEM_LINE_TOOL_BODY",        --Body of a tool item
    "ITEM_LINE_TOOL_END",         --End line of a tool item
    "ITEM_LINE_EXEC",             --Exec item
    "ITEM_LINE_DOT_START",        --Similar to TOOL_START but use DOT tool
    "ITEM_LINE_DOT_END",          --End line of a DOT item
    "ITEM_LINE_DOT_FILE",          --DOT file to include
}
-- This should be an enum --

ItemEnun = {
    RBILA_BEGIN_PARAGRAPH,
    RBILA_END_PARAGRAPH  ,
    RBILA_BEGIN_LIST     ,
    RBILA_END_LIST       ,
    RBILA_BEGIN_LIST_ITEM,
    RBILA_END_LIST_ITEM  ,
    RBILA_BEGIN_PRE      ,
    RBILA_END_PRE        ,
    RBILA_BEGIN_SOURCE   ,
    RBILA_END_SOURCE     ,
}



--[[***f* HeaderTypes/Works_Like_SourceItem
 * FUNCTION
 *   Tells wether this item works similar to the
 *   source item, that is weather it copies it's
 *   content verbatim to the output document.
 * SYNPOPSIS
 ]]
function Works_Like_SourceItem(item_type)
--[[
 * INPUTS
 *   item_type -- Type of item (also the index to the item name)
 * RESULT
 *   TRUE  -- Item works like a SOURCE item
 *   FALSE -- Item does NOT work like a SOURCE item
 * SOURCE
 ]]
    -- Check if it is a source item
    if( item_type == SOURCECODE_ITEM) then
        return true
    end

    --Lookup if it works like a source item
    for i=1, #configuration.source_items do
        if(configuration.source_items[i]==configuration.items[item_type]) then
            return true
        end
    end

    return false

end