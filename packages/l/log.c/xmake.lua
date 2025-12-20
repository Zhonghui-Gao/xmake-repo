package("log.c")
    set_homepage("https://github.com/rxi/log.c")
    set_description("A simple logging library implemented in C99")
    set_license("MIT")

    add_urls("https://github.com/rxi/log.c.git")
    add_versions("master", "master")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean"})
    add_configs("color", {description = "Enable colored output.", default = true, type = "boolean"})

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        -- 将包配置传递给内部构建配置
        configs.color = package:config("color")

        -- 动态生成 xmake.lua
        -- 修正点1: 显式定义 option("color") 以接收 --color 参数
        -- 修正点2: 源文件路径改为 "log.c" (原仓库没有 src 目录)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")

            option("color")
                set_default(true)
                set_showmenu(true)
                add_defines("LOG_USE_COLOR")

            target("logc")
                set_kind("$(kind)")
                add_files("src/log.c") 
                add_headerfiles("src/log.h")
                add_options("color")
        ]])

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("log_log", {includes = "log.h"}))

    end)
