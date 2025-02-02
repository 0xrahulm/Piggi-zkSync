//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IHoldingWallet {
    function freezeTokens(address _receiver) external payable;

    function revokeTokens(address _receiver, uint _amount) external;

    function freeTokens(address _reciever, uint _amount) external;

    function viewHoldings(
        address _publisher,
        address _campaign
    ) external view returns (uint);
}

contract Campaign {
    uint public revenuePerUser;
    string public campaignName;
    address private immutable holdingWalletAddress ;
    address private immutable marketer;
    address private immutable publisherManager;
    address private immutable campaignManager;

    struct Claim {
        address publisher;
        address user;
    }

    mapping(uint=>Claim) private claims;
    uint private newId;

    constructor(
        address _campaignManager,
        address _holdingWalletAddress,
        address _publisherManager,
        address _marketer,
        string memory _campaignName,
        uint _costPerUser
    ) {
        publisherManager = _publisherManager;
        holdingWalletAddress = _holdingWalletAddress;
        revenuePerUser = _costPerUser;
        marketer = _marketer;
        campaignName = _campaignName;
        campaignManager = _campaignManager;
    }

    event SuccessfulClaim(
        address indexed publisher,
        address indexed user,
        uint claimId
    );
    event NewClaim(
        address indexed publisher,
        address indexed user,
        uint claimId
    );
    event RevokedClaim(
        address indexed publisher,
        address indexed user,
        uint claimId
    );

    modifier onlyMarketer(address _caller) {
        require(_caller == marketer, "Only Marketer");
        _;
    }

    modifier onlyPublisherManager() {
        require(msg.sender == publisherManager, "Only PublisherManager");
        _;
    }

    modifier onlyCampaignManager() {
        require(msg.sender == campaignManager, "Only CampaignManager");
        _;
    }

    receive() external payable {}

    function viewMarketer() public view returns (address) {
        return marketer;
    }

    function viewBalance() external view returns (uint) {
        return address(this).balance;
    }

    function viewActiveClaim(
        uint _claimId
    ) public view returns (address _publisher, address _user) {
        require(claims[_claimId].publisher != address(0), "Invalid ClaimId");
        return (claims[_claimId].publisher, claims[_claimId].user);
    }

    function claimUser(
        address publisher,
        address _user
    ) external onlyPublisherManager {
        require(address(this).balance >= revenuePerUser, "Not Enough Funds");
        IHoldingWallet(holdingWalletAddress).freezeTokens{value: revenuePerUser}(publisher);
        uint m_newId = newId;
        claims[m_newId] = Claim(publisher, _user);
        emit NewClaim(publisher, _user, m_newId);
        m_newId++;
        newId = m_newId;
    }

    function verifyClaim(
        address _caller,
        uint _claimId,
        bool _result
    ) external onlyCampaignManager onlyMarketer(_caller) {
        require(claims[_claimId].publisher != address(0), "Invalid ClaimId");

        Claim memory thisClaim = claims[_claimId];
        address publisher = thisClaim.publisher;
        address user = thisClaim.user;

        if (_result) {
            IHoldingWallet(holdingWalletAddress).freeTokens(publisher, revenuePerUser);
            emit SuccessfulClaim(publisher, user, _claimId);
        } else {
            IHoldingWallet(holdingWalletAddress).revokeTokens(publisher, revenuePerUser);
            emit RevokedClaim(publisher, user, _claimId);
        }

        delete claims[_claimId];
    }

    function withdrawFunds(uint _amount) external onlyMarketer(msg.sender) {
        require(address(this).balance >= _amount, "Not Enough Funds");
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal Failed");
    }
}
