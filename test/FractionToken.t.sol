// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "src/1.0/FractionToken.sol";

contract FractionTokenTest is Test {
    FractionToken internal fractionToken;

    function setUp() public virtual {
        fractionToken = new FractionToken(
            0xa0Ee7A142d267C1f36714E4a8F75612F20a79720, // anvil preset address
            5000,
            address(msg.sender),
            10,
            1000000,
            "SoonanTsoor",
            "SNSR"
        );
    }

    function test_getTotalSupply() public {
        //this test indicates the success of instancing object
        assertEq(fractionToken.getTotalSupply(), 1000000);
    }

    function test_getSoldTokens() public {
        fractionToken.purchase(1, 500);
        assertEq(fractionToken.getSoldTokens(1), 500);
    }

    function test_getBalances() public {
        fractionToken.mintTo(address(this), 1000);
        address five = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc; // anvil preset address
        fractionToken.transferTo(five, 200, 2);
        assertEq(fractionToken.getBalanceOf(five), 200);
    }

    function test_twoGetBalances() public {
        fractionToken.mintTo(address(this), 1000);
        address seven = 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955; // anvil preset address
        fractionToken.transferTo(seven, 300, 2);
        assertFalse(
            fractionToken.getBalanceOf(seven) ==
                fractionToken.getBalanceEth(seven)
        );
    }

    function test_getTokenOwners() public {
        fractionToken.purchase(4, 50);
        assertFalse(fractionToken.getTokenOwners().length == 0);
    }
}
