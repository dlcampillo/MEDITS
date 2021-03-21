#
# SETS
#

set NODES;
set ADMISSIBLE_PAIRS within {0..12, 0..12};
set STARTPOINT;
set ENDPOINT;

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

param START := 141;
param END := 201;

set EDGES := {i in NODES, j in NODES: (ZONE[i],ZONE[j]) in ADMISSIBLE_PAIRS and i<>j};

#
# Variables
#

var T {NODES union {END}} >= 0;
var X {EDGES} binary;


#
# Objective
#

minimize OBJ: T[END];

#
# Restrictions
#

subject to R1 {(START,i) in EDGES}:
	T[i] - TRAVEL_TIME[START, i] * X[START, i] >= 0;
	
subject to R2 {i in NODES, t in 1..28}:
	T[i] >= 8 * t;

subject to R3 {i in NODES, t in 1..28}:
	T[i] <= 17 * t;
	
subject to R4 {(i,j) in EDGES, s in 1..28, t in 1..28}:
	T[i] - T[j] + (17*s - 8*t + TRAVEL_TIME[i,j]) * X[i,j] <= 17*s - 8*t;
	
subject to R5 {i in NODES}:
	sum {(i,j) in EDGES} X[i,j] = 1;
	
subject to R6 {i in NODES}:
	sum {(j,i) in EDGES} X[j,i] = 1;
	
subject to R7 {(i,START) in EDGES}:
	T[i] + TRAVEL_TIME[i, START] <= T[END];
