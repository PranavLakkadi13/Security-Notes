// the rules/lemmas are used to check the correctness of the function


methods {
    function mulWadUp(uint256 x, uint256 y) external returns uint256 envfree ; 
}

// this is more like a constant value as 1e18 is not recogniseable in CVL
definition WAD() returns uint256 = 1000000000000000000;

rule check_testMulWadUpFuzz(uint256 x, uint256 y) {
    // The assert_uint256 function is used to convert the result to uint 
    // mathint is a number of any size that can never over or under flow 
    require(x == 0 || y == 0 || y <= assert_uint256(max_uint256 / x));
    uint256 result = mulWadUp(x, y);
    mathint expected = x * y == 0 ? 0 : (x * y - 1) / WAD() + 1;
    assert(result == assert_uint256(expected));
}