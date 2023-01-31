// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
    // Bisa di-upgrade(menggunakan proxy) = yes - almost
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

    mapping(address => uint256[]) private _listOfTokensOwnedBy;

    uint public supply;

    address private _treasuryWallet;
    address private immutable i_projectOwner =
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; // contoh wallet pemilik projek untuk likuifasi

    string private constant NAME = "SoonanTsoor";
    string private constant SYMBOL = "SNSR";
    string public base = "https://nft.soonantsoor.com";

    constructor() ERC721(NAME, SYMBOL) {
        _baseURI();
    }

    event TransferTokenId(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    function setBaseURI(
        string memory newBaseUri
    ) public onlyOwner returns (string memory) {
        base = newBaseUri;
        return base;
    }

    function thisTransferOwnership(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        _listOfTokensOwnedBy[msg.sender].push(tokenId);
    }

    function safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory
    ) public {
        _safeTransfer(from, to, tokenId, "");
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
        safeTransfer(_treasuryWallet, i_projectOwner, amount, "");
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return base;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    // Fungsi-fungsi berikut adalah fungsi view / pure / getter

    // returns the amount of tokens a address has
    function getBalanceOf(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    // returns list of nfts of this function caller
    function getMyNfts() public view returns (string[] memory) {
        address owner = msg.sender;
        string[] memory listOfTokenUris = new string[](
            _listOfTokensOwnedBy[owner].length
        );
        string memory tokenUri;
        uint256 tokenId;
        for (uint i = 0; i < _listOfTokensOwnedBy[owner].length; i++) {
            tokenId = _listOfTokensOwnedBy[owner][i];
            tokenUri = tokenURI(tokenId);
            listOfTokenUris[i] = tokenUri;
        }
        return listOfTokenUris;
    }

    // returns the amount of tokens sold
    function getSoldTokens() public view returns (uint256) {
        return (_tokenIdCounter.current() - 1);
    }
}
