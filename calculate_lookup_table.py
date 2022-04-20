#!/usr/bin/env python3
lookup_table = {}
for i in range(0, 256):
	lookup_table[str(1<<i)] = i
for key in lookup_table:
	print("lookupTable[uint256(" + key + ")] = " + str(lookup_table[key]) + ";")