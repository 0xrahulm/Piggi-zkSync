//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./CampaignContract.sol";

interface IFeEx {
    function enableInteractionFeedback(address _from, address _to) external;
}

contract CampaignManager {
    address public feExAddress;
    address public publisherManagerAddress;
    address public holdingWalletAddress;
    address private owner;

    constructor(){
        owner = msg.sender;
    }

    event CampaignCreated(address indexed Marketer,uint indexed RevenuePerUser,address Campaign,string  CampaignName);
    event CampaignFunded(address indexed Campaign, uint indexed Amount);

    function createCampaign(
        string memory _campaignName,
        uint _revenuePerUser
    ) external returns (address) {
        require(holdingWalletAddress!=address(0) && publisherManagerAddress!=address(0),"Addresses have not been set");
        Campaign newCampaign = new Campaign(
            address(this),
            holdingWalletAddress,
            publisherManagerAddress,
            msg.sender,
            _campaignName,
            _revenuePerUser
        );
        emit CampaignCreated(msg.sender,_revenuePerUser,address(newCampaign),_campaignName);
        return address(newCampaign);
    }

    function fundCampaign(address payable _campaign) external payable {
        require(msg.value > 0, "No Tokens received");
        (bool success, ) = _campaign.call{value: msg.value}("");
        require(success, "Falied to Fund");
        emit CampaignFunded(_campaign, msg.value);
    }

    function verifyClaim(
        address payable _campaign,
        uint _claimId,
        bool _result
    ) external {
        (address reqPublisher,) = Campaign(_campaign).viewActiveClaim(
            _claimId
        );
        Campaign(_campaign).verifyClaim(msg.sender, _claimId, _result);
        

        // Allow the Publisher to rate back the Marketer
        IFeEx(feExAddress).enableInteractionFeedback(reqPublisher, msg.sender);
        
    }

    function updateAddress(address _newAddress,uint _option) external{
        require(msg.sender == owner,"Only owner");
        if(_option==1){
            feExAddress = _newAddress;
        }else if(_option == 2){
            publisherManagerAddress = _newAddress;
        }else {
            holdingWalletAddress = _newAddress;
        }
    }
}
