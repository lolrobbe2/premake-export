workspace "WorkspaceName"
    architecture"x86_64"
    configurations { "Debug", "Release" }

    project "ProjectName"
       kind "ConsoleApp"
       language "C"
       targetdir "bin/%{cfg.buildcfg}"
    
       files { "src/**.c", "include/**.h" }
    
       filter "configurations:Debug"
          defines { "DEBUG" }
          symbols "On"
    
       filter "configurations:Release"
          defines { "NDEBUG" }
          optimize "On"

