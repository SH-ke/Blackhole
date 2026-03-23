const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Blackhole",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.linkLibC();
    exe.linkLibCpp();

    const cpp_sources = &.{
        "src/GLDebugMessageCallback.cc",
        "src/imgui_impl_glfw.cpp",
        "src/imgui_impl_opengl3.cpp",
        "src/main.cpp",
        "src/render.cpp",
        "src/shader.cpp",
        "src/stb_image.cpp",
        "src/texture.cpp",
    };
    exe.addCSourceFiles(.{ .files = cpp_sources, .flags = &.{ "-std=c++17" } });

    const imgui_sources = &.{
        "libs/imgui-1.86/imgui.cpp",
        "libs/imgui-1.86/imgui_draw.cpp",
        "libs/imgui-1.86/imgui_widgets.cpp",
        "libs/imgui-1.86/imgui_tables.cpp",
        "libs/imgui-1.86/imgui_demo.cpp",
    };
    exe.addCSourceFiles(.{ .files = imgui_sources, .flags = &.{ "-std=c++17" } });

    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("libs/imgui-1.86"));
    exe.addIncludePath(b.path("libs/glm-0.9.9.8"));
    exe.addIncludePath(b.path("libs/glfw-3.3.9.bin.WIN64/include"));
    exe.addIncludePath(b.path("libs/glew-2.2.0/include"));
    exe.addIncludePath(b.path("libs/stb"));

    exe.addLibraryPath(b.path("libs/glfw-3.3.9.bin.WIN64/lib-mingw-w64"));
    exe.addLibraryPath(b.path("libs/glew-2.2.0/lib/Release/x64"));

    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("glew32");
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("shell32");

    b.installArtifact(exe);

    const install_assets = b.addInstallDirectory(.{
        .source_dir = b.path("assets"),
        .install_dir = .bin,
        .install_subdir = "assets",
    });
    const install_shader = b.addInstallDirectory(.{
        .source_dir = b.path("shader"),
        .install_dir = .bin,
        .install_subdir = "shader",
    });
    b.getInstallStep().dependOn(&install_assets.step);
    b.getInstallStep().dependOn(&install_shader.step);

    const install_glfw = b.addInstallBinFile(b.path("libs/glfw-3.3.9.bin.WIN64/lib-mingw-w64/glfw3.dll"), "glfw3.dll");
    const install_glew = b.addInstallBinFile(b.path("libs/glew-2.2.0/bin/Release/x64/glew32.dll"), "glew32.dll");
    b.getInstallStep().dependOn(&install_glfw.step);
    b.getInstallStep().dependOn(&install_glew.step);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
