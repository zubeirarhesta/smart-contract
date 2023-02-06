// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "chugsplash/ChugSplash.sol";

import "../src/1.0/FractionToken.sol";

import "../src/1.0/FractionalizeNFT.sol";
import "../src/1.0/NFTContract.sol";

import "../src/1.0/StakeSoonanTsoor.sol";
import "../src/1.0/TransferEth.sol";

contract ChugSplashScript is Script {
    function run() public {
        // Create a ChugSplash instance
        ChugSplash chugsplash = new ChugSplash();

        // Define the path from the project root to your ChugSplash file.
        string memory chugsplashFilePath = "./chugsplash/hello-chugsplash.json";

        // Deploy all contracts in your ChugSplash file (in this case, just HelloChugSplash.sol)
        chugsplash.deploy(chugsplashFilePath);

        chugsplash.refresh();
    }
}
