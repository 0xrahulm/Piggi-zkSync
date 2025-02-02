//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract FeEx {
    uint8 public constant decimals = 33;
    // Feedback in the range of 0-10
    uint256 constant positiveFeedBackThreshold = 7;
    uint256 constant negativeFeedBackThreshold = 5;
    // Maximum Experience Change in two consecutive transactions : 0.05
    uint256 constant maxExpChange = 5;
    // The decrease rate : 1.6, to model faster loss with bad behaviour
    uint256 constant decreaseFactor = 16;
    // Minimum decay value : 0.005
    uint256 constant minimumDecay = 5;
    // Decay rate : 0.005
    uint256 constant decayRate = 5;

    struct ExpStruct {
        // maximum is 1**10
        uint112 currExp;
        uint112 prevExp;
        uint24 perCount;
        bool ratedBefore;
    }

    mapping(address => mapping(address => ExpStruct)) private expInfo;

    mapping(address => bool) private oldUser;
    address[] public users;

    address private publisherManager;
    address private campaignManager;

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyManagers() {
        require(
            msg.sender == publisherManager || msg.sender == campaignManager,
            "Only manager"
        );
        _;
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }

    function setPublisherManager(address _publisherManager) external onlyAdmin {
        publisherManager = _publisherManager;
    }

    function setCampaignManager(address _campaignManager) external onlyAdmin {
        campaignManager = _campaignManager;
    }

    function enableFeedbackFrom(address _from) external {
        _enableFeedback(_from, msg.sender);
    }

    function enableInteractionFeedback(
        address _from,
        address _to
    ) external onlyManagers {
        _enableFeedback(_from, _to);
    }

    function _enableFeedback(address _from, address _to) private {
        ++expInfo[_from][_to].perCount;
    }

    function giveFeedback(address _to, uint _feedback) external {
        _giveFeedback(msg.sender, _to, _feedback);
    }

    function _giveFeedback(address _from, address _to, uint _feedback) private {
        ExpStruct memory exp = expInfo[_from][_to];
        require(exp.perCount > 0, "Not eligible to provide feedback");
        require(0 <= _feedback && _feedback <= 10, "Invalid Feedback Value");

        if (oldUser[_from] == false) {
            users.push(_from);
            oldUser[_from] = true;
        }

        if (oldUser[_to] == false) {
            users.push(_to);
            oldUser[_to] = true;
        }

        // Initial experience set to 0.5
        if (exp.ratedBefore == false) {
            exp.prevExp = 5 * (10 ** 32);
            exp.currExp = 5 * (10 ** 32);
            exp.ratedBefore = true;
        }
        uint currentExp = exp.currExp;
        uint prevExp = exp.prevExp;
        uint newExp;

        if (_feedback >= 7) {
            // Positive FeedBack : Increase Model

            newExp =
                currentExp +
                _feedback *
                5 *
                (10 ** 30 - (currentExp / 10 ** 3));
        } else if (_feedback <= 5) {
            // Negative Feedback : Decrease Model

            uint decreaseAmount = (10 - _feedback) *
                5 *
                16 *
                (10 ** 29 - (currentExp / 10 ** 4));
            newExp = 0;
            if (currentExp > decreaseAmount) {
                newExp = currentExp - decreaseAmount;
            }
        } else {
            // Neutral Feedback : Decay Model
            uint decreaseAmount = 5 *
                (10 ** 30 + (10 ** 27) * 5 - (prevExp / 10 ** 3));
            newExp = 0;
            if (currentExp > decreaseAmount) {
                newExp = currentExp - decreaseAmount;
            }
        }

        exp.prevExp = uint112(currentExp);
        exp.currExp = uint112(newExp);
        exp.perCount--;
        expInfo[_from][_to] = exp;
    }

    function viewExperience(
        address _from,
        address _to
    ) external view returns (uint, bool) {
        return (expInfo[_from][_to].currExp, expInfo[_from][_to].ratedBefore);
    }

    function permissionCount(
        address _from,
        address _to
    ) external view returns (uint) {
        return expInfo[_from][_to].perCount;
    }

    function numofUsers() external view returns (uint) {
        return users.length;
    }
}
