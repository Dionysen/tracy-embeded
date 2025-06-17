on_load(function (target)
    dir = os.getenv("VULKAN_SDK")
    if not dir then
        print("Vulkan SDK not found. Please set VULKAN_SDK environment variable.")
        print("Do you want to install Vulkan SDK? (y/n)")

        io.flush()
        local confirm = io.read()

        if confirm:trim() ~= "y" and confirm:trim() ~= "yes" then
            print("Installation cancelled.")
            return
        else
            print("Installing Vulkan SDK ...")
            local vulkan_version = "1.4.304.1"
            local vulkan_sdk_url = "https://sdk.lunarg.com/sdk/download/" .. vulkan_version .. "/linux/vulkansdk-linux-x86_64-" .. vulkan_version .. ".tar.xz"
            local downloaded_dir = os.scriptdir() .. "/Dionysen/External"

            -- Create download directory if it doesn't exist
            if not os.isdir(downloaded_dir) then
                os.mkdir(downloaded_dir)
            end
            
            -- Download Vulkan SDK
            local downloaded_file = downloaded_dir .. "/vulkansdk.tar.xz"
            print("Downloading from: " .. vulkan_sdk_url)
            
            -- Use wget instead of curl for better reliability
            local wget_cmd = string.format("wget -O %s %s", downloaded_file, vulkan_sdk_url)
            local download_ok = os.exec(wget_cmd)
            
            if download_ok ~= 0 then
                print("Failed to download Vulkan SDK")
                return
            end
            
            -- Extract the SDK
            print("Extracting Vulkan SDK...")
            local extract_cmd = string.format("tar xf %s -C %s", downloaded_file, downloaded_dir)
            local extract_ok = os.exec(extract_cmd)
            
            if extract_ok ~= 0 then
                print("Failed to extract Vulkan SDK")
                return
            end
            
            -- Remove the downloaded archive
            os.rm(downloaded_file)

            print("Vulkan SDK has been downloaded and extracted to " .. downloaded_dir)
        end
    else 
        print("Vulkan SDK found at " .. dir)
        return
    end
end)

function add_vulkan_sdk(dir)
    if is_plat("windows") then
        local include_dir= "Include"
        local lib_dir= "Lib"
        local bin_dir= "Bin"
        if not dir then
            dir = os.getenv("VULKAN_SDK")
        end
        add_includedirs(dir .. "/" .. include_dir)
        add_linkdirs(dir .. "/" .. lib_dir, dir .. "/" .. bin_dir)
        add_links_recursively(dir)
    elseif is_plat("linux") then
        local include_dir = "include"
        local lib_dir = "lib"
        local bin_dir = "bin"

        if not dir then
            dir = os.getenv("VULKAN_SDK")
        end
        add_includedirs(dir .. "/" .. include_dir)
        add_linkdirs(dir .. "/" .. lib_dir, dir .. "/" .. bin_dir)
        add_links_recursively(dir)
    end
end


function add_any_libs(list, dir)
    if is_plat("windows") then
        for _, libfile in ipairs(os.files(path.join(dir, "*.lib"))) do
                
        end
    elseif is_plat("linux") then
        for _, libfile in ipairs(os.files(path.join(dir, "*.so"))) do
            local basename = path.basename(libfile)
            -- Remove "lib" prefix and file extension from the library name
            local libname = basename:gsub("^lib", ""):gsub("%.%w+$", "")
            table.insert(list, libname)
        end
    end
end

-- This is a xmake package for the Vulkan SDK
package("vulkansdk")
    set_homepage("https://www.lunarg.com/vulkan-sdk/")
    set_description("LunarG Vulkan® SDK")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    add_configs("utils",  {description = "Enabled vulkan utilities.", default = {}, type = "table"})

    on_load(function (package)
        import("detect.sdks.find_vulkansdk")
        local vulkansdk = find_vulkansdk()
        if vulkansdk then
            package:addenv("PATH", vulkansdk.bindir)
        end
    end)

    on_fetch(function (package, opt)
        if opt.system then
            import("detect.sdks.find_vulkansdk")
            import("lib.detect.find_library")

            local vulkansdk = find_vulkansdk()
            if vulkansdk then
                local result = {includedirs = vulkansdk.includedirs, linkdirs = vulkansdk.linkdirs, links = {}}
                local utils = package:config("utils")

                if package:is_plat("windows", "mingw") then
                    table.insert(utils, "vulkan-1")
                    -- print("vulkansdk.linkdirs: ",vulkansdk.linkdirs)
                    local libdir = vulkansdk.linkdirs
                    -- 遍历所有链接目录
                    for _, libdir in ipairs(vulkansdk.linkdirs) do
                        -- print("vulkansdk.libdir: ", libdir)
                        local libs = os.files(path.join(libdir, "*.lib"))
                        for _, lib in ipairs(libs) do
                            local basename = path.basename(lib)
                            -- 删除前缀"lib"和后缀
                            local libname = basename.sub(basename, 0, -1)
                            if libname and libname ~= "" then
                                table.insert(utils, libname)
                            end
                        end
                    end
                else
                    table.insert(utils, "vulkan")
                    local libdir = vulkansdk.linkdirs
                    -- 遍历所有链接目录
                    for _, libdir in ipairs(vulkansdk.linkdirs) do
                        -- 处理静态库
                        -- print("vulkansdk.libdir: ", libdir)
                        local libs = os.files(path.join(libdir, "*.a"))
                        for _, lib in ipairs(libs) do
                            local basename = path.basename(lib)
                            -- 简单地删除前缀"lib"和后缀".a"
                            local libname = basename.sub(basename, 4, -1)
                            if libname and libname ~= "" then
                                table.insert(utils, libname)
                            end
                        end
                        
                        -- 处理动态库
                        libs = os.files(path.join(libdir, "*.so"))
                        for _, lib in ipairs(libs) do
                            local basename = path.basename(lib)
                            -- 简单地删除前缀"lib"和后缀".a"
                            local libname = basename.sub(basename, 4, -1)
                            if libname and libname ~= "" then
                                table.insert(utils, libname)
                            end
                        end
                    end
                end

                -- for debug
                -- print("vulkansdk.list: ", utils)
                
                for _, util in ipairs(utils) do
                    if not find_library(util, vulkansdk.linkdirs, {plat = package:plat()}) then
                        wprint(format("The library %s for %s is not found!", util, package:arch()))
                        return
                    end
                    -- print("Adding library: ", util)
                    table.insert(result.links, util)
                end
                -- print("vulkansdk.links: ", result)
                return result
            end
        end
    end)