#
# SETS
#

set NODES;
set ADMISSIBLE_PAIRS within {0..12, 0..12};
set DAYS ordered;

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
param MAX_TIME := card(DAYS) * 24;

param CRT symbolic in NODES;
param CSN symbolic in NODES;
param BCN symbolic in NODES;
param STOP_DAY symbolic in DAYS;

param START_TIME;
param END_TIME;

param lambda1;
param lambda2;

set EDGES := {i in NODES, j in NODES: (ZONE[i],ZONE[j]) in ADMISSIBLE_PAIRS and i<>j};

param M1;

set ZONES;

set AREAS {1..3};

set STRATUMS;

param MIN_HAULS {1..3, STRATUMS};

param MIN;

#
# VARIABLES
#

var X {EDGES} binary;
var D {NODES, DAYS} binary;

var W {NODES} >= 0;

#
# OBJECTIVE
#

maximize OBJ: lambda1 * sum {i in NODES, d in DAYS} D[i,d] - lambda2 * sum{(i,j) in EDGES} X[i,j] * TRAVEL_TIME[i,j];

#
# Restrictions
#
	
subject to R1:
	sum {(CRT,i) in EDGES} X[CRT,i] = 1;
	
subject to R2:
	sum {(i,BCN) in EDGES} X[i,BCN] = 1;
	
subject to R3 {i in NODES}:
	sum {d in DAYS} D[i,d] <= 1;
	
subject to R4 {i in NODES}:
	sum {d in DAYS} (START_TIME + 24 * (d-1)) * D[i,d] <= W[i];
	
subject to R5 {i in NODES}:
	sum {d in DAYS} (END_TIME + 24 * (d-1)) * D[i,d] >= W[i];
	
subject to R6:
	W[CRT] = START_TIME;
	
subject to R7 {(j,BCN) in EDGES}:
	W[BCN] >= W[j];
	
subject to R8:
	W[BCN] <= MAX_TIME;
	
subject to R9 {(i,j) in EDGES}:
	W[j] >= W[i] + HAUL_TIME[i] + TRAVEL_TIME[i,j] - M1 * (1 - X[i,j]);
	
subject to R10 {(i,j) in EDGES}:
	W[j] >= W[i] + HAUL_TIME[i] + KG_TIME[i] - M1 * (1 - X[i,j]);
	
subject to R11 {(i,j) in EDGES}:
	2 * X[i,j] <= sum {d in DAYS} D[i,d] + sum {d in DAYS} D[j,d];
	
subject to R12 {i in NODES diff {CRT, BCN}}:
	sum {(i,j) in EDGES} X[i,j] >= sum {d in DAYS} D[i,d];
	
subject to R13 {i in NODES diff {CRT, BCN}}:
	sum {(j,i) in EDGES} X[j,i] >= sum {d in DAYS} D[i,d];
	
subject to R14 {i in NODES diff {CRT, BCN}}:
	sum {(i,j) in EDGES} X[i,j] <= 1;
	
subject to R15 {i in NODES diff {CRT, BCN}}:
	sum {(j,i) in EDGES} X[j,i] <= 1;
		
subject to R16:
	D[CSN,STOP_DAY] = 1;

subject to R17 {z in ZONES}:
	sum {i in NODES, d in DAYS: ZONE[i] = z} D[i,d] >= MIN;
		
#subject to R17 {a in 1..3, s in STRATUMS}:
#	sum {i in NODES, d in DAYS: (ZONE[i] in AREAS[a]) and (STRATUM[i] = s)} D[i,d] >= MIN_HAULS[a,s];