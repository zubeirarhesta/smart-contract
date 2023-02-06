// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract TransferEth {
    uint256 num;

    function transferEth(address payable _to) public payable /*  */ {
        (bool sent /* bytes memory data */, ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
