#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/LoopInfo.h"
#include <map>

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
            LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
            std::string func_name = F.getName().str();

            errs() << "func: " << func_name << "\n";

            for (LoopInfo::iterator iter = LI.begin(), end = LI.end(); iter != end; ++iter)
            {
                Loop *L = *iter;

                std::vector<Loop*> subLoopAll = L->getSubLoops();
                Loop::iterator j, f;

                errs() << "loop: " << L->getNumBlocks() << ", subloops: " << subLoopAll.size() << "\n";

                //get_loop_data(L, func_name, 0);
            }

            return false;

            // for (LoopInfo::iterator looper = LI.begin(), l_end = LI.end(); looper != l_end; ++looper)
            // {
            //     Loop* l = *looper;
            //     int blocks = 0;
            //     for (Loop::block_iterator blocker = l->block_begin(), b_end = l->block_end(); blocker != b_end; ++blocker)
            //     {
            //         blocks++;
            //     }

            //     errs() << "\tloop: " << l->getName() << ", blocks: " << blocks << " \n";
            //     get_loop_data(*looper, func_name, 0);
            // }

            /*
            for (BasicBlock &BB : F)
            {
                for (Instruction &II : BB) 
                {
                    for (User::op_iterator o_iter = II.op_begin(), o_end = II.op_end(); o_iter != o_end; ++o_iter)
                    {
                        //errs() << o_iter->() << "\n";
                    }
                }
            }
            */
            
            // std::map<std::string, int> op_counter;
            // int loop_count = 0;

            // for (Function::iterator bb = F.begin(), bb_end = F.end(); bb != bb_end; ++bb)
            // {
            //     for (BasicBlock::iterator i = bb->begin(), i_end = bb->end(); i != i_end; ++ i)
            //     {
            //         // if number of successors is greater than 1, loop found
            //         if (i->getNumSuccessors() > 1)
            //         {
            //             loop_count++;
            //         }

            //         std::string op = i->getOpcodeName();
            //         if (op_counter.find(op) == op_counter.end())
            //         {
            //             op_counter[op] = 1;
            //         }
            //         else
            //         {
            //             op_counter[op] += 1;
            //         }
            //     }
            // }

            // errs() << "loop count: " << loop_count << "\n";
            // std::map <std::string, int>::iterator iter = op_counter.begin();
            // std::map <std::string, int>::iterator end = op_counter.end();
            // while (iter != end)
            // {
            //     errs() << iter->first << ": " << iter->second << "\n";
            //     iter++;
            // }
            // errs() << "\n";
            // op_counter.clear();
        }

        void get_loop_data(Loop *L, std::string func_name, unsigned loop_depth)
        {
            // count basic blocks
            unsigned num_blocks = 0;
            Loop::block_iterator bb;
            for (bb = L->block_begin(); bb != L->block_end(); ++bb)
            {
                num_blocks++;
            }

            // recurse into sub loops
            unsigned num_sub_loops = 0;
            std::vector<Loop*> sub_loops = L->getSubLoops();
            Loop::iterator iter, end;
            for (iter = sub_loops.begin(), end = sub_loops.end(); iter != end; ++iter)
            {
                get_loop_data(*iter, func_name, loop_depth + 1);
                num_sub_loops++;
            }

            // print loop info
            errs() << "\t"; // TODO remove this later
            errs() << loop_counter << ": ";
            errs() << "func=" << func_name << ", ";
            errs() << "depth=" << loop_depth << ", ";
            errs() << "subLoops=" << num_sub_loops << ", ";
            errs() << "BBs=" << num_blocks << ", ";
            errs() << "instrs=" << "NULL" << ", ";
            errs() << "atomics=" << "NULL" << ", ";
            errs() << "branches=" << "NULL" << "\n";
            loop_counter++;
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
