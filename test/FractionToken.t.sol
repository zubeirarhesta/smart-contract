// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "src/1.0/FractionToken.sol";

contract FractionTokenTest is Test {
    FractionToken internal fractionToken;
    address buyer = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    uint256 tokens = 100;
    uint256 tokenNum = 4444;

    function setUp() public virtual {
        fractionToken = new FractionToken(
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
            4444,
            0x5B38Da6a701c568545dCFCB03FcB875f56bEDDc7,
            30,
            1000,
            "SoonanTsoor",
            "SNSR"
        );
    }

    function test_getOwnerBalance() public {
        assertEq(fractionToken.getOwnerBalance(), 1000);
    }
}
