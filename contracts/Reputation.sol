//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Reputation{
    uint8 immutable decimals = 33;
    mapping(address => uint) public RepPos;
    mapping(address => uint) public RepNeg;
    address public immutable  admin;

    struct AddressReputation{
        address party;
        uint reputation;
    }
    constructor(){
        admin = msg.sender;
    }

    event RequestReputationCalculation();

    modifier onlyAdmin {
        require(msg.sender == admin,"Only Admin");
        _;
    }

    function requestCalculation() public {
        emit RequestReputationCalculation();
    }

    function updateReputation(AddressReputation[] calldata _positiveRep,AddressReputation[] calldata _negativeRep) external onlyAdmin {
        //update repPos
        for(uint i=0;i<_positiveRep.length;i++){
            RepPos[_positiveRep[i].party] = _positiveRep[i].reputation;
        }
        //update repNeg
        for(uint i=0;i<_negativeRep.length;i++){
            RepNeg[_negativeRep[i].party] = _negativeRep[i].reputation;
        }
    }
}