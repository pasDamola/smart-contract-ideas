// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract Guugle is KeeperCompatibleInterface {
    address public employer;
    address public employee;
    uint256 amountToBePaidPerMonth;
    uint256 contractPeriod;
    uint256 paymentInterval;
    /*
        interval - in seconds
        we can set this to 2592000, which will be the number of seconds in a month
    */
    uint256 interval;
    uint256 lastTimeStamp;


    /// The provided value has to be equal to full contract payment.
    error ValueNotEnough();


    constructor(uint256 _interval, address _employee, uint256 _contractPeriod, uint256 _amountToBePaidPerMonth) payable {
        employer = msg.sender;
        employee = _employee;
        interval = _interval;
        lastTimeStamp = block.timestamp;
        amountToBePaidPerMonth = _amountToBePaidPerMonth;
        contractPeriod = _contractPeriod;
        if(msg.value != ((amountToBePaidPerMonth * contractPeriod) * 10 ** 18)) {
            revert ValueNotEnough();
        }
    }


    function checkUpkeep(bytes calldata /* checkData */) external override view  returns (bool upkeepNeeded, bytes memory /* performData */) {
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata /* performData */) external override  {
        if(block.timestamp - lastTimeStamp > interval) {
            lastTimeStamp = block.timestamp;
            paySalary();
        }
    }

    function paySalary() public {
        // automated process
        (bool success, ) = payable(employee).call{value: amountToBePaidPerMonth}("");
        require(success, "Transfer failed");
    }
}