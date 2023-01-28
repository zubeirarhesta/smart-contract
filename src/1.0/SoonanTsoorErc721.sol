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
    // 1. Melihat jumlah NFT yang dimiliki wallet tertentu
    // 2. Melihat daftar NFT yang dimiliki dia sendiri
    // 3. Melihat / membeli NFT di Opensea/Nftfy
    // 4. Berapa jumlah token yang sudah terjual
    // 5. Withdraw uang ke waller pemilik proyek
    // 6. Bisa di-redeem untuk pembayaran off-chain

    uint256 private s_initialSupply = 5100;
    uint256 private s_totalSupply;

    constructor() /* uint256 _initialSupply */ ERC721("SoonanTsoor", "SNSR") {
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
    function getTotalSupply() public view returns (uint256) {
        return s_totalSupply;
    }
}
