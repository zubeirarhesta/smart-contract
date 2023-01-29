// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SoonanTsoor is ERC20, ERC20Burnable, Pausable, Ownable {
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

    // Mengembalikan nilai berupa jumlah token yang allowed by owner for buyer to use. Granting menggunakan approve
    mapping(address => mapping(address => uint256)) private allowances;

    address[] public s_purchasers;
    address private immutable i_projectOwner =
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    uint256 private immutable i_initialSupply = 5000000;
    string private constant NAME = "SoonanTsoor";
    string private constant SYMBOL = "SNSR";
    uint256 private s_soldToken;
    uint256 private s_tokenPrice;
    address private treasuryWallet;

    constructor() ERC20(NAME, SYMBOL) {
        _mint(msg.sender, i_initialSupply);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mintSNSR(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burnSNSR(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }

    function transferSNSR(
        address from,
        address to,
        uint256 amount
    ) public onlyOwner returns (bool, uint256) {
        _transfer(from, to, amount);
        return (true, setSoldTokens());
    }

    function transferUsdc(uint256 amountOfUsdc) private onlyOwner {
        transfer(treasuryWallet, amountOfUsdc);
    }

    function transferOwnershipSNSR(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }

    function purchase(uint256 amountOfUsdc) public payable {
        transferUsdc(amountOfUsdc);
        s_purchasers.push(msg.sender);
    }

    function withdraw(uint256 amount) public payable onlyOwner {
        _transfer(treasuryWallet, i_projectOwner, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function setSoldTokens() private returns (uint256) {
        s_soldToken = i_initialSupply - balanceOf(msg.sender);
        return s_soldToken;
    }

    function updateTokenPrice(
        uint256 newTokenPrice
    ) public onlyOwner returns (uint256) {
        s_tokenPrice = newTokenPrice;
        return s_tokenPrice;
    }

    function updateTreasuryWallet(
        address newTreasuryWallet
    ) public onlyOwner returns (address) {
        treasuryWallet = newTreasuryWallet;
        return treasuryWallet;
    }

    // Fungsi-fungsi berikut adalah fungsi view / pure / getter
    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    function getSoldTokens() public view returns (uint256) {
        return s_soldToken;
    }

    function getOwner() public view returns (address) {
        return owner();
    }

    function getBalanceOf(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function getName() public view returns (string memory) {
        return name();
    }

    function getSymbol() public view returns (string memory) {
        return symbol();
    }

    function getTokenPrice() public view returns (uint256) {
        return s_tokenPrice;
    }
}
