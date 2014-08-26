find_package(GreatCMakeCookOff NO_MODULE PATHS ${cookoff_path} REQUIRED)
initialize_cookoff()

include(PythonPackageLookup)
include(EnvironmentScript)
include(MakoFiles)

set(LOCAL_PYTHON_EXECUTABLE "${PROJECT_BINARY_DIR}/localpython.sh")
create_environment_script(
    EXECUTABLE "${PYTHON_EXECUTABLE}"
    PATH "${LOCAL_PYTHON_EXECUTABLE}"
    PYTHON
)
add_to_python_path("${EXTERNAL_ROOT}/python")

lookup_python_package(mako REQUIRED)
find_program(mako_SCRIPT mako-render HINT "${EXTERNAL_ROOT}/python")

file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/__init__.mako.py"
    "import other\n"
    "i = 0\n"
    "% for a in ['hello', 'world']:\n"
    "assert '\${a}' == 'hello world'.split()[\${loop.index}]\n"
    "i += 1\n"
    "% endfor\n"
    "assert i == 2\n"
    "assert other.i == 8\n"
)
file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/other.mako.py"
    "i = 5\n"
    "% for a in ['hello', 'despicable', 'world']:\n"
    "assert '\${a}' == 'hello despicable world'.split()[\${loop.index}]\n"
    "i += 1\n"
    "% endfor\n"
    "assert i == 8\n"
)

set(destination "${CMAKE_CURRENT_BINARY_DIR}/python_package/makoed")
add_custom_target(makoed ALL)
mako_files(makoed *.mako.py
    DESTINATION "${destination}"
    OUTPUT_FILES output
)

list(LENGTH output i)
if(NOT i EQUAL 2)
    message(FATAL_ERROR "Expected 2 output files. Got ${output}.")
endif()

foreach(filename other.py __init__.py)
    set(filename "${destination}/${filename}")
    list(FIND output "${filename}" found)
    if(found LESS 0)
        message(FATAL_ERROR "${filename} not in output files")
    endif()
endforeach()

install(FILES ${output} DESTINATION
    "${CMAKE_CURRENT_BINARY_DIR}/install")