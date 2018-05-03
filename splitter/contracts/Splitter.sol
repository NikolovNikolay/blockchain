pragma solidity ^0.4.18;

/** @title Safe math operations */
contract SafeMath {

    // constant value for 0
    uint80 constant NoBalance = uint80(0);

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a && c >= b);
        return c;
    }

    function safeHalf(uint256 amount) internal pure returns (uint256 half) {

        require(amount > NoBalance);
        half = amount / 2;
        require(amount - half == half);
        return half;
    }
}


/** @title Interruptible interface */
contract Interruptible {

    /** @dev Will turn the contract in not running state and
     *       not able to reflect invocation of functions
     *  @return the new state of the contract
     **/
    function interruptContract() public returns (bool) {}

    /** @dev Will turn the contract in running state and
     *       able to reflect invocation of functions
     *  @return the new state of the contract
     **/
    function resumeContract() public returns (bool) {}

}

/** @title Base Contract wrapper with major components */
contract BaseContract {

    // Holds the address of the owner
    address internal owner;
    address constant NoAddress = address(0);

    struct Contributor {
        uint256 _balance;
    }

    // Holds balances for contributors
    mapping(address => Contributor) contributors;

    /** @dev Will return available contributor's balance
     *  @return balance balance of contributor
     **/
    function balanceOf(address holder) constant public returns (uint256) {
        return contributors[holder]._balance;
    }

    /** @dev Will return the contract owner */
    function getOwner() constant public returns (address) {
        return owner;
    }

    /** @dev Will check for valid address
     *  @param _address address to check
     **/
    modifier validAddress(address _address) {
        require(_address != NoAddress);
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
}

/** @title Interruptible token */
contract InterruptibleToken is Interruptible, BaseContract {

    event LogTokenInterrupted();
    event LogTokenResumed();

    // Indicates whether the contract is available to call
    bool internal isRunning;

    function interruptContract()
        public
        isOwner
        returns (bool)
    {
        isRunning = false;
        emit LogTokenInterrupted();
        return isRunning;
    }

    function resumeContract()
        public
        isOwner
        returns (bool)
    {
        isRunning = true;
        emit LogTokenResumed();
        return isRunning;
    }

    function getState()
        public
        constant
        returns (bool)
    {
        return isRunning;
    }

    /** @dev Will continue execution only if the contract
     *       is in active state
     **/
    modifier ifRunning() {
        require(isRunning);
        _;
    }
}

/** @title Amount splitter */
contract AmmountSplitter is SafeMath, InterruptibleToken {

    event LogSplitAmount(
        address indexed sender,
        address indexed firstRecipient,
        address indexed secondRecipient,
        uint256 recipientSplitAmount);

    /** @dev Will split the transferred amount between two recipients
     *  @param firstRecipient first address to add split amount to
     *  @param secondRecipient seconds address to add split amount to
     *  @return if success will return true, else will revert
     */
    function splitAmount(
        address firstRecipient,
        address secondRecipient
    )
        public
        ifRunning
        payable
        validAddress(firstRecipient)
        validAddress(secondRecipient)
        returns (bool)
    {

        if (owner == firstRecipient || owner == secondRecipient) {
            revert();
        }

        uint256 split = safeHalf(msg.value);
        contributors[firstRecipient]._balance =
            safeAdd(contributors[firstRecipient]._balance, split);
        contributors[secondRecipient]._balance =
            safeAdd(contributors[secondRecipient]._balance, split);

        // Check if the sum can not be split equally to two halves.
        // If so add the remainder to the sender's balance in the
        // contract
        uint256 remainder = msg.value - (2 * split);
        if (remainder > 0) {
            contributors[msg.sender]._balance = 
                safeAdd(contributors[msg.sender]._balance, remainder);
        }
        emit LogSplitAmount(msg.sender, firstRecipient, secondRecipient, split);
        return true;
    }
}

contract Splitter is AmmountSplitter {

    constructor() public {
        owner = msg.sender;
        resumeContract();
    }
}