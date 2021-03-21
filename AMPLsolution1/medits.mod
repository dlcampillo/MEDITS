#
# SETS
#

set NODES;
set STARTPOINT within NODES;
set ENDPOINT within NODES;
set ADMISSIBLE_PAIRS within {0..12, 0..12};

#
# PARAMETERS
#

param KG_TIME {NODES} >= 0;
param STRATUM {NODES} >= 0, integer;
param ZONE {NODES} >= 0, integer;
param LAT {NODES};
param LONG {NODES};
param DEPTH {NODES} >= 0;
param TRAVEL_TIME {NODES, NODES} >= 0;
param HAUL_TIME {NODES} >= 0;
param MAX_TIME := 28 * 24;
set EDGES := {i in NODES, j in NODES: (ZONE[i],ZONE[j]) in ADMISSIBLE_PAIRS and i<>j};

#
# VARIABLES
#

var X {NODES} binary;
var Y {EDGES} binary;
var U {NODES} >= 0;

#
# OBJECTIVE
#

maximize OBJ: sum {i in NODES} X[i];

#
# RESTRICTIONS
#

# MTZ Restrictions

subject to R3 {(i,j) in EDGES}:
	U[i] - U[j] + card(NODES) * (1 - Y[i,j]) >= 1;

# Total time restriction

subject to R4:
	sum {(i,j) in EDGES} Y[i,j] * (TRAVEL_TIME[i,j] + (HAUL_TIME[i] + KG_TIME[i])) <= MAX_TIME;
	
# Haul and travel time restriction

subject to R5 {(i,j) in EDGES}:
	KG_TIME[i] * Y[i,j] <= TRAVEL_TIME[i,j];
	
# If we include an edge in the tour, both endpoints of that edge must be active

subject to R6 {(i,j) in EDGES}:
	2 * Y[i,j] <= X[i] + X[j];
	
# The starting node must have an outoing edge on order 1 (and only one) and vice versa with
# the end node

subject to R7 {i in STARTPOINT}:
	sum {(i,j) in EDGES} Y[i,j] = 1;
	
subject to R10 {i in ENDPOINT}:
	sum {(j,i) in EDGES} Y[j,i] = 1;
	
# For every node, active or inactive, there must be at most one active incoming edge
# and one  active outgoing edge

subject to R11 {i in NODES}:
	sum {j in NODES: (i,j) in EDGES} Y[i,j] <= 1;
	
subject to R12 {i in NODES}:
	sum {j in NODES: (j,i) in EDGES} Y[j,i] <= 1;
	
# The rest of the active nodes must have an incoming and an outgoing edge

subject to R13 {i in NODES diff ({STARTPOINT} union {ENDPOINT})}:
	sum {j in NODES: (i,j) in EDGES} Y[i,j] >= X[i];
	
subject to R14 {i in NODES diff ({STARTPOINT} union {ENDPOINT})}:
	sum {j in NODES: (j,i) in EDGES} Y[j,i] >= X[i];