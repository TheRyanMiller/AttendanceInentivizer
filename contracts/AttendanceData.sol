pragma solidity ^0.4.11;

contract AttendanceData {

  struct Attendee {
    string name;
    uint amountDonated;
    uint lastAttendedEvent;
    uint totalEventsAttended;
    mapping(address => Validator) validators;
    address[] validatorList;
    uint256 listPointer;
  }

  struct Validator {
    bool hasValidated;
    uint256 listPointer;
    uint eventId;
  }

  uint eventId; //start at 0, iterate up for each event
  mapping(address => Attendee) public attendees;
  address[] public attendeeList;
  mapping(address => uint) public winnings; //map addresses to their winnings balance
  address[] public eventResults; //track winners of each event
  uint public unclaimedValue; //total unclaimed value in the contract (available only to winners)
  uint public currentEventValue; //value of current meetup
  address public owner;

  modifier onlyBy(address _account){
    require(msg.sender == _account);
    // Do not forget the "_;"! It will
    // be replaced by the actual function
    // body when the modifier is used.
    _;
  }

  function AttendanceData() public {
    unclaimedValue=0;
    currentEventValue=0;
    owner = msg.sender;
  }

  function isAttendee(address attendeeAddress) public constant returns(bool isAttendee) {
    if(attendeeList.length == 0) return false;
    return (attendeeList[attendees[attendeeAddress].listPointer] == attendeeAddress
        && attendees[attendeeAddress].lastAttendedEvent == eventId
      );
  }

  function hasPastAttendeeRecord(address attendeeAddress) public constant returns(bool isAttendee) {
    return (attendees[attendeeAddress].lastAttendedEvent != eventId
              && attendees[attendeeAddress].lastAttendedEvent >= 0);
  }

  /*
    Check if a particular address has already validated an attendee
      1. Ensure attendee exists
      2. Grab validator object from attendee struct
      3.
  */
  function hasValidated(address attendeeAddress, address validatorAddress) public constant returns(bool hasValidated) {
    if(attendees[attendeeAddress].validatorList.length == 0) return false;
    if(isAttendee(attendeeAddress)) throw;
    return attendees[attendeeAddress].validators[validatorAddress].hasValidated;
  }

  function getAttendeeCount() public constant returns(uint attendeeCount) {
    return attendeeList.length;
  }

  function newAttendee(address attendeeAddress, string name, uint amountDonated) public payable returns(bool success) {
    /*
      Adding new attendee:
        1. Make sure attendee doesn't already exist
        2. Add AttendeeStruct data to mapping
        3. Push address onto array
    */
    if(isAttendee(attendeeAddress)) throw;
    if(hasPastAttendeeRecord(attendeeAddress)){
      updateAttendee(attendeeAddress, name, amountDonated);
      attendees[attendeeAddress].listPointer = attendeeList.push(attendeeAddress) - 1;
      attendees[attendeeAddress].lastAttendedEvent = eventId;
      attendees[attendeeAddress].totalEventsAttended++;
      return true;
    }
    else{
      attendees[attendeeAddress].name = name;
      attendees[attendeeAddress].lastAttendedEvent = eventId;
      attendees[attendeeAddress].amountDonated = amountDonated;
      attendees[attendeeAddress].listPointer = attendeeList.push(attendeeAddress) - 1;
      attendees[attendeeAddress].totalEventsAttended=1;
      return true;
    }
  }

  function updateAttendee(address attendeeAddress, string name, uint amountDonated) private returns(bool success) {
    if(!isAttendee(attendeeAddress)) throw;
    attendees[attendeeAddress].name = name;
    attendees[attendeeAddress].lastAttendedEvent = eventId;
    attendees[attendeeAddress].amountDonated = amountDonated;
    currentEventValue+=amountDonated;
    unclaimedValue+=amountDonated;
    return true;
  }

  function updateAttendeeName(address attendeeAddress, string name) public returns(bool success) {
    if(!isAttendee(attendeeAddress)) throw;
    attendees[attendeeAddress].name = name;
    return true;
  }

  function validate(address attendeeAddress, address validatorAddress) public returns(bool success) {
    if(!isAttendee(attendeeAddress)) throw; //Make sure that validatee is an attendee
    if(!isAttendee(validatorAddress)) throw;//Make sure that validator is an attendee too
    if(hasValidated(attendeeAddress, validatorAddress)) throw; // check if already validated before
    attendees[attendeeAddress].validators[validatorAddress].hasValidated = true;
    attendees[attendeeAddress].validators[validatorAddress].listPointer = attendees[attendeeAddress].validatorList.push(validatorAddress) - 1;
    return true;
  }

  function deleteAttendee(address attendeeAddress) public returns(bool success) {
    if(!isAttendee(attendeeAddress)) throw;
    uint rowToDelete = attendees[attendeeAddress].listPointer; // array index of specified address
    address keyToMove = attendeeList[attendeeList.length-1]; // address at last position
    attendeeList[rowToDelete] = keyToMove; //set address of deleted index, to address of last index
    attendees[keyToMove].listPointer = rowToDelete; // update pointer of last
    attendeeList.length--;
    return true;
  }

  function payout() public returns(bool success) {
    require (attendeeList.length>0);
    address winner = calculateWinner();
    winnings[winner] += currentEventValue;
    currentEventValue = 0;
    resetAttendance();
    return true;
  }

  function resetAttendance() private returns(bool success){
    //Can only be run by .payOut()
    attendeeList.length=0;
    currentEventValue=0;
    eventId++;
    return true;
  }

  function collectWinnings(address caller) public returns(bool success){
    //Can only be run by .payOut()
    if(winnings[caller] > 0) throw;
    caller.transfer(winnings[caller]);
    return true;
  }

  function calculateWinner() private view returns(address) {
    /*THIS SECTION NEEDS WORK
      1. Grab list of validated addresses
      2. Add ransomized selection algorithm
    */
    return attendeeList[0];
  }


}
