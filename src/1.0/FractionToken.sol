// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FractionToken is ERC20, ERC20Burnable, Pausable, Ownable {
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

    constructor(
        address _NFTAddress,
        uint256 _NFTId,
        address _NFTOwner,
        uint256 _royaltyPercentage,
        uint256 _supply,
        /* address _projectOwner, */
        string memory _tokenName,
        string memory _tokenTicker
    ) ERC20(_tokenName, _tokenTicker) {
        /* projectOwner = _projectOwner; */
        supply = _supply;
        NFTAddress = _NFTAddress;
        NFTId = _NFTId;
        NFTOwner = _NFTOwner;
        RoyaltyPercentage = _royaltyPercentage;

        ContractDeployer = msg.sender;

        _mint(_NFTOwner, supply);
    }

    modifier onlyContractDeployer() {
        _checkContractDeployer();
        _;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function thisMint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        //calculate royalty fee
        uint royaltyFee = (amount * RoyaltyPercentage) / 100;
        uint afterRoyaltyFee = amount - royaltyFee;
        address owner = _msgSender();

        //send royalty fee to owner
        _transfer(owner, NFTOwner, royaltyFee);
        //send rest to receiver
        _transfer(owner, to, afterRoyaltyFee);

        // addNewUserRemoveOld(to, owner);
        _setSoldTokens();

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);

        //calculate royalty fee
        uint royaltyFee = (amount * RoyaltyPercentage) / 100;
        uint afterRoyaltyFee = amount - royaltyFee;

        //send royalty fee to owner
        _transfer(from, NFTOwner, royaltyFee);
        //send rest to receiver
        _transfer(from, to, afterRoyaltyFee);

        return true;
    }

    function thisTransferOwnership(
        address newOwner
    ) public onlyContractDeployer {
        transferOwnership(newOwner);
    }

    function purchase(uint256 amountOfUsdc) public payable {
        _transferUsdc(amountOfUsdc);
        tokenOwners.push(msg.sender);
    }

    function burn(uint256 amount) public virtual override {
        _burn(_msgSender(), amount);
    }

    function updateNFTOwner(address _newOwner) public onlyContractDeployer {
        NFTOwner = _newOwner;
    }

    function withdraw(uint256 amount) public payable onlyContractDeployer {
        _transfer(_treasuryWallet, projectOwner, amount);
    }

    function updateTokenPrice(
        uint256 newTokenPrice
    ) public onlyContractDeployer returns (uint256) {
        _tokenPrice = newTokenPrice;
        return _tokenPrice;
    }

    function updateTreasuryWallet(
        address newTreasuryWallet
    ) public onlyContractDeployer returns (address) {
        _treasuryWallet = newTreasuryWallet;
        return _treasuryWallet;
    }

    function returnTokenOwners() public view returns (address[] memory) {
        return tokenOwners;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _checkContractDeployer() internal view virtual {
        require(
            msg.sender == ContractDeployer,
            "Only contract deployer can call this function"
        );
    }

    function _transferUsdc(uint256 amountOfUsdc) private onlyOwner {
        transfer(_treasuryWallet, amountOfUsdc);
    }

    function _setSoldTokens() private returns (uint256) {
        _soldToken = supply - balanceOf(ContractDeployer);
        return _soldToken;
    }

    // Fungsi-fungsi berikut adalah fungsi view / pure / getter
    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    function getSoldTokens() public view returns (uint256) {
        return _soldToken;
    }

    function getBalanceOf(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function getTokenPrice() public view returns (uint256) {
        return _tokenPrice;
    }
}
