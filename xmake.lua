add_rules("mode.debug", "mode.release")
includes("Scripts/XMake/function.lua")
add_requires("zstd", "capstone", "glfw", "glew")
add_requires("nativefiledialog-extended", {configs = {vs_runtimes = "MD", runtimes = "MD"}})
set_languages("c++23")

target("tracy")
    set_kind("binary")
    add_includedirs_recursively("profiler")
    add_files_recursively("profiler")
    include_deps("Vendor")
    add_deps("ppqsort", "imgui")
    add_packages("zstd", "capstone", "glfw", "nativefiledialog-extended", "glew")
    if is_plat("windows") then
        add_defines("NOMINMAX")
        add_syslinks("advapi32", "opengl32")
    end
    add_cxxflags("/utf-8", "/Zc:preprocessor", {force = true})