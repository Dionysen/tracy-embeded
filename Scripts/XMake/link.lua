
function add_links_recursively_windows(dir)
    -- Add all .lib files in the current directory
    for _, libfile in ipairs(os.files(path.join(dir, "*.lib"))) do
        add_links(path.basename(libfile))
    end
    -- Recursively traverse subfolders
    for _, subdir in ipairs(os.dirs(path.join(dir, "*"))) do
        add_links_recursively(subdir)
    end
end

function add_links_recursively_linux(dir)
    -- Add all .so .a files in the current directory
    local lib_patterns = {"*.a", "*.so"}
    for _, pattern in ipairs(lib_patterns) do
        for _, libfile in ipairs(os.files(path.join(dir, pattern))) do
            local basename = path.basename(libfile)
            -- Remove "lib" prefix and file extension from the library name
            local libname = basename:gsub("^lib", ""):gsub("%.%w+$", "")
            add_links(libname)
        end
    end
    -- Recursively traverse subfolders
    for _, subdir in ipairs(os.dirs(path.join(dir, "*"))) do
        add_links_recursively(subdir)
    end
end

function add_links_recursively(dir)
    if is_plat("windows") then
        add_links_recursively_windows(dir)
    elseif is_plat("linux") then
        add_links_recursively_linux(dir)
    else
        print("Unsupported platform: " .. os.host())
        return
    end
end
