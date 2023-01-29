// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SoonanTsoor is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    // Bisa di-upgrade(menggunakan proxy) = yes
    // Token Suplai = 5100 - selesai
    // Bisa difraksi = ya
    // Pembayaran = USDC
    // Fungsi:
    // 1. burn,
    // 2. transfer,
    // 3. staking, dan
    // 4. transfer ownership
    // Fitur:
    // 1. Melihat jumlah NFT yang dimiliki wallet tertentu - selesai
    // 2. Melihat daftar NFT yang dimiliki dia sendiri - selesai
    // 3. Melihat / membeli NFT di Opensea/Nftfy
    // 4. Berapa jumlah token yang sudah terjual
    // 5. Withdraw uang ke wallet pemilik proyek
    // 6. Bisa di-redeem untuk pembayaran off-chain
    // 7. Merubah base URI

    uint256 private s_initialSupply = 5100;

    address private treasuryWallet;
    address private immutable i_projectOwner =
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; // contoh wallet pemilik projek untuk likuifasi

    string private constant NAME = "SoonanTsoor";
    string private constant SYMBOL = "SNSR";

    constructor() ERC721(NAME, SYMBOL) {
        _mint(msg.sender, s_initialSupply);
    }

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // Fungsi-fungsi berikut adalah fungsi view / pure / getter
    function getBalanceOf(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function getMyBalance() public view returns (uint256) {
        return balanceOf(msg.sender);
    }
}
