# Horse Store 

## A simple store/ horse Store contract  

# To run the huff file 
```bash
 huffc src/horseStore_V1/horseStore.huff -b
```

# to get the runtime code of huff file 
```bash
  huffc src/horseStore_V1/horseStore.huff --bin-runtime 
```

# To run yul file 
```bash
 solc --strict-assembly --optimize --optimize-runs 20000 ./yul/horseStoreYul.yul 
```

# to get the bytecode of the yul file 
```bash
 solc --strict-assembly --optimize --optimize-runs 20000 ./yul/horseStoreYul.yul --bin 
```