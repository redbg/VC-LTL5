﻿cmake_minimum_required(VERSION 3.13)

#VC-LTL核心版本号，由于4.X并不兼容3.X。此值可以用于兼容性判断。
set(LTL_CoreVersion 5)

if(NOT SupportWinXP)
    set(SupportWinXP "false")
endif()


if(NOT SupportLTL)
    set(InternalSupportLTL "true")
else()
    set(InternalSupportLTL ${SupportLTL})
endif()

if(${InternalSupportLTL} STREQUAL "true")
    if(NOT CMAKE_SYSTEM_NAME)
        message(WARNING "VC-LTL not load, because CMAKE_SYSTEM_NAME is not defined!!!")
        set(InternalSupportLTL "false")
    elseif(NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
        message(WARNING "VC-LTL not load, because ${CMAKE_SYSTEM_NAME} is not supported!!!")
        set(InternalSupportLTL "false")
    endif()
endif()


if(${InternalSupportLTL} STREQUAL "true")
    if(LTLPlatform)
        #外部已经定义
    elseif(CMAKE_GENERATOR_PLATFORM)
        # -A 参数已经传递，仅在 CMake 3.1更高版本中支持
        message("CMAKE_GENERATOR_PLATFORM = " ${CMAKE_GENERATOR_PLATFORM})
        string(TOLOWER "${CMAKE_GENERATOR_PLATFORM}" CMAKE_GENERATOR_PLATFORM_LOWER)
        if(${CMAKE_GENERATOR_PLATFORM_LOWER} STREQUAL "win32")
            set(LTLPlatform "Win32")
        elseif(${CMAKE_GENERATOR_PLATFORM_LOWER} STREQUAL "x64")
            set(LTLPlatform "x64")
        elseif(${CMAKE_GENERATOR_PLATFORM_LOWER} STREQUAL "arm")
            set(LTLPlatform "arm")
        elseif(${CMAKE_GENERATOR_PLATFORM_LOWER} STREQUAL "arm64")
            set(LTLPlatform "arm64")
        else()
            message(WARNING "VC-LTL not load, Unknown Platform!!!")
            set(InternalSupportLTL "false")
        endif()
    elseif(CMAKE_VS_PLATFORM_NAME)
        # CMake 3.1以及更早版本不支持 -A 参数，因此通过 CMAKE_VS_PLATFORM_NAME解决
        message("CMAKE_VS_PLATFORM_NAME = " ${CMAKE_VS_PLATFORM_NAME})
        string(TOLOWER "${CMAKE_VS_PLATFORM_NAME}" CMAKE_VS_PLATFORM_NAME_LOWER)
        if(${CMAKE_VS_PLATFORM_NAME_LOWER} STREQUAL "win32")
            set(LTLPlatform "Win32")
        elseif(${CMAKE_VS_PLATFORM_NAME_LOWER} STREQUAL "x64")
            set(LTLPlatform "x64")
        elseif(${CMAKE_VS_PLATFORM_NAME_LOWER} STREQUAL "arm")
            set(LTLPlatform "arm")
        elseif(${CMAKE_VS_PLATFORM_NAME_LOWER} STREQUAL "arm64")
            set(LTLPlatform "arm64")
        else()
            message(WARNING "VC-LTL not load, Unknown Platform!!!")
            set(InternalSupportLTL "false")
        endif()
    elseif(MSVC_VERSION)
        message("load CheckSymbolExists......")

        include(CheckSymbolExists)

        check_symbol_exists("_M_IX86" "" _M_IX86)
        check_symbol_exists("_M_AMD64" "" _M_AMD64)
        check_symbol_exists("_M_ARM" "" _M_ARM)
        check_symbol_exists("_M_ARM64" "" _M_ARM64)

        if(_M_AMD64)
            set(LTLPlatform "x64")
        elseif(_M_IX86)
            set(LTLPlatform "Win32")
        elseif(_M_ARM)
            set(LTLPlatform "arm")
        elseif(_M_ARM64)
            set(LTLPlatform "arm64")
        else()
            message(WARNING "VC-LTL not load, Unknown Platform!!!")
            set(InternalSupportLTL "false")
        endif()
    elseif(VCPKG_TARGET_ARCHITECTURE)
        #为了兼容VCPKG
        message("VCPKG_TARGET_ARCHITECTURE = " ${VCPKG_TARGET_ARCHITECTURE})
        string(TOLOWER "${VCPKG_TARGET_ARCHITECTURE}" VCPKG_TARGET_ARCHITECTURE_LOWER)
        if(${VCPKG_TARGET_ARCHITECTURE_LOWER} STREQUAL "x86")
            set(LTLPlatform "Win32")
        elseif(${VCPKG_TARGET_ARCHITECTURE_LOWER} STREQUAL "x64")
            set(LTLPlatform "x64")
        elseif(${VCPKG_TARGET_ARCHITECTURE_LOWER} STREQUAL "arm")
            set(LTLPlatform "arm")
        elseif(${VCPKG_TARGET_ARCHITECTURE_LOWER} STREQUAL "arm64")
            set(LTLPlatform "arm64")
        else()
            message(WARNING "VC-LTL not load, Unknown Platform!!!")
            set(InternalSupportLTL "false")
        endif()
    elseif(DEFINED ENV{VSCMD_ARG_TGT_ARCH})
        #VSCMD_ARG_TGT_ARCH参数只有2017才有，因此兼容性更差
        message("VSCMD_ARG_TGT_ARCH = " $ENV{VSCMD_ARG_TGT_ARCH})
        string(TOLOWER "$ENV{VSCMD_ARG_TGT_ARCH}" VSCMD_ARG_TGT_ARCH_LOWER)
        if(${VSCMD_ARG_TGT_ARCH_LOWER} STREQUAL "x86")
            set(LTLPlatform "Win32")
        elseif(${VSCMD_ARG_TGT_ARCH_LOWER} STREQUAL "x64")
            set(LTLPlatform "x64")
        elseif(${VSCMD_ARG_TGT_ARCH_LOWER} STREQUAL "arm")
            set(LTLPlatform "arm")
        elseif(${VSCMD_ARG_TGT_ARCH_LOWER} STREQUAL "arm64")
            set(LTLPlatform "arm64")
        else()
            message(WARNING "VC-LTL not load, Unknown Platform!!!")
            set(InternalSupportLTL "false")
        endif()
    elseif(DEFINED ENV{LIB})
        #采用更加奇葩发方式，检测lib目录是否包含特定后缀
        message("LIB = $ENV{LIB}")

        string(TOLOWER "$ENV{LIB}" LTL_LIB_TMP)

        if("${LTL_LIB_TMP}" MATCHES "\\x64;")
            set(LTLPlatform "x64")
        elseif("${LTL_LIB_TMP}" MATCHES "\\x86;")
            set(LTLPlatform "Win32")
        elseif("${LTL_LIB_TMP}" MATCHES "\\arm;")
            set(LTLPlatform "arm")
        elseif("${LTL_LIB_TMP}" MATCHES "\\arm64;")
            set(LTLPlatform "arm64")
        elseif("${LTL_LIB_TMP}" MATCHES "\\lib;")
            #为了兼容VS 2015
            set(LTLPlatform "Win32")
        else()
            message(WARNING "VC-LTL not load, Unknown Platform!!!")
            set(InternalSupportLTL "false")
        endif()
    else()
        message(WARNING "VC-LTL not load, Unknown Platform!!!")
        set(InternalSupportLTL "false")
    endif()
endif()


if(NOT ${InternalSupportLTL} STREQUAL "false")

    #获取最佳TargetPlatform，一般默认值是 6.0.6000.0
    if(WindowsTargetPlatformMinVersion)
        # 故意不用 VERSION_GREATER_EQUAL，因为它在 3.7 才得到支持
        if(NOT ${WindowsTargetPlatformMinVersion} VERSION_LESS 10.0.19041.0)
            set(InternalLTLCRTVersion "10.0.19041.0")
        elseif(NOT ${WindowsTargetPlatformMinVersion} VERSION_LESS 10.0.10240.0)
            set(InternalLTLCRTVersion "10.0.10240.0")
        elseif(${LTLPlatform} STREQUAL "arm64")
            set(InternalLTLCRTVersion "10.0.10240.0")
        elseif(NOT ${WindowsTargetPlatformMinVersion} VERSION_LESS 6.2.9200.0)
            set(InternalLTLCRTVersion "6.2.9200.0")
        elseif(${LTLPlatform} STREQUAL "arm")
            set(InternalLTLCRTVersion "6.2.9200.0")
        elseif(NOT ${WindowsTargetPlatformMinVersion} VERSION_LESS 6.0.6000.0)
            set(InternalLTLCRTVersion "6.0.6000.0")
        elseif(${LTLPlatform} STREQUAL "x64")
            set(InternalLTLCRTVersion "5.2.3790.0")
        else()
            set(InternalLTLCRTVersion "5.1.2600.0")
        endif()
    else()
        #默认值
        if(${LTLPlatform} STREQUAL "arm64")
            set(InternalLTLCRTVersion "10.0.10240.0")
        elseif(${LTLPlatform} STREQUAL "arm")
            set(InternalLTLCRTVersion "6.2.9200.0")
        elseif(NOT ${SupportWinXP} STREQUAL "true")
            set(InternalLTLCRTVersion "6.0.6000.0")
        elseif(${LTLPlatform} STREQUAL "x64")
            set(InternalLTLCRTVersion "5.2.3790.0")
        else()
            set(InternalLTLCRTVersion "5.1.2600.0")
        endif()
    endif()

    if(${LTLPlatform} STREQUAL "arm64")
        set(InternalSupportLTL "ucrt")
    endif()
    if(${InternalSupportLTL} STREQUAL "true")
        if(${InternalLTLCRTVersion} VERSION_LESS 10.0.0.0)
            set(InternalSupportLTL "msvcrt")
        else()
            set(InternalSupportLTL "ucrt")
        endif()
    elseif(${InternalSupportLTL} STREQUAL "msvcrt")
        if(NOT ${InternalLTLCRTVersion} VERSION_LESS 10.0.0.0)
            set(InternalLTLCRTVersion "6.2.9200.0")
        endif()
    elseif(${InternalSupportLTL} STREQUAL "ucrt")
        if(${InternalLTLCRTVersion} VERSION_LESS 10.0.0.0)
            set(InternalLTLCRTVersion "10.0.10240.0")
        endif()
    endif()

    if (NOT EXISTS ${VC_LTL_Root}/TargetPlatform/${InternalLTLCRTVersion}/lib/${LTLPlatform})
        message(FATAL_ERROR "VC-LTL can't find lib files, please download the binary files from https://github.com/Chuyu-Team/VC-LTL5/releases/latest then continue.")
    endif()

    #打印VC-LTL图标
    message("################################################################################")
    message("#                                                                              #")
    message("#     8b           d8  ,ad8888ba,         88     888888888888 88               #")
    message("#     `8b         d8' d8\"'    `\"8b        88          88      88               #")
    message("#      `8b       d8' d8'                  88          88      88               #")
    message("#       `8b     d8'  88                   88          88      88               #")
    message("#        `8b   d8'   88          aaaaaaaa 88          88      88               #")
    message("#         `8b d8'    Y8,         \"\"\"\"\"\"\"\" 88          88      88               #")
    message("#          `888'      Y8a.    .a8P        88          88      88               #")
    message("#           `8'        `\"Y8888Y\"'         88888888888 88      88888888888      #")
    message("#                                                                              #")
    message("################################################################################")

    message("")

    #打印VC-LTL基本信息
    message(" VC-LTL Path          :" ${VC_LTL_Root})
    message(" VC-LTL Tools Version :" $ENV{VCToolsVersion})
    message(" ${InternalSupportLTL} Mode :" ${InternalLTLCRTVersion})
    message(" Platform             :" ${LTLPlatform})
    message("")

    set(VC_LTL_Include ${VC_LTL_Root}/TargetPlatform/header;${VC_LTL_Root}/TargetPlatform/${InternalLTLCRTVersion}/header)
    set(VC_LTL_Library ${VC_LTL_Root}/TargetPlatform/${InternalLTLCRTVersion}/lib/${LTLPlatform})

    #message("INCLUDE " $ENV{INCLUDE})
    #message("LIB " $ENV{LIB})

    #set( ENV{INCLUDE} ${VC_LTL_Include};$ENV{INCLUDE})
    #set( ENV{LIB} ${VC_LTL_Library};$ENV{LIB})


    #message("INCLUDE " $ENV{INCLUDE})
    #message("LIB " $ENV{LIB})
    if(VC_LTL_EnableCMakeInterface)
        add_library(VC_LTL INTERFACE)
        target_include_directories(VC_LTL SYSTEM BEFORE INTERFACE ${VC_LTL_Include})
        target_link_directories(VC_LTL INTERFACE ${VC_LTL_Library})
    else()
        include_directories(BEFORE SYSTEM ${VC_LTL_Include})
        link_directories(${VC_LTL_Library})
    endif()
    #message("INCLUDE " $ENV{INCLUDE})
    #message("LIB " $ENV{LIB})
endif()
