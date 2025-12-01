// g++ ot.cpp -o ot_exp -I. -IOpenTimer lib/libOpenTimer.a && ./ot_exp
#include <../OpenTimer/ot/timer/timer.hpp>                     // top-level header to include

int main(int argc, char *argv[]) {
  ot::Timer timer;                                // create a timer instance (thread-safe)
  std::string designDir = "/home/a1023/STA2/bench/example/simple/";

  timer.read_celllib(designDir + "osu018_stdcells.lib", std::nullopt)  // read the library (O(1) builder)
       .read_verilog(designDir + "simple.v")                  // read the verilog netlist (O(1) builder)
       .read_spef(designDir + "simple.spef")                  // read the parasitics (O(1) builder)
       .read_sdc(designDir + "simple.sdc")                    // read the design constraints (O(1) builder)
       .update_timing();                          // update timing (O(1) builder)

  if(auto tns = timer.report_tns(); tns) std::cout << "TNS: " << *tns << '\n';  // (O(N) action)
  if(auto wns = timer.report_wns(); wns) std::cout << "WNS: " << *wns << '\n';  // (O(N) action)
  
  timer.dump_timer(std::cout);                    // dump the timer details (O(1) accessor)
  
  auto paths = timer.report_timing(INT16_MAX);
  for(size_t i=0; i<paths.size(); ++i) {
    std::cout << "Path " << i << ": " << paths[i] << '\n';
  }

  return 0;
}