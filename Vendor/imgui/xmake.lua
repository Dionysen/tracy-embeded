-- add_requires("vulkansdk")
target("imgui")
    set_languages("cxx14")
    set_kind("static")
    set_group("Vendor")
    
    add_files("*.cpp", "misc/cpp/*.cpp")
    add_headerfiles("*.h", "(misc/cpp/*.h)", { public = true })
    add_includedirs(".", "backends", "misc/cpp", { public = true })
 
    -- add_packages("vulkansdk")
    add_deps("glfw")

    if is_kind("shared") and is_plat("windows", "mingw") then
        add_defines("IMGUI_API=__declspec(dllexport)")
    end
    
    if is_plat("windows") then
        add_defines("NOMINMAX", { public = true })
    end

    -- dx9 backend
    -- add_files("backends/imgui_impl_dx9.cpp")
    -- add_headerfiles("(backends/imgui_impl_dx9.h)")

    -- dx10 backend
    -- add_files("backends/imgui_impl_dx10.cpp")
    -- add_headerfiles("(backends/imgui_impl_dx10.h)")

    -- dx11 backend
    -- add_files("backends/imgui_impl_dx11.cpp")
    -- add_headerfiles("(backends/imgui_impl_dx11.h)")

    -- dx12 backend
    -- add_files("backends/imgui_impl_dx12.cpp")
    -- add_headerfiles("(backends/imgui_impl_dx12.h)")

    -- glfw backend
    add_files("backends/imgui_impl_glfw.cpp")
    add_headerfiles("(backends/imgui_impl_glfw.h)")

    -- opengl2 backend
    -- add_files("backends/imgui_impl_opengl2.cpp")
    -- add_headerfiles("(backends/imgui_impl_opengl2.h)")

    -- opengl3 backend
    add_files("backends/imgui_impl_opengl3.cpp")
    add_headerfiles("(backends/imgui_impl_opengl3.h)")
    add_headerfiles("(backends/imgui_impl_opengl3_loader.h)")

    -- vulkan backend, impl in by us
    -- add_files("backends/imgui_impl_vulkan.cpp")
    -- add_headerfiles("(backends/imgui_impl_vulkan.h)")
    add_packages("vulkansdk")
    
    -- add_includedirs("$(env VULKAN_SDK)/Include")
    -- add_linkdirs("$(env VULKAN_SDK)/Lib", "$(env VULKAN_SDK)/Bin")
    -- add_links(
    --     "vulkan-1"
    -- )

    -- win32 backend
    -- add_files("backends/imgui_impl_win32.cpp")
    -- add_headerfiles("(backends/imgui_impl_win32.h)")

    -- wgpu backend 
    -- add_files("backends/imgui_impl_wgpu.cpp")
    -- add_headerfiles("(backends/imgui_impl_wgpu.h)")
    -- add_packages("wgpu-native")


    -- if has_config("freetype") then
    --     add_files("misc/freetype/imgui_freetype.cpp")
    --     add_headerfiles("misc/freetype/imgui_freetype.h")
    --     add_packages("freetype")
    --     add_defines("IMGUI_ENABLE_FREETYPE")
    -- end

    -- add_defines("IMGUI_USE_WCHAR32")

    add_includedirs("misc/cpp")
    add_files("misc/cpp/*.cpp")