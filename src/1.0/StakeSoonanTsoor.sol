// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface Token {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (uint256);
}

contract StakeSoonanTsoor is Pausable, Ownable, ReentrancyGuard, ERC20 {
    Token snsrToken;

    // 365 Days (365 * 24 * 60 * 60)
    uint256 public planDuration = 31536000;

    // 180 Days (180 * 24 * 60 * 60)
    //uint256 _planExpired = 15552000;

    //uint256 public planExpired;
    uint8 public totalStakers;

    struct StakeInfo {
        uint256 startTS;
        uint256 endTS;
        uint256 amount;
        uint256 claimed;
    }

    event Staked(address indexed from, uint256 amount);
    event Claimed(address indexed from, uint256 amount);

    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool) public addressStaked;

    constructor(Token _tokenAddress) ERC20("TokenReward", "TRWRD") {
        require(
            address(_tokenAddress) != address(0),
            "Token Address cannot be address 0"
        );
        snsrToken = _tokenAddress;
        /* planExpired = block.timestamp + _planExpired; */
        totalStakers = 0;
    }

    function transferToken(address to, uint256 amount) external onlyOwner {
        require(snsrToken.transfer(to, amount), "Token transfer failed!");
    }

    function stakeToken(uint256 stakeAmount) external payable whenNotPaused {
        require(stakeAmount > 1000, "Stake amount should be correct");
        require(
            addressStaked[_msgSender()] == false,
            "You already participated"
        );
        require(
            snsrToken.balanceOf(_msgSender()) >= stakeAmount,
            "Insufficient Balance"
        );

        snsrToken.transferFrom(_msgSender(), address(this), stakeAmount);
        totalStakers++;
        addressStaked[_msgSender()] = true;

        stakeInfos[_msgSender()] = StakeInfo({
            startTS: block.timestamp,
            endTS: block.timestamp + planDuration,
            amount: stakeAmount,
            claimed: 0
        });

        emit Staked(_msgSender(), stakeAmount);
    }

    function claimReward() external returns (bool) {
        require(
            addressStaked[_msgSender()] == true,
            "You are not participated"
        );
        require(
            (stakeInfos[_msgSender()].endTS - stakeInfos[_msgSender()].endTS) >=
                planDuration,
            "Stake Time is not over yet"
        );
        require(stakeInfos[_msgSender()].claimed == 0, "Already claimed");

        uint256 stakeAmount = stakeInfos[_msgSender()].amount;
        _mint(address(this), 25000000);
        uint256 totalTokens = stakeAmount + 25000000;
        stakeInfos[_msgSender()].claimed == totalTokens;
        snsrToken.transfer(_msgSender(), totalTokens);

        emit Claimed(_msgSender(), totalTokens);

        return true;
    }

    function getTokenExpiry() external view returns (uint256) {
        require(
            addressStaked[_msgSender()] == true,
            "You are not participated"
        );
        return stakeInfos[_msgSender()].endTS;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
