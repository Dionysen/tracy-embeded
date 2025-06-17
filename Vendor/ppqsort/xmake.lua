target("ppqsort")
    set_kind("headeronly")
    set_group("Vendor")
    add_includedirs_recursively("include", { public = true })
    add_headerfiles("include/ppqsort.h")

    set_languages("c++23")
    if is_plat("windows") then
        add_defines("NOMINMAX", { public = true })
    end