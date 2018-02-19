pragma solidity ^0.4.11;

import "./AttendanceDataInterface.sol";

contract AttendanceIncentivizer {
  event Donate(address indexed donater, uint indexed amount);
  event Payout(address indexed donater, uint indexed amount);
  event Validate(address indexed validator, address indexed validatee);


  uint constant minimumDonation = 1;
  address private owner;
  address private datastore;
  AttendanceDataInterface adi;

  modifier onlyBy(address _account){
    require(msg.sender == _account);
    // Do not forget the "_;"! It will
    // be replaced by the actual function
    // body when the modifier is used.
    _;
  }

  function updateDatastore(address newDatastore) public onlyBy(owner){
    datastore = newDatastore;
    adi = AttendanceDataInterface(datastore);
  }

  function updateOwner(address newOwner) public onlyBy(owner){
    owner = newOwner;
  }

  function AttendanceIncentivizer(address _datastore) public {
    owner = msg.sender;
    datastore = _datastore;
    adi = AttendanceDataInterface(datastore);
  }

  function donate(string name) public payable returns(bool success) {
    //require(msg.value >= minimumDonation);
    if(msg.value==0) throw;
    if(!adi.newAttendee(msg.sender, name, msg.value)) throw;
    datastore.transfer(msg.value);
    Donate(msg.sender, msg.value); //Event
    return true;
  }

  function validate(address validatee) public {
    require (validatee != msg.sender); //Require validator is not same as validatee
    if(!adi.validate(validatee, msg.sender)) throw;
    Validate(msg.sender, validatee); //Log event
  }

  function payout() public returns (bool success){
    return adi.payout();
  }

}
