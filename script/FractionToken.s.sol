// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/1.0/FractionToken.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        FractionToken fractionToken = new FractionToken(
            0x70997970C51812dc3A010C7d01b50e0d17dc79C8,
            4444,
            0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC,
            30,
            1000,
            "SoonanTsoor",
            "SNSR"
        );

        vm.stopBroadcast();
    }
}
