target("glfw")
    set_kind("static")
    set_group("Vendor")
    -- 添加所有通用源文件
    add_includedirs("include", {
        public = true
    })

    add_files(
        "src/context.c", 
        "src/init.c", 
        "src/input.c", 
        "src/monitor.c", 
        "src/null_init.c", 
        "src/null_joystick.c",
        "src/null_monitor.c", 
        "src/null_window.c", 
        "src/platform.c", 
        "src/vulkan.c", 
        "src/window.c")

    -- Linux 特定配置
    if is_plat("linux") then
        add_files(
            "src/x11_init.c", 
            "src/x11_monitor.c", 
            "src/x11_window.c", 
            "src/xkb_unicode.c", 
            "src/posix_module.c",
            "src/posix_time.c", 
            "src/posix_thread.c", 
            "src/posix_module.c", 
            "src/glx_context.c", 
            "src/egl_context.c",
            "src/osmesa_context.c", 
            "src/linux_joystick.c")
        add_defines("_GLFW_X11")
        add_cflags("-fPIC")
    end

    -- macOS 特定配置
    if is_plat("macosx") then
        add_files(
            "src/cocoa_init.m", 
            "src/cocoa_monitor.m", 
            "src/cocoa_window.m", 
            "src/cocoa_joystick.m",
            "src/cocoa_time.c", 
            "src/nsgl_context.m", 
            "src/posix_thread.c", 
            "src/posix_module.c", 
            "src/osmesa_context.c",
            "src/egl_context.c")
        add_defines("_GLFW_COCOA")
        add_cflags("-fPIC")
    end

    -- Windows 特定配置
    if is_plat("windows") then
        add_files(
            "src/win32_init.c", 
            "src/win32_joystick.c", 
            "src/win32_module.c", 
            "src/win32_monitor.c",
            "src/win32_time.c", 
            "src/win32_thread.c", 
            "src/win32_window.c", 
            "src/wgl_context.c", 
            "src/egl_context.c",
            "src/osmesa_context.c")
        add_defines("_GLFW_WIN32", "_CRT_SECURE_NO_WARNINGS")
    end

    -- Debug 配置
    if is_mode("debug") then
        set_symbols("debug")
        set_runtimes("MD")
    end

    -- Debug-AS 配置（仅Windows）
    if is_plat("windows") and is_mode("debug") then
        on_config(function(target)
            if target:values("sanitizer") then
                target:set("symbols", "debug")
                target:set("runtimes", "MD")
                target:add("cxflags", "/fsanitize=address")
                target:add("ldflags", "/INCREMENTAL:NO")
            end
        end)
    end

    -- Release 配置
    if is_mode("release") then
        set_symbols("none")
        set_optimize("fastest")
        set_runtimes("MD")
    end

    -- Dist 配置
    if is_mode("dist") then
        set_symbols("none")
        set_optimize("fastest")
        set_runtimes("MD")
    end
