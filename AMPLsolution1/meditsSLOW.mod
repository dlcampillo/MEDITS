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
param MAX_HAULS := 200;
set ORDER := 1..MAX_HAULS;
set EDGES := {i in NODES, j in NODES: (ZONE[i],ZONE[j]) in ADMISSIBLE_PAIRS and i<>j};

#
# VARIABLES
#

var X {NODES, ORDER} binary;
var Y {EDGES, ORDER} binary;
var U {NODES, ORDER} >= 0;

#
# OBJECTIVE
#

maximize OBJ: sum {i in NODES, k in ORDER} X[i,k];

#
# RESTRICTIONS
#

# MTZ Restrictions

subject to R3 {(i,j) in EDGES, k in ORDER}:
	U[i,k] - U[j,k] + card(NODES) * (1 - Y[i,j,k]) >= 1;

# Total time restriction

subject to R4:
	sum {(i,j) in EDGES, k in ORDER} Y[i,j,k] * (TRAVEL_TIME[i,j] + (HAUL_TIME[i] + KG_TIME[i])) <= MAX_TIME;
	
# Haul and travel time restriction

subject to R5 {(i,j) in EDGES, k in ORDER}:
	KG_TIME[i] * Y[i,j,k] <= TRAVEL_TIME[i,j];
	
# If we include an edge in the tour, both endpoints of that edge must be active

subject to R6 {(i,j) in EDGES, k in ORDER diff {MAX_HAULS}}:
	2 * Y[i,j,k] <= X[i,k] + X[j,k+1];
	
# The starting node must have an outoing edge on order 1 (and only one) and vice versa with
# the end node

subject to R7 {i in STARTPOINT}:
	sum {(i,j) in EDGES} Y[i,j,1] = 1;
	
subject to R9 {i in STARTPOINT, k in ORDER diff {1}}:
	sum {(i,j) in EDGES} Y[i,j,k] = 0;
	
subject to R10 {i in ENDPOINT}:
	sum {(j,i) in EDGES, k in ORDER} Y[j,i,k] = 1;
	
# For every node, active or inactive, there must be at most one active incoming edge
# and one  active outgoing edge

subject to R11 {i in NODES, k in ORDER}:
	sum {j in NODES: (i,j) in EDGES} Y[i,j,k] <= 1;
	
subject to R12 {i in NODES, k in ORDER}:
	sum {j in NODES: (j,i) in EDGES} Y[j,i,k] <= 1;
	
# The rest of the active nodes must have an incoming and an outgoing edge

subject to R13 {i in NODES diff {STARTPOINT} union {ENDPOINT}, k in ORDER diff {1}}:
	sum {j in NODES: (i,j) in EDGES} Y[i,j,k] >= X[i,k];
	
subject to R14 {i in NODES diff {STARTPOINT} union {ENDPOINT}, k in ORDER diff {1}}:
	sum {j in NODES: (j,i) in EDGES} Y[j,i,k-1] >= X[i,k];

# We arrive at the nodes at working time (from 8 to 17)

subject to R15 {k in ORDER diff {1} union {MAX_HAULS}}:
	sum {(i,j) in EDGES, l in 1..k} Y[i,j,l] * (HAUL_TIME[i] + KG_TIME[i] + TRAVEL_TIME[i,j]) mod 24 <= 17;
	
subject to R16 {k in ORDER diff {1} union {MAX_HAULS}}:
	sum {(i,j) in EDGES, l in 1..k} Y[i,j,l] * (HAUL_TIME[i] + KG_TIME[i] + TRAVEL_TIME[i,j]) mod 24 >= 8;