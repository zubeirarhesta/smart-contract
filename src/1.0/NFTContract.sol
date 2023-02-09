// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTContract is
    ERC721,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable
{
    // Bisa di-upgrade(menggunakan proxy) = yes - almost
    // Bisa difraksi = ya
    // Fitur:
    // 3. Melihat / membeli NFT di Opensea/Nftfy - purchase

    mapping(address => uint256[]) private _listOfTokensOwnedBy;
    mapping(uint256 => address) ownerOfThis;

    address private _treasuryWallet;
    address projectOwner;

    string[] public tokenUris;

    string public base = "https://nft.soonantsoor.com";

    constructor(address _fractionalizer) ERC721("SoonanTsoor", "SNSR") {
        setApprovalForAll(_fractionalizer, true);
        _baseURI();
    }

    function setBaseURI(
        string memory _newBaseUri
    ) public onlyOwner returns (string memory) {
        base = _newBaseUri;
        return base;
    }

    function transferOwnershipTo(address _newOwner) public {
        transferOwnership(_newOwner);
    }

    function pause() public {
        _pause();
    }

    function unpause() public {
        _unpause();
    }

    function safeMintAll() public {
        require(
            owner() == msg.sender,
            "This function is only callable by Soonan Tsoor"
        );
        /* string memory tokenUri; */
        for (uint i = 1; i <= 5100; i++) {
            // should be 5100
            safeMint(i);
            /* tokenUri = tokenURI(i);
            tokenUris[i] = tokenUri;*/
        }
    }

    function safeMint(uint256 _tokenId) public {
        _safeMint(msg.sender, _tokenId);
    }

    function safeTransfer(address _to, uint256 _tokenId) public {
        _safeTransfer(msg.sender, _to, _tokenId, "");
        ownerOfThis[_tokenId] = _to;
    }

    function purchase(uint256 _nftId) public payable onlyOwner {
        //tfEth.transferEth{value: msg.value}(payable(_treasuryWallet));
        ownerOfThis[_nftId] = msg.sender;
    }

    function updateBaseUri(
        string memory newBaseUri
    ) public onlyOwner returns (string memory) {
        base = newBaseUri;
        return base;
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

    // returns list of nfts of this function caller -- needs REVIEW
    function getNFT() public view returns (string[] memory) {
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
}
