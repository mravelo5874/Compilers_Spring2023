#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace
{
    struct LoopAnalysis : public FunctionPass
    {
        static char ID;
        LoopAnalysis() : FunctionPass(ID) {}

        bool runOnFunction(Function &F) override
        {
            errs() << "Hello: ";
            errs().write_escaped(F.getName()) << '\n';
            return false;
        }
    };
}

char LoopAnalysis::ID = 0;
static RegisterPass<LoopAnalysis> X("mar7655-loop-props", "LOOP ANALYSIS PASS", false /*Only looks at CFG*/, false /*Analysis Pass*/);