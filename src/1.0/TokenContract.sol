// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./TransferEth.sol";

contract TokenContract is
    ERC20,
    ERC20Burnable,
    Pausable,
    Ownable,
    ReentrancyGuard,
    ERC721Holder
{
    // WSNSR token variables

    IERC721 public collection;
    TransferEth internal tfEth = new TransferEth();
    address payable SoonanTsoor;

    uint256 RoyaltyPercentage = 10;
    uint256 private _soldToken;
    uint256 public tokenPrice;
    mapping (uint256 => address[]) public tokenOwners;

    address private _treasuryWallet;
    address private _projectOwner;

    mapping(address => bool) isHoldingUnit;
    mapping(uint256 => uint256) public soldTokens;
    mapping(uint256 => uint256) public availableSuppyOf;
    mapping(address => uint256) private _balances;

    bool isForAuction;

    constructor() ERC20("SoonanTsoor", "WSNSR") {
       SoonanTsoor = payable(msg.sender);
       tokenPrice = 87 * 10 ** decimals();
       isForAuction = false;
    }

    struct BuyerInfo{
        uint256 totalBalance;
        mapping(uint256 => uint256) amountOf;
        mapping(uint256 => bool) hasThis;
    }

    mapping(address => BuyerInfo) public buyerInfos;

    // Modifier(s) and its function

    modifier isSupplyEnough(uint256 _nftId, uint256 _amount){
        _isEnough(_nftId, _amount);
        _;
    }

    function _isEnough(uint256 _nftId, uint256 _amount) private view{
        require(
            _amount <= availableSuppyOf[_nftId], 
            "Exceed the amount of available supplies"
        );
    }

    // Pausable functions

    function pause() public {
        _pause();
    }

    function unpause() public {
        _unpause();
    }


    function mintTo(address _to, uint256 _amount) public whenNotPaused {
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) public virtual override {
        _burn(_msgSender(), _amount);
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
        _transfer(_from, SoonanTsoor, royaltyFee);
        //send rest to receiver
        _transfer(_from, _to, afterRoyaltyFee);

        return true;
    }

    function transferTo(
        address _to,
        uint256 _tokenId,
        uint256 _amount
    ) public returns (bool) {
        uint256 requiredAmount = buyerInfos[msg.sender].amountOf[_tokenId];
        require(_amount <= requiredAmount, "You don't have enough tokens");

        address owner = msg.sender;
        
        if(buyerInfos[_to].amountOf[_tokenId] == 0){
           _transfer(owner, _to, _amount);
           buyerInfos[_to].hasThis[_tokenId] = true;
        }else{
            _transfer(owner, _to, _amount);
        }
        buyerInfos[msg.sender].amountOf[_tokenId] -= _amount;
        buyerInfos[msg.sender].totalBalance -= _amount;
        buyerInfos[_to].amountOf[_tokenId] += _amount;
        buyerInfos[_to].totalBalance += _amount;
        if(buyerInfos[msg.sender].amountOf[_tokenId] == 0){
            buyerInfos[msg.sender].hasThis[_tokenId] = false;
        } 
        return true;
    }


    function transferOwnershipTo(address _newOwner) public {
        transferOwnership(_newOwner);
    }

    function transferEth(address payable _to) public payable /*  */ {
        (bool sent /* bytes memory data */, ) = _to.call{
            value: msg.value
        }("");
        require(sent, "Failed to send Ether");
    }

    function setNewTokenPrice(uint256 _newTokenPrice) external {
        tokenPrice = _newTokenPrice * 10 ** decimals();
    }

    function setNewProjectOwner(address _newProjectOwner) external {
        _projectOwner = _newProjectOwner;
    }

    function setNewTreasuryWallet(address _newTreasuryWallet) external {
        _treasuryWallet = _newTreasuryWallet;
    }

    function setSoldTokens(uint256 _amount, uint256 _tokenId) private {
        uint256 currentSoldTokens = soldTokens[_tokenId];
        soldTokens[_tokenId] = currentSoldTokens + _amount; 
    }

    function setOwnerOf(uint256 _tokenId, address _ownerOf) private {
        tokenOwners[_tokenId].push(_ownerOf);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    // Purchase related functions

    function transferFromOwner(
        address _to,
        uint256 _tokenId,
        uint256 _amount
    ) private returns (bool) {

        require(_amount <= balanceOf(SoonanTsoor));

        address owner = SoonanTsoor;
        
        _transfer(owner, _to, _amount);

        setSoldTokens(_amount, _tokenId);
        return true;
    }

    function purchase(
        uint256 _tokenId,
        uint256 _amountToBuy
    ) public payable whenNotPaused nonReentrant isSupplyEnough(_tokenId, _amountToBuy){
        require(getBalanceEth(msg.sender) >= msg.value, "You don't have enough USDC");
        require(msg.value >= tokenPrice * _amountToBuy, "You neen to spend more USDC");
        tfEth.transferEth{value: msg.value}(payable(address(this)));
        transferFromOwner(msg.sender, _tokenId, _amountToBuy);
        buyerInfos[msg.sender].hasThis[_tokenId] = true;
        buyerInfos[msg.sender].amountOf[_tokenId] += _amountToBuy;
        buyerInfos[msg.sender].totalBalance += _amountToBuy;
        availableSuppyOf[_tokenId] = availableSuppyOf[_tokenId] - _amountToBuy;
    }

    function withdraw() external payable onlyOwner{
        SoonanTsoor.transfer(msg.value);
    }

    //Fractionalize functions

    function createAllFractions(address _nftContractAddress) public {
        for (uint256 i = 1; i <= 5000; i++) { //create all fractions from 5000 nft
            createFraction(_nftContractAddress, i);
        }
    }

    function createFraction(
        address _nftContractAddress,
        uint256 _nftId
    ) public  {
        collection = IERC721(_nftContractAddress);
        collection.safeTransferFrom(msg.sender, address(this), _nftId, "");
        _mint(msg.sender, 1000);
        availableSuppyOf[_nftId] = 1000;
    }

    //Reedem function
    function setIsHoldingUnit(address _account) external onlyOwner{
       isHoldingUnit[_account] = true;
    } 

    function redeem(uint256 _amount) public{
        require(isHoldingUnit[msg.sender] == true, "You don't have any Soonan's unit yet");
        uint256 totalEther = address(this).balance;
        uint256 toRedeem = _amount * totalEther / 5000;
        payable(msg.sender).transfer(toRedeem);
    }

    //Auction function need review
    function setOpenForAuction() external onlyOwner{
        isForAuction = true;
    }

    function placeABid(uint256 _amount, uint256 _tokenId) public{
        require(isForAuction == true, "Not Open");
    }    
    // Fungsi-fungsi berikut adalah fungsi view / pure / getter
    function getProjectOwner() public view returns(address){
        return _projectOwner;
    }

    function getTreasuryWallet() public view returns(address){
        return _treasuryWallet;
    }

    function getBalanceEth(address /* payable */ _account) public view returns (uint) {
        return _account.balance;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    function getSoldTokens(uint256 _tokenId) public view returns (uint256) {
        return soldTokens[_tokenId]; 
    }

    function getBalanceOf(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    function getTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function getTokenOwners(uint256 _tokenId) public view returns ( address[] memory) {
        return tokenOwners[_tokenId];
    }

    function getOwner() public view returns(address){
        return owner();
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(_from, _to, _amount);
    }

}
