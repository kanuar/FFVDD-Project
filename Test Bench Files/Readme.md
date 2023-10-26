Test Benches for Router RTL Design

Overview:
These files includes test benches designed to verify and validate the functionality of a simplified router implemented. These test benches evaluate the performance of different router modules, including the Router FSM, Router Reg, Router Sync, and Router FIFO.

Router FSM Test Bench:
The Router FSM test bench assesses the decision-making and state-transition logic of the router's finite state machine. It verifies that the router correctly detects packets, manages data loading, handles errors, and ensures proper routing.

Router Reg Test Bench:
The Router Reg test bench focuses on the behavior of the router's registers. It validates the registration and handling of data, error flags, and packet validity, ensuring data integrity during routing.

Router Sync Test Bench:
In the Router Sync test bench, synchronization mechanisms within the router are examined. This test bench verifies that data channels are correctly synchronized to enable smooth data flow and routing decisions.

Router FIFO Test Bench:
The Router FIFO test bench evaluates the functionality of the data buffer. It ensures that data is temporarily stored and efficiently transferred between different router modules, avoiding data loss and ensuring data continuity.

While we can always improve on the verification aspect, we have tested this complicated design with this testbench to see if the basic functionality can be observed.
