Notes for testing(Fuzzing):
1) understand the invariant (The property of the code that should never change and always hold)
2) write a fuzz test for the invariant 

StateFull vs StateLess Fuzzing:
--> In Stateless fuzzing the state of the previous run is discarded for every new run and in StateFull fuzzing the final state of the previous fuzz run is used as the starting state for the current fuzz test 


Important Points in Audits:
1) See and understand what the invariants are.....
2) Write functions tests to execute them



Points About ABI (encode,packed etc):
1) 