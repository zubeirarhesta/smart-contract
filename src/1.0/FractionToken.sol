// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FractionToken is
    ERC20,
    ERC20Burnable,
    Pausable,
    Ownable,
    ReentrancyGuard
{
    // Bisa di-upgrade(menggunakan proxy) = yes
    // Token Suplai = 5000000 - selesai
    // Pembayaran = USDC
    // Fungsi:
    // 1. burn, - selesai
    // 2. transfer, - selesai
    // 3. staking, dan - selesai
    // 4. transfer ownership - selesai
    // Fitur:
    // 1. Berapa jumlah token yang sudah terjual --> getSoldTokens() - selesai
    // 2. Mengubah harga token --> updateTokebPrice(uint256 newTokenPrice) - selesai
    // 3. Merubah alamat wallet --> updateTreasuryWallet(address newTreasuryWallet) - selesai
    // 3. Withdraw uang ke wallet pemilik proyek --> withdraw(uint256 amount, address projectOwner) - selesai
    // 4. Staking token untuk memberikan token rewards - selesai
    // 5. Bisa di-redeem untuk pembayaran off-chain
    address public NFTAddress;
    uint256 public NFTId;
    address public NFTOwner;

    address public ContractDeployer;
    uint256 public RoyaltyPercentage;

    uint256 public supply;
    uint256 private _soldToken;
    uint256 private _tokenPrice;
    address[] tokenOwners;

    address private _treasuryWallet;
    address public projectOwner;

    mapping(address => bool) isHolding;
    mapping(uint256 => uint256) public supplyOf;

    constructor(
        address _NFTAddress,
        uint256 _NFTId,
        address _NFTOwner,
        uint256 _royaltyPercentage,
        uint256 _supply,
        string memory _tokenName,
        string memory _tokenTicker
    ) ERC20(_tokenName, _tokenTicker) {
        NFTAddress = _NFTAddress;
        NFTId = _NFTId;
        NFTOwner = _NFTOwner;
        RoyaltyPercentage = _royaltyPercentage;
        supply = _supply;
        _mint(_NFTOwner, supply);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mintTo(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function transferTo(
        address _to,
        uint256 _amount,
        uint256 _tokenId
    ) public returns (bool) {
        //calculate royalty fee
        uint royaltyFee = (_amount * RoyaltyPercentage) / 100;
        uint afterRoyaltyFee = _amount - royaltyFee;
        address owner = _msgSender();

        //send royalty fee to owner
        _transfer(owner, NFTOwner, royaltyFee);
        //send rest to receiver
        _transfer(owner, _to, afterRoyaltyFee);

        // addNewUserRemoveOld(to, owner);
        tokenOwners.push(_to);
        setSoldTokens(_tokenId, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(_from, spender, _amount);

        //calculate royalty fee
        uint royaltyFee = (_amount * RoyaltyPercentage) / 100;
        uint afterRoyaltyFee = _amount - royaltyFee;

        //send royalty fee to owner
        _transfer(_from, NFTOwner, royaltyFee);
        //send rest to receiver
        _transfer(_from, _to, afterRoyaltyFee);

        return true;
    }

    function transferOwnershipTo(address _newOwner) public {
        transferOwnership(_newOwner);
    }

    function purchase(
        uint256 _amountOfUsdc,
        uint256 _tokenId
    ) public payable whenNotPaused nonReentrant {
        require(
            supplyOf[_tokenId] <= supply, // or should be without taking from param like this? -> supplyOf[NFTId] <= supply,
            "Exceed the amount of available supplies"
        );
        _transferUsdc(_amountOfUsdc);
        tokenOwners.push(msg.sender);
    }

    function burn(uint256 _amount) public virtual override {
        _burn(_msgSender(), _amount);
    }

    function setNewNFTOwner(address _newNFTOwner) external {
        NFTOwner = _newNFTOwner;
    }

    function withdraw(uint256 _amount) public payable {
        _transfer(_treasuryWallet, projectOwner, _amount);
    }

    function setNewTokenPrice(uint256 _newTokenPrice) external {
        _tokenPrice = _newTokenPrice;
    }

    function setNewProjectOwnerWallet(address _newProjectOwnerWallet) external {
        projectOwner = _newProjectOwnerWallet;
    }

    function setNewTreasuryWallet(address _newTreasuryWallet) external {
        _treasuryWallet = _newTreasuryWallet;
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(_from, _to, _amount);
    }

    function _transferUsdc(uint256 _amountOfUsdc) private {
        transfer(_treasuryWallet, _amountOfUsdc);
    }

    function setSoldTokens(uint256 _tokenId, uint256 _amount) private {
        supplyOf[_tokenId] + _amount; // or should be without taking from param like this? -> supplyOf[NFTId] <= supply,
    }

    // Fungsi-fungsi berikut adalah fungsi view / pure / getter
    function getTotalSupply() public view returns (uint256) {
        return supply;
    }

    function getSoldTokens(uint256 _tokenId) public view returns (uint256) {
        return supplyOf[_tokenId]; // or should be without taking from param like this? -> supplyOf[NFTId] <= supply,
    }

    function getBalanceOf(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    function getTokenPrice() public view returns (uint256) {
        return _tokenPrice;
    }

    function getTokenOwners() public view onlyOwner returns (address[] memory) {
        return tokenOwners;
    }
}
