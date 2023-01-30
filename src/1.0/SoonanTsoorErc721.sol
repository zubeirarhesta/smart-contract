// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SoonanTsoor is
    ERC721,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable
{
    // Bisa di-upgrade(menggunakan proxy) = yes
    // Token Suplai = 5100 - selesai
    // Bisa difraksi = ya
    // Pembayaran = USDC
    // Fungsi:
    // 1. burn, - selesai
    // 2. transfer, - selesai
    // 3. staking, dan
    // 4. transfer ownership - selesai
    // Fitur:
    // 1. Melihat jumlah NFT yang dimiliki wallet tertentu - selesai
    // 2. Melihat daftar NFT yang dimiliki dia sendiri - selesai
    // 3. Melihat / membeli NFT di Opensea/Nftfy
    // 4. Berapa jumlah token yang sudah terjual - selesai
    // 5. Withdraw uang ke wallet pemilik proyek - selesai
    // 6. Bisa di-redeem untuk pembayaran off-chain
    // 7. Merubah base URI - selesai
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(address => uint256[]) private listOfTokensOwnedBy;

    uint256 private s_initialSupply = 5100;

    address private treasuryWallet;
    address private immutable i_projectOwner =
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; // contoh wallet pemilik projek untuk likuifasi

    string private constant NAME = "SoonanTsoor";
    string private constant SYMBOL = "SNSR";
    string public base = "https://nft.soonantsoor.com";

    constructor() ERC721(NAME, SYMBOL) {
        _baseURI();
    }

    function _baseURI() internal view override returns (string memory) {
        return base;
    }

    function setBaseURI(
        string memory newBaseURI
    ) public onlyOwner returns (string memory) {
        base = newBaseURI;
        return base;
    }

    function transferOwnershipSNSR(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        listOfTokensOwnedBy[to].push(tokenId);
    }

    function safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory
    ) public {
        _safeTransfer(from, to, tokenId, "");
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function updateBaseUri(
        string memory newBaseUri
    ) public onlyOwner returns (string memory) {
        base = newBaseUri;
        return base;
    }

    function withdraw(
        address,
        address,
        uint256 amount,
        bytes memory
    ) public payable onlyOwner {
        safeTransfer(treasuryWallet, i_projectOwner, amount, "");
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

    function getMyNft() public view returns (string[] memory) {
        address owner = msg.sender;
        string[] memory tokenUris = new string[](
            listOfTokensOwnedBy[owner].length
        );
        string memory toUr;
        uint256 tokenId;
        for (uint i = 0; i < listOfTokensOwnedBy[owner].length; i++) {
            tokenId = listOfTokensOwnedBy[owner][i];
            toUr = tokenURI(tokenId);
            tokenUris[i] = toUr;
        }
        return tokenUris;
    }

    function getSoldTokens() public view returns (uint256) {
        return (_tokenIdCounter.current() - 1);
    }
}
