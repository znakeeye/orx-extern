--
-- tests/test_gmake_cpp.lua
-- Automated test suite for GNU Make C/C++ project generation.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.gmake_cpp = { }

--
-- Configure a solution for testing
--

	local sln, prj
	function T.gmake_cpp.setup()
		_ACTION = "gmake"
		_OPTIONS.os = "linux"

		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms { "native" }

		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
	end

	local function prepare()
		premake.bake.buildconfigs()
	end



--
-- Test the header
--

	function T.gmake_cpp.BasicHeader()
		prepare()
		premake.gmake_cpp_header(prj, premake.gcc, sln.platforms)
		test.capture [[
# GNU Make project makefile autogenerated by Premake
ifndef config
  config=debug
endif

ifndef verbose
  SILENT = @
endif

CC = gcc
CXX = g++
AR = ar

ifndef RESCOMP
  ifdef WINDRES
    RESCOMP = $(WINDRES)
  else
    RESCOMP = windres
  endif
endif
		]]
	end



--
-- Test configuration blocks
--

	function T.gmake_cpp.BasicCfgBlock()
		prepare()
		local cfg = premake.getconfig(prj, "Debug")
		premake.gmake_cpp_config(cfg, premake.gcc)
		test.capture [[
ifeq ($(config),debug)
  OBJDIR     = obj/Debug
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/MyProject
  DEFINES   +=
  INCLUDES  +=
  ALL_CPPFLAGS  += $(CPPFLAGS) -MMD -MP $(DEFINES) $(INCLUDES) $(FORCE_INCLUDE)
  ALL_CFLAGS    += $(CFLAGS) $(ALL_CPPFLAGS) $(ARCH)
  ALL_CXXFLAGS  += $(CXXFLAGS) $(ALL_CFLAGS)
  ALL_RESFLAGS  += $(RESFLAGS) $(DEFINES) $(INCLUDES)
  ALL_LDFLAGS   += $(LDFLAGS) -s
  LIBS      +=
  LDDEPS    +=
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(ALL_LDFLAGS) $(LIBS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif
		]]
	end


	function T.gmake_cpp.BasicCfgBlockWithPlatformCc()
		platforms { "ps3" }
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "PS3")
		premake.gmake_cpp_config(cfg, premake.gcc)
		test.capture [[
ifeq ($(config),debugps3)
  CC         = ppu-lv2-g++
  CXX        = ppu-lv2-g++
  AR         = ppu-lv2-ar
  OBJDIR     = obj/PS3/Debug
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/MyProject.elf
  DEFINES   +=
  INCLUDES  +=
  ALL_CPPFLAGS  += $(CPPFLAGS) -MMD -MP $(DEFINES) $(INCLUDES) $(FORCE_INCLUDE)
  ALL_CFLAGS    += $(CFLAGS) $(ALL_CPPFLAGS) $(ARCH)
  ALL_CXXFLAGS  += $(CXXFLAGS) $(ALL_CFLAGS)
  ALL_RESFLAGS  += $(RESFLAGS) $(DEFINES) $(INCLUDES)
  ALL_LDFLAGS   += $(LDFLAGS) -s
  LIBS      +=
  LDDEPS    +=
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(ALL_LDFLAGS) $(LIBS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif
		]]
	end


	function T.gmake_cpp.PlatformSpecificBlock()
		platforms { "x64" }
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "x64")
		premake.gmake_cpp_config(cfg, premake.gcc)
		test.capture [[
ifeq ($(config),debug64)
  OBJDIR     = obj/x64/Debug
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/MyProject
  DEFINES   +=
  INCLUDES  +=
  ALL_CPPFLAGS  += $(CPPFLAGS) -MMD -MP $(DEFINES) $(INCLUDES) $(FORCE_INCLUDE)
  ALL_CFLAGS    += $(CFLAGS) $(ALL_CPPFLAGS) $(ARCH) -m64
  ALL_CXXFLAGS  += $(CXXFLAGS) $(ALL_CFLAGS)
  ALL_RESFLAGS  += $(RESFLAGS) $(DEFINES) $(INCLUDES)
  ALL_LDFLAGS   += $(LDFLAGS) -s -m64 -L/usr/lib64
  LIBS      +=
  LDDEPS    +=
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(RESOURCES) $(ARCH) $(ALL_LDFLAGS) $(LIBS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif
		]]
	end


	function T.gmake_cpp.UniversalStaticLibBlock()
		kind "StaticLib"
		platforms { "universal32" }
		prepare()
		local cfg = premake.getconfig(prj, "Debug", "Universal32")
		premake.gmake_cpp_config(cfg, premake.gcc)
		test.capture [[
ifeq ($(config),debuguniv32)
  OBJDIR     = obj/Universal32/Debug
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/libMyProject.a
  DEFINES   +=
  INCLUDES  +=
  ALL_CPPFLAGS  += $(CPPFLAGS)  $(DEFINES) $(INCLUDES) $(FORCE_INCLUDE)
  ALL_CFLAGS    += $(CFLAGS) $(ALL_CPPFLAGS) $(ARCH) -arch i386 -arch ppc
  ALL_CXXFLAGS  += $(CXXFLAGS) $(ALL_CFLAGS)
  ALL_RESFLAGS  += $(RESFLAGS) $(DEFINES) $(INCLUDES)
  ALL_LDFLAGS   += $(LDFLAGS) -s -arch i386 -arch ppc
  LIBS      +=
  LDDEPS    +=
  LINKCMD    = libtool -o $(TARGET) $(OBJECTS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif
		]]
	end
