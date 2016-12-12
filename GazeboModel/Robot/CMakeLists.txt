cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

find_package(roscpp)
find_package(gazebo REQUIRED)
include_directories(${GAZEBO_INCLUDE_DIRS})
link_directories(${GAZEBO_LIBRARY_DIRS})
include_directories(${roscpp_INCLUDE_DIRS})
link_directories(${roscpp_LIBRARY_DIRS})
include_directories(${rosconsole_INCLUDE_DIRS})
link_directories(${rosconsole_LIBRARY_DIRS})
list(APPEND CMAKE_CXX_FLAGS "${GAZEBO_CXX_FLAGS}")

add_library(SetJoints SHARED SetJoints.cc)
target_link_libraries(SetJoints ${GAZEBO_LIBRARIES} ${Boost_LIBRARIES} ${roscpp_LIBRARIES} ${rosconsole_LIBRARIES})

include_directories(include ${catkin_INCLUDE_DIRS} ${roscpp_INCLUDE_DIRS})

add_executable(talker src/talker.cpp)
target_link_libraries(talker ${catkin_LIBRARIES}${roscpp_LIBRARIES}${rosconsole_LIBRARIES})
add_dependencies(talker beginner_tutorials_generate_messages_cpp)
