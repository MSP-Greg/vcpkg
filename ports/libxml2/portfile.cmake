vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF 2b998a4ffbdfea04fc6a620721abc690a15743af
    SHA512 3be718db307a20d973031caaacd2fb0834ef4bf18d89be9e6f69fccbc829d2aa3b99d8bc009b6b13f7795819d55290cbe6d9ff46ba37eefe0a7efe6f56ba23b9
    HEAD_REF master
    PATCHES
        disable-docs.patch
        fix_cmakelist.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "ftp" LIBXML2_WITH_FTP
        "http" LIBXML2_WITH_HTTP
        "iconv" LIBXML2_WITH_ICONV
        "legacy" LIBXML2_WITH_LEGACY
        "lzma" LIBXML2_WITH_LZMA
        "zlib" LIBXML2_WITH_ZLIB
        "tools" LIBXML2_WITH_PROGRAMS
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBXML2_WITH_TESTS=OFF
        -DLIBXML2_WITH_HTML=ON
        -DLIBXML2_WITH_C14N=ON
        -DLIBXML2_WITH_CATALOG=ON
        -DLIBXML2_WITH_DEBUG=ON
        -DLIBXML2_WITH_ISO8859X=ON
        -DLIBXML2_WITH_ICU=OFF # Culprit of linkage issues? Solving this is probably another PR
        -DLIBXML2_WITH_MEM_DEBUG=OFF
        -DLIBXML2_WITH_MODULES=ON
        -DLIBXML2_WITH_OUTPUT=ON
        -DLIBXML2_WITH_PATTERN=ON
        -DLIBXML2_WITH_PUSH=ON
        -DLIBXML2_WITH_PYTHON=OFF
        -DLIBXML2_WITH_READER=ON
        -DLIBXML2_WITH_REGEXPS=ON
        -DLIBXML2_WITH_RUN_DEBUG=OFF
        -DLIBXML2_WITH_SAX1=ON
        -DLIBXML2_WITH_SCHEMAS=ON
        -DLIBXML2_WITH_SCHEMATRON=ON
        -DLIBXML2_WITH_THREADS=ON
        -DLIBXML2_WITH_THREAD_ALLOC=OFF
        -DLIBXML2_WITH_TREE=ON
        -DLIBXML2_WITH_VALID=ON
        -DLIBXML2_WITH_WRITER=ON
        -DLIBXML2_WITH_XINCLUDE=ON
        -DLIBXML2_WITH_XPATH=ON
        -DLIBXML2_WITH_XPTR=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libxml2")
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES xmllint xmlcatalog AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(_file "${CURRENT_PACKAGES_DIR}/include/libxml2/libxml/xmlexports.h")
    file(READ "${_file}" _contents)
    string(REPLACE "#ifdef LIBXML_STATIC" "#undef LIBXML_STATIC\n#define LIBXML_STATIC\n#ifdef LIBXML_STATIC" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

file(COPY "${CURRENT_PACKAGES_DIR}/include/libxml2/" DESTINATION "${CURRENT_PACKAGES_DIR}/include") # TODO: Fix usage in all dependent ports hardcoding the wrong include path.

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/xml2Conf.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/xml2Conf.sh")

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
