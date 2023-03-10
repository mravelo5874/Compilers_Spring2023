# AddLLVM needs these
set(LLVM_RUNTIME_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/bin)
set(LLVM_LIBRARY_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lib)

include(HandleLLVMOptions) # important: matches compiler flags to LLVM/Clang build
include(AddLLVM)

add_llvm_library( LLVMLoopAnalysis MODULE
  LoopAnalysis.cpp

  PLUGIN_TOOL
  opt
  )