This Folder contains the Design codes for this 1X3 network router. It is systematically ordered such that each file in the folder represents a certain module in the overall design of the router. Here is the implementation:
Router Design Implementation

Overview:
The router is a hardware component responsible for routing data packets from a source to a destination. This design is a simplified representation of a router for educational and verification purposes.

Key Modules:
Router FSM (Finite State Machine): 
The heart of the router's decision-making process. It manages states like packet detection, data loading, and error checking. The FSM orchestrates data flow and routing decisions.

Router Reg: 
This module simulates registers within the router. It holds data, controls, and state information to facilitate packet routing.

Router Sync: 
Synchronization is critical in a router. This module handles synchronization between data channels, ensuring proper data flow.

Router FIFO (First-In-First-Out): 
The FIFO module acts as a data buffer. It stores data temporarily, allowing controlled data transfer between different router modules.

State Machine Logic:
The Router FSM module employs a finite state machine to make routing decisions. It considers factors like data availability, FIFO status, and packet validity to make decisions. States include packet detection, data loading, and error handling.

Data Buffer:
The Router FIFO serves as a data buffer. It ensures a smooth flow of data between the source and destination channels. Data is temporarily stored in this FIFO, preventing data loss and ensuring orderly delivery.

Synchronization:
The Router Sync module handles data synchronization, an essential aspect of any router. It ensures that data is correctly aligned for routing.

Register Simulation:
The Router Reg module simulates the router's registers. It manages data, flags, and error checking, contributing to the router's decision-making process.

Error Handling:
The design includes error-checking mechanisms, like parity checks, to ensure data integrity during routing.

The main purpose for write separte modules for each part of the router is to be able to test and check the working of the said components individually.
