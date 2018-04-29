pragma solidity ^0.4.18;

contract InterruptibleContract {

    bool internal isRunning;

    function interruptContract() internal {
        isRunning = false;
    }

    function resumeContract() internal {
        isRunning = true;
    }

}

contract Splitter is InterruptibleContract {

    address private owner;

    address private bobAddress;
    address private carolAddress;

    constructor(address _bobAddress, address _carolAddress) public {
        owner = msg.sender;

        bobAddress = _bobAddress;
        carolAddress = _carolAddress;

        resumeContract();
    }
}