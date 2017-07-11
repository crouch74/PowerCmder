-- Source: https://github.com/crouch74/PowerCmder 
-- Based on: https://github.com/AmrEldib/cmder-powerline-prompt 
local Json = require("json")
--- promptValue is whether the displayed prompt is the full path or only the folder name
 -- Use:
 -- "full" for full path like C:\Windows\System32
local promptValueFull = "full"
 -- "folder" for folder name only like System32
local promptValueFolder = "folder"
 -- default is promptValueFull
local promptValue = promptValueFull


local arrowSymbol = ""
local branchSymbol = ""
local deatchedSymbol = "➦"

local function get_folder_name(path)
	local reversePath = string.reverse(path)
	local slashIndex = string.find(reversePath, "\\")
	return string.sub(path, string.len(path) - slashIndex + 2)
end

local function get_last_word(s,sep)
	local reverseS = string.reverse(s)
	local sepIndex = string.find(reverseS, sep)
	return string.sub(s, string.len(s) - sepIndex + string.len(sep) + 1 )
end

-- return parent path for specified entry (either file or directory)
local function pathname(path)
    local prefix = ""
    local i = path:find("[\\/:][^\\/:]*$")
    if i then
        prefix = path:sub(1, i-1)
    end
    return prefix
end

-- Resets the prompt 
function lambda_prompt_filter()
    cwd = clink.get_cwd()
	if promptValue == promptValueFolder then
		cwd =  get_folder_name(cwd)
	end
    prompt = "\x1b[30;44m"..arrowSymbol.." \x1b[37;44m{cwd} {git}{hg} {npm}\n\x1b[1;32;40m{lamb} \x1b[0m"
    new_value = string.gsub(prompt, "{cwd}", cwd)
    clink.prompt.value = string.gsub(new_value, "{lamb}", "λ")
end


--- copied from clink.lua
 -- Resolves closest directory location for specified directory.
 -- Navigates subsequently up one level and tries to find specified directory
 -- @param  {string} path    Path to directory will be checked. If not provided
 --                          current directory will be used
 -- @param  {string} dirname Directory name to search for
 -- @return {string} Path to specified directory or nil if such dir not found
local function get_dir_contains(path, dirname)

    -- Navigates up one level
    local function up_one_level(path)
        if path == nil then path = '.' end
        if path == '.' then path = clink.get_cwd() end
        return pathname(path)
    end

    -- Checks if provided directory contains git directory
    local function has_specified_dir(path, specified_dir)
        if path == nil then path = '.' end
        local found_dirs = clink.find_dirs(path..'/'..specified_dir)
        if #found_dirs > 0 then return true end
        return false
    end

    -- Set default path to current directory
    if path == nil then path = '.' end

    -- If we're already have .git directory here, then return current path
    if has_specified_dir(path, dirname) then
        return path..'/'..dirname
    else
        -- Otherwise go up one level and make a recursive call
        local parent_path = up_one_level(path)
        if parent_path == path then
            return nil
        else
            return get_dir_contains(parent_path, dirname)
        end
    end
end

-- copied from clink.lua
-- clink.lua is saved under %CMDER_ROOT%\vendor
local function get_hg_dir(path)
    return get_dir_contains(path, '.hg')
end

-- adopted from clink.lua
-- clink.lua is saved under %CMDER_ROOT%\vendor
function colorful_hg_prompt_filter()

    -- Colors for mercurial status
    local colors = {
        clean = "\x1b[1;37;40m",
        dirty = "\x1b[31;1m",
    }

    if get_hg_dir() then
        -- if we're inside of mercurial repo then try to detect current branch
        local branch = get_hg_branch()
        if branch then
            -- Has branch => therefore it is a mercurial folder, now figure out status
            if get_hg_status() then
                color = colors.clean
            else
                color = colors.dirty
            end

            clink.prompt.value = string.gsub(clink.prompt.value, "{hg}", color.."("..branch..")")
            return false
        end
    end

    -- No mercurial present or not in mercurial file
    clink.prompt.value = string.gsub(clink.prompt.value, "{hg}", "")
    return false
end

-- copied from clink.lua
-- clink.lua is saved under %CMDER_ROOT%\vendor
local function get_git_dir(path)

    -- return parent path for specified entry (either file or directory)
    local function pathname(path)
        local prefix = ""
        local i = path:find("[\\/:][^\\/:]*$")
        if i then
            prefix = path:sub(1, i-1)
        end
        return prefix
    end

    -- Checks if provided directory contains git directory
    local function has_git_dir(dir)
        return #clink.find_dirs(dir..'/.git') > 0 and dir..'/.git'
    end

    local function has_git_file(dir)
        local gitfile = io.open(dir..'/.git')
        if not gitfile then return false end

        local git_dir = gitfile:read():match('gitdir: (.*)')
        gitfile:close()

        return git_dir and dir..'/'..git_dir
    end

    -- Set default path to current directory
    if not path or path == '.' then path = clink.get_cwd() end

    -- Calculate parent path now otherwise we won't be
    -- able to do that inside of logical operator
    local parent_path = pathname(path)

    return has_git_dir(path)
        or has_git_file(path)
        -- Otherwise go up one level and make a recursive call
        or (parent_path ~= path and get_git_dir(parent_path) or nil)
end

---
 -- Get the status of working dir
 -- @return {bool}
---
function get_git_status()
    local file = io.popen("git status --no-lock-index --porcelain 2>nul")
    for line in file:lines() do
        file:close()
        return false
    end
    file:close()
    return true
end

---
 -- Check if current head is detached
 -- @return {bool}
---
function get_git_detached()
    local file = io.popen("git status 2>nul")
    for line in file:lines() do
        if string.find(line,' detached') then
            file:close()
            return true
        end
    end
    file:close()
    return false
end

-- adopted from clink.lua
-- Modified to add colors and arrow symbols
function colorful_git_prompt_filter()

    -- Colors for git status
    local colors = {
        clean = "\x1b[34;42m"..arrowSymbol.."\x1b[37;42m ",
        dirty = "\x1b[34;43m"..arrowSymbol.."\x1b[30;43m ",
    }

    local closingcolors = {
        clean = " \x1b[32;40m"..arrowSymbol,
        dirty = "± \x1b[33;40m"..arrowSymbol,
    }

    local git_dir = get_git_dir()
    if git_dir then
        -- if we're inside of git repo then try to detect current branch
        local branch = get_git_branch(git_dir)
        local checkedOutSymbol = branchSymbol
        if branch then
            -- Has branch => therefore it is a git folder, now figure out status
            if get_git_status() then
                color = colors.clean
                closingcolor = closingcolors.clean
            else
                color = colors.dirty
                closingcolor = closingcolors.dirty
            end

            if get_git_detached() then
                checkedOutSymbol = deatchedSymbol
                branch = "("..get_last_word(branch," ")..")"
            end

            --clink.prompt.value = string.gsub(clink.prompt.value, "{git}", color.."  "..branch..closingcolor)
            clink.prompt.value = string.gsub(clink.prompt.value, "{git}", color..""..checkedOutSymbol.." "..branch..closingcolor)
            return false
        end
    end

    -- No git present or not in git file
    clink.prompt.value = string.gsub(clink.prompt.value, "{git}", "\x1b[34;40m"..arrowSymbol)
    return false
end

-- NPM prompt filter
-- get the path of package.json file
function get_npm_package_file(path)
    -- default path : CWD
    if path == nil then path = clink.get_cwd() end

    local parent_path = pathname(path)
    local gitfile = io.open(path..'/package.json')
    if not gitfile then
        return nil
            or (parent_path ~= path and get_npm_package_file(parent_path) or nil)
    end
    gitfile:close()
    return path..'/package.json'
end

function parse_package_file(path)
    local file = io.open( path, "r" )
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        return Json:decode(contents)
    end
    return nil
end

function colorful_npm_prompt_filter()
    local pf = get_npm_package_file()
    if pf then
        local table = parse_package_file(pf)
        local name = table["name"] == nil and "no-name" or table["name"] 
        local version = table["version"] == nil and "0.0.0" or table["version"]
        clink.prompt.value = string.gsub(clink.prompt.value, "{npm}", "\x1b[33m<"..name.."@"..version..">")
        return false
    end
    clink.prompt.value = string.gsub(clink.prompt.value, "{npm}", "")
    return false
end




-- override the built-in filters
clink.prompt.register_filter(lambda_prompt_filter, 55)
clink.prompt.register_filter(colorful_hg_prompt_filter, 60)
clink.prompt.register_filter(colorful_git_prompt_filter, 60)
clink.prompt.register_filter(colorful_npm_prompt_filter, 60)