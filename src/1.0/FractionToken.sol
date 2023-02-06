// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TransferEth.sol";

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
    // Fitur:
    // 4. Staking token untuk memberikan token rewards - selesai
    // 5. Bisa di-redeem untuk pembayaran off-chain
    FractionToken public fractionToken;
    TransferEth internal tfEth = new TransferEth();

    address public NFTAddress;
    uint256 public NFTId;
    address public NFTOwner;

    uint256 public RoyaltyPercentage;

    uint256 public supply;
    uint256 private _soldToken;
    uint256 public tokenPrice;
    address[] tokenOwners;

    address private _treasuryWallet;
    address public projectOwner;
    address contractDeployer;

    mapping(address => bool) isHolding;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => uint256) public supplyOf;
    mapping(uint256 => uint256) public maxSupplyOf;
    mapping(address => uint256) private _balances;

    string tokenName;
    string tokenTicker;

    address private original;

    constructor() ERC20(tokenName, tokenTicker) {
        NFTAddress = 0x1111111111111111111111111111111111111111;
        NFTId = 5000;
        NFTOwner = 0x1111111111111111111111111111111111111111;
        RoyaltyPercentage = 10;
        supply = 1000;

        
        /* _mint(msg.sender, supply); */
    }
    
    

    modifier isSupplyEnough(uint256 _nftId, uint256 _amount){
        _isEnough(_nftId, _amount);
        _;
    }

    function _isEnough(uint256 _nftId, uint256 _amount) private view{
        require(
            _amount <= maxSupplyOf[_nftId], //somehow this 'require' only reverts with error once supplyOf[_nftId] > supply the second time
            "Exceed the amount of available supplies"
        );
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

    function makeMaxSupply() public {
        for(uint i = 1; i <= 5000; i++){
            maxSupplyOf[i] = supply;
        }
    }

    function transferTo(
        address _to,
        uint256 _nftId,
        uint256 _amount
    ) public returns (bool) {
        //calculate royalty fee
        require(_amount <= balanceOf(NFTOwner));
        uint royaltyFee = (_amount * RoyaltyPercentage) / 100;
        uint afterRoyaltyFee = _amount - royaltyFee;
        address owner = NFTOwner;
        
    
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
        uint256 _amountToBuy
    ) public payable whenNotPaused nonReentrant isSupplyEnough(_nftId, _amountToBuy){
        tfEth.transferEth{value: msg.value}(payable(address(this)));
        transferTo(msg.sender, _nftId, _amountToBuy);
        maxSupplyOf[_nftId] = maxSupplyOf[_nftId] - _amountToBuy;
        /* setSoldTokens(_amountToBuy, _nftId);
        setOwnerOf(_nftId, msg.sender);
        tokenOwners.push(msg.sender); */
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

    /* function withdraw(uint256 _amount) public payable onlyOwner {
        payable(msg.sender).transfer(_amount*10**18);
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
        return supplyOf[_nftId]; 
    }

    function getBalanceOf(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    function getTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function getTokenOwners() public view returns (address[] memory) {
        return tokenOwners;
    }

    function getOwner() public view returns(address){
        return owner();
    }
}

