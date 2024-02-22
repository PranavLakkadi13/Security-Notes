### [H-1] Storing the Password on chain makes it visible to anyone

**Description:** All the data that is stored on chain is visible to anyone that has the copy of the blockchain. even tho the `PasswordStore::s_password` is intended to be read by the owner everyone one can read the data

**Impact:** Anyone can read the private password which severely breaks the functionality of the protocol

**Proof of Concept:**
The below code shows how the code is vulnerable

1. Create a locally running chain

```bash
make anvil
```

2. Deploy the contract to the chain

```
make deploy
```

3. Run the storage tool

We use `1` because that's the storage slot of `s_password` in the contract.

```
cast storage <ADDRESS_HERE> 1 --rpc-url http://127.0.0.1:8545
```

You'll get an output that looks like this:

`0x6d7950617373776f726400000000000000000000000000000000000000000014`

You can then parse that hex to a string with:

```
cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```

And get an output of:

```
myPassword
```

**Recommended Mitigation:**
Due to having the ability that anyone can read the password from onchain, the suggestion would be to encrypt the password offchain and then store the encrypted value on the chain

### [H-2] `PasswordStore::setPassword` has no access control meaning a non-owner can change the password

**Description:** The `PasswordStore::setPassword` function is set to be an `external` function, however the natspec of the function and overall purpose of the smart contract is that `This function allows only the owner to set a new password.`

```javascript
    function setPassword(string memory newPassword) external {
@>      // @audit - There are no access controls here
        s_password = newPassword;
        emit SetNetPassword();
    }
```

**Impact:** Anyone can set and change the password, thus severly damaging the intended purpose

**Proof of Concept:** Adding the following to `PasswordStore.t.sol`

<details>

```javascript

    function test_anyone_can_change_Password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        string memory newPassword = "myNewPassword";
        passwordStore.setPassword(newPassword);

        vm.prank(owner);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, newPassword);
    }
```

</details>

**Recommended Mitigation:** Add an access control to the above code to get the expected functionality

```javascript

    if (msg.sender != s_owner) {
        revert PasswordStore__NotOwner();
    }

```

### [I-1] The `PasswordStore::getPassword` natspec indicates a parameter that doesn't exist, causing the natspec to be incorrect

**Description:**

```javascript
    /*
     * @notice This allows only the owner to retrieve the password.
@>   * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
```

The natspec for the function `PasswordStore::getPassword` indicates it should have a parameter with the signature `getPassword(string)`. However, the actual function signature is `getPassword()`.

**Impact:** The natspec is incorrect.

**Recommended Mitigation:** Remove the incorrect natspec line.

```diff
-     * @param newPassword The new password to set.
```