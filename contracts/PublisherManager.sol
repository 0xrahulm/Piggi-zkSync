//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICampaign {
    function claimUser(address _publisher, address _user) external;

    function viewMarketer() external view returns (address);
}

interface IFeEx {
    function enableInteractionFeedback(address _from, address _to) external;
}

interface IHoldingWallet {
    function freezeTokens(address _receiver) external payable;

    function revokeTokens(address _receiver, uint _amount) external;

    function freeTokens(address _reciever, uint _amount) external;

    function viewHoldings(
        address _publisher,
        address _campaign
    ) external view returns (uint);
}

contract PublisherManager {
    address public feExAddress;
    address private owner;
    address public holdingWalletAddress;

    constructor(){
        owner = msg.sender;
    }

    receive() external payable {}

    function viewCampaignHeldTokens(
        address _campaign
    ) external view returns (uint) {
        return IHoldingWallet(holdingWalletAddress).viewHoldings(msg.sender, _campaign);
    }

    function claimEndUser(address _userId, address _campaign) external {
        //enable feedback from the marketer
        address marketer = ICampaign(_campaign).viewMarketer();
        IFeEx(feExAddress).enableInteractionFeedback(marketer, msg.sender);
        ICampaign(_campaign).claimUser(msg.sender, _userId);
    }

    function updateAddress(address _newAddress,bool _holdingWallet) external{
        require(msg.sender == owner,"Only Owner");
        if(_holdingWallet){
            holdingWalletAddress = _newAddress;
        }else{
            feExAddress = _newAddress;
        }
    }
}
