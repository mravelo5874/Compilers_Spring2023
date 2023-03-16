#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/LoopInfo.h"
#include <assert.h>

using namespace llvm;

namespace
{
    struct MyLoopAnalysis : public FunctionPass
    {
        static char ID;
        MyLoopAnalysis() : FunctionPass(ID) {}

        int loop_counter = 0;

        void getAnalysisUsage(AnalysisUsage &AU) const override
        {
            AU.addRequired<LoopInfoWrapperPass>();
            AU.addPreserved<LoopInfoWrapperPass>();
            AU.setPreservesAll();
        }

        virtual bool runOnFunction(Function &F)
        {
            // get all loops and function name
            LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
            std::string func_name = F.getName().str();

            // iterate through every loop to get loop data
            for (LoopInfo::iterator iter = LI.begin(), end = LI.end(); iter != end; ++iter)
            {
                Loop *L = *iter;
                print_loop_data(L, func_name, 0);
            }

            // return false -> no changes
            return false;
        }

        std::pair<int, int> print_loop_data(Loop* L, std::string func_name, int loop_depth)
        {
            std::vector<BasicBlock*> blocks = L->getBlocksVector();
            std::vector<Loop*> sub_loops = L->getSubLoops();

            // count basic blocks
            int num_sub_loops = 0;
            int num_blocks = blocks.size();
            int num_inst = 0;
            int num_atom = 0;
            int num_branch = 0;
            
            // count branches, instructions, and atomics
            for (int i = 0; i < num_blocks; i++)
            {
                BasicBlock* block = blocks[i];
                BasicBlock::iterator iter, end;
                for (iter = block->begin(), end = block->end(); iter != end; ++iter)
                {
                    // instructions
                    num_inst++;
                    // branches
                    if (isa<BranchInst>(iter) || isa<SwitchInst>(iter) || isa<IndirectBrInst>(iter)) num_branch++;
                    // atomics
                    if (iter->isAtomic()) num_atom++;
                }
            }
            
            // recurse into sub loops
            int inner_blocks = 0;
            int inner_branches = 0;
            Loop::iterator iter, end;
            for (iter = sub_loops.begin(), end = sub_loops.end(); iter != end; ++iter)
            {
                std::pair<int, int> blocks_branches = print_loop_data(*iter, func_name, loop_depth + 1);
                inner_blocks += blocks_branches.first;
                inner_branches += blocks_branches.second;
                num_sub_loops++;
            }

            // make sure inner_blocks is correctly calculated
            assert (inner_blocks < num_blocks);

            // compute loop atributes
            std::string contains_sub_loops = (num_sub_loops == 0 ? "false" : "true");
            int my_blocks = num_blocks - inner_blocks;
            int my_branches = num_branch - inner_branches;

            // errs() << "blocks: " << num_blocks << ", ";
            // errs() << "inner_blocks: " << inner_blocks << ", ";
            // errs() << "my_blocks: " << my_blocks << ", \t";

            // print loop info
            errs() << loop_counter << ": ";
            errs() << "func=" << func_name << ", ";
            errs() << "depth=" << loop_depth << ", ";
            errs() << "subLoops=" << contains_sub_loops << ", ";
            errs() << "BBs=" << my_blocks << ", ";
            errs() << "instrs=" << num_inst << ", ";
            errs() << "atomics=" << num_atom << ", ";
            errs() << "branches=" << my_branches << "\n";
            loop_counter++;

            // return blocks and branches
            return std::make_pair(num_blocks, num_branch);
        }
    }; // end of struct
} // end of namespace

char MyLoopAnalysis::ID = 0;
static RegisterPass<MyLoopAnalysis> X("loop-props", "mar7655-LoopAnalysis", false, false);

/*
For each loop, print a line to std error in following format:

    <ID>: func=<str>, depth=<num>, subLoops=<str>, BBs=<num>, instrs=<num>, atomics=<num>, branches=<num>

1. function:        
        name of the function containing this loop
2. loop depth:      
        0 if not nested; otherwise, it is 1 mroe than that of the loop in which it is nested in
3. nested loops:    
        constains nested loops?
4. num top-level basic blocks: 
        count all basic blocks in loop but not in any of its nested loops
5. num instructions:
        count all instructions in loop including those in nested loops
6. num atomic operations:
        count all atomic operations including those in its nested loops
7. num top-level branch instructions:
        count branch instructions including those in its nested loops
*/
