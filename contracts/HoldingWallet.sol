//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract HoldingWallet {
    mapping(address => mapping(address => uint)) private holdings;

    function viewHoldings(
        address _publisher,
        address _campaign
    ) external view returns (uint) {
        return holdings[_publisher][_campaign];
    }

    function freezeTokens(address _receiver) external payable {
        holdings[_receiver][msg.sender] += msg.value;
    }

    function revokeTokens(address _receiver, uint _amount) external {
        require(
            holdings[_receiver][msg.sender] >= _amount,
            "You dont hold that much Tokens of receiver"
        );
        holdings[_receiver][msg.sender] -= _amount;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Failed to sent back the Tokens");
    }

    function freeTokens(address _receiver, uint _amount) external {
        require(
            holdings[_receiver][msg.sender] >= _amount,
            "You dont hold that much Tokens of receiver"
        );
        holdings[_receiver][msg.sender] -= _amount;
        (bool success, ) = payable(_receiver).call{value: _amount}("");
        require(success, "Failed to sent Tokens to the reciever");
    }
}
