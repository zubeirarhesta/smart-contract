// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "chugsplash/ChugSplash.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/1.0/FractionToken.sol";

contract FractionTokenTest is Test {
    FractionToken fractionTokenProxy;
    FractionToken fractionTokenOrigin;
    event Log(string message);
    event LogBytes(bytes data);
    address projectOwner;
    address treasuryWallet;

    function setUp() public virtual {
        // Create a ChugSplash instance
        ChugSplash chugsplash = new ChugSplash();

        // Define the path from the project root to your ChugSplash file.
        string memory chugsplashFilePath = "./chugsplash/hello-chugsplash.json";

        // Deploy all contracts in your ChugSplash file (in this case, just HelloChugSplash.sol)
        chugsplash.deploy(chugsplashFilePath, true);

        // You *must* refresh EVM state after calling `chugsplash.deploy`.
        chugsplash.refresh();

        fractionTokenProxy = FractionToken(
            payable(
                chugsplash.getAddress(chugsplashFilePath, "Soonan Tsoor ERC20")
            )
        );

        fractionTokenOrigin = new FractionToken();
        /* 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720, */ // anvil preset address
        /* 5000, */
        /* msg.sender, */
        /* 10, */
        /* 1000, */
        /* "SoonanTsoor", */
        /* "SNSR" */

        fractionTokenProxy.makeMaxSupply();
        fractionTokenOrigin.makeMaxSupply();
        projectOwner = 0x976EA74026E726554dB657fA54763abd0C3a0aa9; // anvil preset address
        treasuryWallet = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65; // anvil preset address
    }

    function test_getTotalSupply() public {
        //getTotalSupply() returns supply
        //that defined
        assertEq(fractionTokenProxy.getTotalSupply(), 1000);
    }

    function test_getSoldTokens() public {
        //this test also covers purchase(uint256 _amount, uint256 _nftId )
        //this test also covers setSoldTokens(uint256 _nftId, uint256 _tokens ) that includes in purchase()
        fractionTokenOrigin.mintTo(
            address(fractionTokenOrigin.NFTOwner()),
            10000
        );
        fractionTokenOrigin.purchase{value: 0}(1, 500); // 1 = the Id of certain NFT, 500 = amount of NFTs purchased
        assertEq(fractionTokenOrigin.getSoldTokens(1), 500); // shows that NFT with Id 1 is sold with the amount of 500
    }

    function test_getBalanceOf() public {
        //this test also covers transferTo(address _to, uint256 _amount, uint256 _nftId)
        address five = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc;
        fractionTokenOrigin.mintTo(
            address(fractionTokenOrigin.NFTOwner()),
            10000
        );
        fractionTokenOrigin.transferTo(five, 2, 200);
        assertEq(fractionTokenOrigin.getBalanceOf(five), 180);
    }

    function test_getBalanceses() public {
        //this test shows that getBalanceOf and getBalanceEth are different

        address seven = 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955; // anvil preset address
        fractionTokenOrigin.mintTo(
            address(fractionTokenOrigin.NFTOwner()),
            10000
        );
        fractionTokenOrigin.transferTo(seven, 300, 2);
        assertFalse(
            fractionTokenOrigin.getBalanceOf(seven) == // getBalanceOf returns amount of token
                fractionTokenOrigin.getBalanceEth(seven) // getBalanceEth returns amount of Eth or USDC
        );
    }

    function test_getTokenOwners() public {
        //this test covers getTokenOwners() that returns array of addresses
        fractionTokenOrigin.mintTo(
            address(fractionTokenOrigin.NFTOwner()),
            10000
        );
        fractionTokenOrigin.purchase{value: 0}(4, 1); // everytime purchase() called, array of tokenOwners increase 1 in length
        assertFalse(fractionTokenOrigin.getTokenOwners().length == 0); //thus, the calling of getTokenOwner() should returns 1
    }

    function test_pause() public {
        //this test covers pause() that changes the state of contrart to paused()
        //means that function that has whenNotPaused modifier on it, can't be called
        //purchase() has whenNotPaused modifies, thus it never be called
        //with that being said, setSoldTokens() not executed
        fractionTokenProxy.pause();
        try fractionTokenProxy.purchase(5, 500) {} catch Error(
            string memory reason
        ) {
            // catch failing revert() and require()
            emit Log(reason);
        }
        assertEq(fractionTokenProxy.getTokenOwners().length, 0); //those result that nft tokens of Id '5' is never sold aka equals'0'
    }

    function test_mintTo() public {
        //this test covers mintTo()
        //that does minting tokens to an address
        address six = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;
        fractionTokenOrigin.mintTo(six, 1000);
        assertEq(fractionTokenOrigin.getBalanceOf(six), 1000);
    }

    function test_transferOwnership() public {
        address six = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;
        fractionTokenOrigin.transferOwnership(six);
        assertEq(fractionTokenOrigin.getOwner(), six);
    }

    function test_burn() public {
        fractionTokenOrigin.mintTo(address(this), 1000);
        fractionTokenOrigin.burn(1000);
        assertEq(fractionTokenProxy.getBalanceOf(address(this)), 0);
    }

    function test_transferEth() public {
        //this test covers transferEth()
        //that does transferring amount of eth to a payable address
        //this test also covers getBalanceEth() that returns eth owned by a payable address
        address six = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;
        fractionTokenProxy.transferEth{value: 1 ether}(payable(six)); // { value : 1 ether } this is how we pass value to msg.value
        assertEq(fractionTokenProxy.getBalanceEth(payable(six)), 10001 ether);
    }

    function test_setNewTokenPrice() public {
        //this test covers setNewTokenPrice() and getTokenPrice()
        //that sets new price of token
        //currently 17 ether
        uint256 newTokenPrice = 18 ether;
        fractionTokenProxy.setNewTokenPrice(newTokenPrice);
        assertEq(fractionTokenProxy.getTokenPrice(), 18 ether);
    }

    function test_setNewProjectOwner() public {
        //this test covers setNewProjectOwner() and getProjectOwner()
        //that sets new project owner wallet
        //currently 0x976EA74026E726554dB657fA54763abd0C3a0aa9
        address newProjectOwner = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;
        fractionTokenProxy.setNewProjectOwner(newProjectOwner);
        assertEq(fractionTokenProxy.getProjectOwner(), newProjectOwner);
    }

    function test_setNewTreasuryWallet() public {
        //this test covers setNewTreasuryWallet() and getTreasuryWallet()
        //that sets new treasury wallet
        //currently 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65
        address newTreasuryWallet = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;
        fractionTokenProxy.setNewTreasuryWallet(newTreasuryWallet);
        assertEq(fractionTokenProxy.getTreasuryWallet(), newTreasuryWallet);
    }

    function test_getOwnerOf() public {
        //this test covers getOwnerOf() and returns owner of spesific nftId
        //also covers setOwnerOf() that triggered when purchase() called
        //initially nft with Id of 17 is no man nft
        fractionTokenOrigin.mintTo(
            address(fractionTokenOrigin.NFTOwner()),
            10000
        );
        fractionTokenOrigin.purchase{value: 0}(17, 500); //msg.sender purchases 500 nfts with Id no 17
        assertEq(fractionTokenOrigin.getOwnerOf(17), address(this));
    }

    function test_transferFrom() public {
        //this test cover transferFrom() and approve()
        //this flow/schema explains nft trading that has 3rd party involved like opensea
        fractionTokenOrigin.mintTo(address(this), 10000);
        address buyer = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;
        fractionTokenOrigin.approve(address(this), 1000);
        fractionTokenOrigin.transferFrom(address(this), buyer, 100);
        assertEq(fractionTokenOrigin.getBalanceOf(buyer), 90);
    }

    function test_requireOfPurchase() public {
        fractionTokenOrigin.mintTo(
            address(fractionTokenOrigin.NFTOwner()),
            10000
        );
        fractionTokenOrigin.purchase{value: 1 ether}(10, 500);
        try fractionTokenOrigin.purchase{value: 0}(10, 600) {} catch Error(
            string memory reason
        ) {
            // catch failing revert() and require()
            emit Log(reason);
        }
        console2.logUint(fractionTokenOrigin.getBalanceEth(address(this)));
        assertFalse(fractionTokenOrigin.getSoldTokens(10) == 1100);
    }

    function test_justConsoling() public view {
        console2.logString("This is FractionToken Implementation Address: ");
        console2.logAddress(address(fractionTokenOrigin));
        console2.logString(" ");
        console2.logString("This is FractionToken Proxy Address: ");
        console2.logAddress(address(fractionTokenProxy));
        console2.logString(" ");
        console2.logString("This is this function caller Address: ");
        console2.logAddress(msg.sender);
        console2.logString(" ");
        console2.logString("This is this contract Address: ");
        console2.logAddress(address(this));
        console2.logString(" ");
        console2.logString(
            "This is the Address FractionToken Implementation Calling getOwner(): "
        );
        console2.logAddress(fractionTokenOrigin.getOwner());
        console2.logString(" ");
        console2.logString(
            "This is the Address FractionToken Proxy Calling getOwner(): "
        );
        console2.logAddress(fractionTokenProxy.getOwner());
        console2.logString(" ");
    }
}
