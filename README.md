# The FPGA Multi-Agent Fabric Integration Architecture Project
## The MAFIA Project

This project aims to design a SOC Tile based mesh fabric that can incorporate various functionalities, such as RISCV mini-cores, big-cores, hardware accelerators, and IO devices like UART, keyboard, VGA, DE10-Lite FPGA IO, and more.


## Getting Started
To see your build and run options, run the following command:  
```python build.py -h ```  
For any issue please see here: [fpga_mafia/discussions](https://github.com/amichai-bd/fpga_mafia/discussions/101)  
Please add your question in the comment section of the discussion

## Prerequisite
Before you start, make sure you have the following tools and software installed:
- [RISCV gcc releases](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/) & [install](https://xpack.github.io/riscv-none-embed-gcc/install/), a Windows gcc for RISCV ISA.  
- [Intel design SW for windows](https://www.intel.com/content/www/us/en/software-kit/660907/intel-quartus-prime-lite-edition-design-software-version-20-1-1-for-windows.html) , modelsim + quartus + MAX10 (de10-lite). used to compile, simulate & load to FPGA the HW systemverilog design.  
### Recommendations
To make your experience smoother, we recommend installing the following tools:
- [GitBash](https://gitforwindows.org/), a Windows version of Git that includes a "Unix-like" shell.  
- [Visual Studio Code](https://code.visualstudio.com/download), a code editor that supports many programming languages.  


# Project overview
- The final project for 4th-year Electrical Engineering and Computer Engineering students at Bar-Ilan University and the Technion in Israel  
- Goal: design a System-on-a-Chip (SOC) tile-based mesh fabric that integrates various IPs & functionalities  

Main Components:  
- 4-way Router  
- 3-stage Mini Core RV32I compatible   
- 7-stage Big Core RV32IM CSR compatible with MMIO (VGA, uart, FPGA IO, PS2 Keyboard)  
- Memory Subsystem with L1 Instruction and Data Cache and a Memory Controller  

Software Stack to run on SOC:
- Simple RISCV Embeded OS
- Software library for VGA graphical capabilities
- Software library for accessing the FPGA MMIO and special control registers
- Software examples demonstrating utilization of many cores for distributed calculations and parallel computation

The diagram below provides a general idea of the project's architecture.   
![image](https://user-images.githubusercontent.com/81047407/217345069-21aef258-084b-44b3-b776-e9740aad8e88.png)




## Inspiration Behind the Project:  
This project draws inspiration from some of the most innovative players in the field of computing.  
These include:  
- [Tesla: DOJO](https://www.tesla.com/AI) | [Watch the video on Youtube](https://www.youtube.com/watch?v=DSw3IwsgNnc)  
- [Tenstorrent: Wormhole & more](https://tenstorrent.com/) | [Watch the video on Youtube](https://www.youtube.com/watch?v=32CRYenTcdw)  
- [Esperanto: ET-SoC-1](https://www.esperanto.ai/)  | [Watch the video on Youtube](https://www.youtube.com/watch?v=5foT3huJ_Gg)  
Each of these entities has pushed the boundaries of what's possible with modern computing, and this project aims to continue that legacy by offering a unique, highly-integratable mesh architecture that can support a wide range of agents.  

## Common Issues:

``` ModuleNotFoundError: No module named 'termcolor' ```  
  To resolve this issue, run the following command:  
> pip install termcolor


``` 'riscv-none-embed-gcc.exe' is not recognized as an internal or external command ```  
To resolve this issue, make sure the following line is added to your `~/.bashrc` file:  
> export PATH=$PATH:/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin   
Then run ``` source ~/.bashrc ```   


Additionally, make sure the following aliases are present in your `~/.aliases` file:
> alias rv_gcc='/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-gcc.exe'  
> alias rv_objcopy='/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-objcopy.exe'  
> alias rv_objdump='/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-objdump.exe'    

Then run ``` source ~/.aliases ```    



### fast access
python build.py -h
python build.py -proj_name 'big_core' -debug -tests alive -app 
