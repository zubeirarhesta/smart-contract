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

    uint256 public RoyaltyPercentage;

    uint256 public supply;
    uint256 private _soldToken;
    uint256 tokenPrice;
    address[] tokenOwners;

    address private _treasuryWallet;
    address public projectOwner;
    address contractDeployer;

    mapping(address => bool) isHolding;
    mapping(uint256 => address) public ownerOf;
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

        contractDeployer = msg.sender;
        _mint(_NFTOwner, supply);
    }

    function pause() public {
        _pause();
    }

    function unpause() public {
        _unpause();
    }

    function mintTo(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function transferTo(
        address _to,
        uint256 _amount,
        uint256 _nftId
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
        setOwnerOf(_nftId, _to);
        setSoldTokens(_amount, _nftId);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
        uint256 _nftId,
        uint256 _tokens
    ) public payable whenNotPaused nonReentrant {
        require(
            supplyOf[_nftId] <= supply, //somehow this require only reverts with error once supplyOf[_nftId] > supply the second time
            "Exceed the amount of available supplies"
        );
        setOwnerOf(_nftId, msg.sender);
        setSoldTokens(_tokens, _nftId);
        tokenOwners.push(msg.sender);
    }

    function burn(uint256 _amount) public virtual override {
        _burn(_msgSender(), _amount);
    }

    function transferEth(address payable _to) public payable /*  */ {
        (bool sent /* bytes memory data */, ) = _to.call{
            value: msg.value
        }("");
        require(sent, "Failed to send Ether");
    }

    /* function withdraw(uint256 _amount) public payable {
        _transfer(_treasuryWallet, projectOwner, _amount);
    } */

    /* function setNewNFTOwner(address _newNFTOwner) external {
        NFTOwner = _newNFTOwner;
    } */ 

    function setNewTokenPrice(uint256 _newTokenPrice) external {
        tokenPrice = _newTokenPrice;
    }

    function setNewProjectOwner(address _newProjectOwner) external {
        projectOwner = _newProjectOwner;
    }

    function setNewTreasuryWallet(address _newTreasuryWallet) external {
        _treasuryWallet = _newTreasuryWallet;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(_from, _to, _amount);
    }

    /* function _transferUsdc(uint256 _amountOfUsdc) private {
        transfer(_treasuryWallet, _amountOfUsdc);
    } */

    function setSoldTokens(uint256 _amount, uint256 _nftId) private {
        uint256 currentSoldTokens = supplyOf[_nftId];
        supplyOf[_nftId] = currentSoldTokens + _amount; 
    }

    function setOwnerOf(uint256 _nftId, address _ownerOf) private {
        ownerOf[_nftId] = _ownerOf;
    }

    // Fungsi-fungsi berikut adalah fungsi view / pure / getter
    function ContractDeployer() public view returns(address){
        return contractDeployer;
    }

    function getProjectOwner() public view returns(address){
        return projectOwner;
    }

    function getTreasuryWallet() public view returns(address){
        return _treasuryWallet;
    }

    function getBalanceEth(address /* payable */ account) public view returns (uint) {
        return account.balance;
    }

    function getTotalSupply() public view returns (uint256) {
        return supply;
    }

    function getOwnerOf(uint256 _nftId) public view returns(address){
        return ownerOf[_nftId];
    }

    function getSoldTokens(uint256 _nftId) public view returns (uint256) {
        return supplyOf[_nftId]; // or should be without taking from param like this? -> supplyOf[NFTId],
    }

    function getBalanceOf(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    function getTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function getTokenOwners() public view onlyOwner returns (address[] memory) {
        return tokenOwners;
    }

    function getOwner() public view returns(address){
        return owner();
    }
}
