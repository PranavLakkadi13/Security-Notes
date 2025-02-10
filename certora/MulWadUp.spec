// the rules/lemmas are used to check the correctness of the function


methods {
    function mulWadUp(uint256 x, uint256 y) external returns uint256 envfree ; 
    function sqrt(uint256 x) external returns uint256 envfree;
    function uniSqrt(uint256 x) external returns uint256 envfree;
}

// this is more like a constant value as 1e18 is not recogniseable in CVL
definition WAD() returns uint256 = 1000000000000000000;

// this is the test function 
rule check_testMulWadUpFuzz(uint256 x, uint256 y) {
    // The assert_uint256 function is used to convert the result to uint 
    // mathint is a number of any size that can never over or under flow 
    // max_uint256 is the maximum value of uint256 but of type mathint so we use the assert_uint256 to convert it to uint256
    require(x == 0 || y == 0 || y <= assert_uint256(max_uint256 / x));
    uint256 result = mulWadUp(x, y);
    mathint expected = x * y == 0 ? 0 : (x * y - 1) / WAD() + 1;
    assert(result == assert_uint256(expected));
}



// invariant is a special type that declares the invariant property of the contract
// the above rule can be written as the following invariant
invariant check_mulWadUpInvariant(uint256 x, uint256 y) 
    mulWadUp(x, y) == assert_uint256(x * y == 0 ? 0 : (x * y - 1) / WAD() + 1) { // invariant property
        preserved {
            // the invariant should hold as long as the invariant property is preserved 
            require(x == 0 || y == 0 || y <= assert_uint256(max_uint256 / x)); 
        }
    }
    

invariant check_sqrtInvariant(uint256 x) 
    sqrt(x) == uniSqrt(x) { // invariant property
        preserved {
            // the invariant should hold as long as the invariant property is preserved 
            require(x >= 0);
        }
    }