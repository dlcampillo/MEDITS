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
param MAX_TIME := 28 * 24;

param CRT symbolic in NODES;
param CSN symbolic in NODES;
param BCN symbolic in NODES;
param STOP_DAY symbolic in DAYS;

param START_TIME;
param END_TIME;

set EDGES := {i in NODES, j in NODES: (ZONE[i],ZONE[j]) in ADMISSIBLE_PAIRS and i<>j};

param lambda1;
param lambda2;

param M1;
param M2;

#
# VARIABLES
#

var X {EDGES} binary;
var D {NODES, DAYS} binary;

var W {NODES} >= 0, <= card(DAYS)*24;
var E {NODES} >= 0;

#
# OBJECTIVE
#

minimize OBJ: sum {(i,j) in EDGES} X[i,j] * (TRAVEL_TIME[i,j] + HAUL_TIME[i]) + sum {i in NODES} E[i];

#
# Restrictions
#
	
subject to R1 {j in NODES diff {BCN}}:
	sum {(j,i) in EDGES} X[j,i] = 1;
	
subject to R2 {j in NODES diff {CRT}}:
	sum {(i,j) in EDGES} X[i,j] = 1;
	
subject to R3 {i in NODES}:
	sum {d in DAYS} D[i,d] = 1;
	
subject to R4A {i in NODES}:
	sum {d in DAYS} START_TIME * d*D[i,d] <= W[i];
	
subject to R4B {i in NODES}:
	sum {d in DAYS} END_TIME * d*D[i,d] >= W[i];
	
subject to R5:
	W[CRT] = START_TIME;
	
subject to R6 {(j,BCN) in EDGES}:
	W[BCN] >= W[j];
	
subject to R7 {(i,j) in EDGES}:
	W[j] >= W[i] + HAUL_TIME[i] + TRAVEL_TIME[i,j] + E[j] - M1 * (1 - X[i,j]);
	
subject to R8 {(i,j) in EDGES}:
	KG_TIME[i] <= TRAVEL_TIME[i,j] + M2 * (1 - X[i,j]);
	
subject to R9:
	D[CSN,STOP_DAY] = 1;