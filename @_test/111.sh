export cmr_CMAKE_DIR="/home/work/apps/cmake/cmake-3.21.2-linux-x86_64"
export cmr_CMAKE_CMD="${cmr_CMAKE_DIR}/bin/cmake"

#cmr_LIB_PARAMS=-DCMAKE_GENERATOR="Unix Makefiles"
#cmr_LIB_PARAMS=cmr_CMAKE_GENERATOR="Ninja"

cmr_LIB_PARAMS=(
  -DCMAKE_GENERATOR="Unix Makefiles"
  -Dcmr_CMAKE_GENERATOR_2="Unix_2 Makefiles_2"
)

cmr_LIB_PARAMS+=(
  -Dcmr_CMAKE_GENERATOR_3="Unix_3 Makefiles_3"
  -Dcmr_CMAKE_GENERATOR_4="Unix_4 Makefiles_4"
)

cd ./build
${cmr_CMAKE_CMD} /home/luka/projects/Feographia/Feographia/libs/LibCMaker/samples \
  "${cmr_LIB_PARAMS[@]}"
