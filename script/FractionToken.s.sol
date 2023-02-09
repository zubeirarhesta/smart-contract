// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/1.0/FractionToken.sol";

import "../src/1.0/TokenContract.sol";
import "../src/1.0/NFTContract.sol";

import "../src/1.0/StakeSoonanTsoor.sol";
import "../src/1.0/TransferEth.sol";

contract ChugSplashScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("POLYGON_MUMBAI_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        TransferEth tfEth = new TransferEth();
        /* FractionToken fractionToken = new FractionToken(
            0xa0Ee7A142d267C1f36714E4a8F75612F20a79720,
            5000,
            msg.sender,
            1000,
            "SoonanTsoor",
            "SNSR"
        ); */

        /* TokenContract token = new TokenContract(); */
        //NFTContract nftContract = new NFTContract();
        vm.stopBroadcast();
    }
}
// https://polygon-mumbai.g.alchemy.com/v2/your-api-key
// 74dfa90880db564c87d82dc9bc380e6affd46da162d9b69d0b45c73dfdb4ad9b
//forge create --rpc-url $POLYGON_MUMBAI_URL --private-key $POLYGON_MUMBAI_PRIVATE_KEY -c src/1.0/TokenContract.sol TokenContract
// forge create TokenContract --rpc-url https://polygon-mumbai.infura.io/v3/YOUR-API-KEY --private-key 74dfa90880db564c87d82dc9bc380e6affd46da162d9b69d0b45c73dfdb4ad9b --contracts src/1.0/TokenContract.sol
// src/1.0/TransferEth.sol
// forge create --rpc-url https://polygon-mumbai.infura.io/v3/YOUR-API-KEY --private-key 74dfa90880db564c87d82dc9bc380e6affd46da162d9b69d0b45c73dfdb4ad9b --contracts src/1.0/TransferEth.sol TransferEth
