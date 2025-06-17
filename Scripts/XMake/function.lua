-- ===============================================
-- ================== FUNCTIONS ==================
-- ===============================================
-- Recursively traverse all folders and their subfolders. If .h or .hpp files are found, add the folder to the project.
function add_includedirs_recursively(dir)
    local has_h_files = false
    local has_hpp_files = false
    
    for _, file in ipairs(os.files(path.join(dir, "*.h"))) do
        has_h_files = true
        break
    end
    for _, file in ipairs(os.files(path.join(dir, "*.hpp"))) do
        has_hpp_files = true
        break
    end
    
    if has_h_files or has_hpp_files then
        add_includedirs(dir, {
            public = true
        })
        -- 只添加存在的文件类型
        if has_h_files then
            add_headerfiles(dir .. "/*.h", {
                public = true
            })
        end
        if has_hpp_files then
            add_headerfiles(dir .. "/*.hpp", {
                public = true
            })
        end
    end

    for _, subdir in ipairs(os.dirs(path.join(dir, "*"))) do
        add_includedirs_recursively(subdir)
    end
end

function add_includedirs_recursively_skipped(dir, skip_dirs)
    -- 检查当前文件夹是否需要跳过
    local dir_name = path.basename(dir)
    for _, skip_dir in ipairs(skip_dirs) do
        if dir_name == skip_dir then
            return
        end
    end

    local has_h_files = false
    local has_hpp_files = false
    
    for _, file in ipairs(os.files(path.join(dir, "*.h"))) do
        has_h_files = true
        break
    end
    for _, file in ipairs(os.files(path.join(dir, "*.hpp"))) do
        has_hpp_files = true
        break
    end
    
    if has_h_files or has_hpp_files then
        add_includedirs(dir, {
            public = true
        })
        -- 只添加存在的文件类型
        if has_h_files then
            add_headerfiles(dir .. "/*.h", {
                public = true
            })
        end
        if has_hpp_files then
            add_headerfiles(dir .. "/*.hpp", {
                public = true
            })
        end
    end

    for _, subdir in ipairs(os.dirs(path.join(dir, "*"))) do
        add_includedirs_recursively_skipped(subdir, skip_dirs)  -- 传递 skip_dirs 参数
    end
end


-- Recursively traverse all folders under the folder, find .cpp and .c files and add them to the project.
function add_files_recursively(dir)
    for _, filepath in ipairs(os.files(path.join(dir, "*.cpp"))) do
        add_files(filepath)
    end
    for _, filepath in ipairs(os.files(path.join(dir, "*.c"))) do
        add_files(filepath)
    end
    -- Recursively traverse subfolders
    for _, subdir in ipairs(os.dirs(path.join(dir, "*"))) do
        add_files_recursively(subdir)
    end
end

function add_files_recursively_skipped(dir, skip_dirs)
    -- 检查当前文件夹是否需要跳过
    local dir_name = path.basename(dir)
    for _, skip_dir in ipairs(skip_dirs) do
        if dir_name == skip_dir then
            return
        end
    end
    
    for _, filepath in ipairs(os.files(path.join(dir, "*.cpp"))) do
        add_files(filepath)
    end
    for _, filepath in ipairs(os.files(path.join(dir, "*.c"))) do
        add_files(filepath)
    end
    -- Recursively traverse subfolders
    for _, subdir in ipairs(os.dirs(path.join(dir, "*"))) do
        add_files_recursively_skipped(subdir, skip_dirs)  -- 传递 skip_dirs 参数
    end
end

-- Include all deps under the folder
function include_deps(dir)
    for _, file in ipairs(os.files(path.join(dir, "*/xmake.lua"))) do
        local folder_name = path.basename(path.directory(file))
        includes(file)
    end
end

-- Add resource files under the folder
function add_resource_files_recursively(dir)
    for _, file in ipairs(os.files(path.join(dir, "*.glsl"))) do
        add_headerfiles(file)
    end
    for _, subdir in ipairs(os.dirs(path.join(dir, "*"))) do
        add_resource_files_recursively(subdir)
    end
end


function add_target(target_name)
    target(target_name)
        set_kind("binary")
        add_deps("Dionysen")
        set_group("Atelier")

        local target_path = "Atelier/" .. target_name
        add_includedirs_recursively(target_path)
        add_files_recursively(target_path)
end