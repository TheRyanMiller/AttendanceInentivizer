pragma solidity ^0.4.19;

contract AttendanceDataInterace {
    function validate(address attendeeAddress, address validatorAddress) public returns (bool success);
    function newAttendee(address attendeeAddress, string name, uint amountDonated) public returns (bool success);
    function deleteAttendee(address attendeeAddress) public returns(bool success);
    function updateAttendeeName(address attendeeAddress, string name) public returns(bool success);
    function getAttendeeCount() public constant returns(uint attendeeCount);
    function hasValidated(address attendeeAddress, address validatorAddress) public constant returns(bool hasValidated);
    function hasPastAttendeeRecord(address attendeeAddress) public constant returns(bool isAttendee);
    function isAttendee(address attendeeAddress) public constant returns(bool isAttendee);
    function payout() public returns(bool success);
    function collectWinnings(address caller) private returns(bool success);
    
}
