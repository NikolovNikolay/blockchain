pragma solidity ^0.4.18;

/** @title Interruptible interface contract*/
contract InterruptibleContract {
    
    // Indicates whether the contract is available to call
    bool internal isRunning;
    
    /** @dev Will turn the contract in not running state and 
     *       not able to reflect invocation of functions
     *  @return currentState if the contract is active
     **/
    function interruptContract() internal returns(bool currentState) {
        isRunning = false;
        return true;
    }

    /** @dev Will turn the contract in running state and 
     *       able to reflect invocation of functions
     *  @return currentState if the contract is active
     **/
    function resumeContract() internal returns (bool currentState) {
        isRunning = true;
        return currentState;
    }
    
    /** @dev Will continue execution only if the contract
     *       is in active state
     **/
    modifier ifRunning() {
        if (!isRunning) {
            revert();
        }
        _;
    }
}

contract Splitter is InterruptibleContract {

    // Holds the address of the owner
    address private owner;

    // Holds balances for contributors
    mapping(address => uint256) private balances;

    constructor() public {
        owner = msg.sender;

        resumeContract();
    }
}