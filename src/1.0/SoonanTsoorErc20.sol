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
    // 3. staking, dan
    // 4. transfer ownership - selesai
    // Fitur:
    // 1. Berapa jumlah token yang sudah terjual --> getTotalSupply() - selesai
    // 2. Mengubah harga token --> setPrice(uint256 price)
    // 3. Withdraw uang ke wallet pemilik proyek --> withdraw(uint256 amount, address projectOwner)
    // 4. Staking token untuk memberikan token rewards
    // 5. Bisa di-redeem untuk pembayaran off-chain

    // Mengembalikan nilai berupa jumlah token yang allowed by owner for buyer to use. Granting menggunakan approve
    mapping(address => mapping(address => uint256)) private allowances;

    address[] private s_accounts;
    uint256 s_initialSupply = 5000000;
    string private _name = "SoonanTsoor";
    string private _symbol = "SNSR";

    constructor() ERC20(_name, _symbol) {
        _mint(msg.sender, s_initialSupply);
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
    ) public onlyOwner {
        _transfer(from, to, amount);
    }

    function transferOwnershipSNSR(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    // Fungsi-fungsi berikut adalah fungsi view / pure / getter
    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
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
}
