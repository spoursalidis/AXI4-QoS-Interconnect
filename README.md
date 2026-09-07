# AXI4-QoS-Interconnect
This module implements a 8-to-1 AXI4 Quality-of-Service Interconnect. <br>

Arbibration is decided based on the ARQOS/AWQOS signals of the AXI4 protocol, since they
are recommended to be used as priority indicators for the associated write or read requests,
where a higher value indicates a higher priority request.

## Acknowledgments
Parts of the implementation have been sourced from the Open Logic FPGA Standard Library.
This source was specifically utilized to implement correct pipelining across all AXI Full channels (AR, R, AW, W, B), effectively resolving critical timing issues encountered after the place and route phase.

* **Source Repository:** [Open Logic - A VHDL Standard* Library](https://github.com/open-logic/open-logic.git)
* **License Note:** The sourced files retain their original PSI HDL / LGPL license guidelines, while the rest of the proprietary codebase in this repository remains under its own independent terms.
