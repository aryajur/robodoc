-- TO store all globals to be used across modules

local lfs = require("lfs")

local type = type
local setmetatable = setmetatable
local io = io

local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2
end

function sanitizePath(path,file)
	path = path:gsub([[\]],[[/]]):gsub("^%s*",""):gsub("%s*$","")
	if not file and path:sub(-1,-1) ~= "/" and path ~= "" then
		path = path.."/"
	end
	return path
end	

-- Function to check whether the path exists
function verifyPath(path)
	if type(path) ~= "string" then
		return nil,"Path should be a string"
	end
	local i,d = lfs.dir(path)
	if not d:next() then
		d:close()
		return false,"Path does not exist"
	end
	d:close()
	return true
end

function fileExists(file)
	local f,msg = io.open(file,"r")
	if not f then
		return nil,msg
	end
	f:close()
	return file
end

function fileCreatable(file)
	if fileExists(file) then
		return nil,"File already exists"
	end
	local f,msg = io.open(file,"w+")
	if not f then
		return nil,msg
	end
	f:close()
	os.remove(file)
	return true
end

-- Function to return the directory listing iterator object
-- path is the path of the directory whose iterator is created
-- fd is a indicator to indicate what to iterate:
-- 1 = files only
-- 2 = directories only
-- everything else is files and directories both
-- onlyCurrent true means iterate only the current directory items
dirIter = function(path,fd,onlyCurrent)
	local stat,msg = verifyPath(path)
	if not stat then return nil,msg end
	path = path:gsub([[\]],[[/]]):gsub("^%s*",""):gsub("%s*$","")
	if path:sub(-1,-1) ~= "/" and path ~= "" then
		path = path.."/"
	end
	fd = fd or 3
	
	local obj = {}	-- iterator object
	local objMeta = {
		__index = {
			next = function()
				local item = obj.dObj[#obj.dObj].obj:next()
				if not item then
					if onlyCurrent then
						return nil
					end
					-- go up a level
					while #obj.dObj > 0 and not item do
						obj.dObj[#obj.dObj].obj:close()
						obj.dObj[#obj.dObj] = nil
						if #obj.dObj == 0 then
							break
						end
						item = obj.dObj[#obj.dObj].obj:next()
					end
					if #obj.dObj == 0 then
						-- nothing found
						return nil
					end
				end	-- if not item then ends here
				if item == "." or item == ".." then
					return obj.next()	-- skip these
				end
				-- We have an item now check whether it is file or directory
				if lfs.attributes(obj.dObj[#obj.dObj].path..item,"mode") == "directory" then
					local offset = 1
					if not onlyCurrent then
						-- Set the next iterator by going into the directory
						obj.dObj[#obj.dObj+1] = {path = obj.dObj[#obj.dObj].path..item.."/"}
						local i
						i,obj.dObj[#obj.dObj].obj = lfs.dir(obj.dObj[#obj.dObj].path)
						offset = 0
					end
					if fd == 1 then
						return obj.next()	-- directories not to be returned
					else
						return item,obj.dObj[#obj.dObj-1+offset].path,"directory"
					end
				else
					-- Not a directory object
					if fd == 2 then
						return obj.next()
					else
						return item,obj.dObj[#obj.dObj].path,"file"
					end
				end		-- if lfs.attributes(obj.dObj[#obj.dObj].path..item,"mode") == "directory" then ends
			end
		},
		__newindex = function(t,k,v)
		end,
		__gc = function(t)
			for i = #t.dObj,1,-1 do
				t.dObj[i].obj:close()
			end
		end
	}
	
	obj.dObj = {{path=path}}
	local i
	i,obj.dObj[1].obj=lfs.dir(path)
	setmetatable(obj,objMeta)
	return obj
end

-- Function to make sure that the given path exists. 
-- If not then the full hierarchy is created where required to reach the given path
function createPath(path)
	if verifyPath(path) then
		return true
	end
	local p = ""
	local stat,msg
	for pth in path:gmatch("(.-)%/") do
		p = p..pth.."/"
		if not verifyPath(p) then
			-- Create this directory
			stat,msg = lfs.mkdir(p)
			if not stat then
				return nil,msg
			end
		end
	end
	return true
end
	