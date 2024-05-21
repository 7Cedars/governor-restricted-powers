// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// RBAC: Role Based Access Control.
import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {DoubleEndedQueue} from "@openzeppelin/contracts//utils/structs/DoubleEndedQueue.sol";

contract LawTemplates is AccessManaged {
    // See modifier onlyGovernance() below for explanation.  
    // using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    /* Errors  */
    error GovernorOnlyExecutorOfLaw(address sender); 

    /* Type declarations */
    // See modifier onlyGovernance() below for explanation. 
    // DoubleEndedQueue.Bytes32Deque private _governanceCall;

    /* State variables */
    uint256 public freeStateVar;
    uint256 public restrictedStateVar;
    uint256 public internallySetStateVar;

    address private immutable i_governor; 
    
    /* Events */
    event FallbackTriggered(address indexed sender);

    /* Modifiers */
    // This modifier is a simplified version of the onlyGovernance modifier in Governor.sol.
    // In this case, it just checks if calls are made from the Governor contract, ensuring they are called through a governance process. 
    //  
    // for a detailed explanation, see governor.sol.  
    modifier onlyGovernance() {
        if (i_governor != _msgSender()) {
            revert GovernorOnlyExecutorOfLaw(_msgSender());
        }
        _;
    }

     

    /* FUNCTIONS */
    /* constructor */
    constructor(address governor) AccessManaged(governor) {
        i_governor = governor; 
     }

    /* receive function (if exists) */
    /* fallback function (if exists) */
    fallback() external {
        emit FallbackTriggered(msg.sender);
    }

    function helloWorld(uint256 _var) external {
        freeStateVar = _var;
    }

    // This is a first basic outline of what a law should look like. 
    function helloWorldRestricted(uint256 _var) external restricted returns (bool success, bytes32 hashDescription) {
        // human readable description law.  
        string memory description = "this is a test law";

        // related function of law. 
        restrictedStateVar = _var; 

        // returns true as check of function execution; descriptionHash as extra check if correct law has been executed.
        return(true, keccak256(bytes(description))); 
    }

    /* public */
    /* internal */
    function _internalLaw(uint256 _var) internal {
      internallySetStateVar = _var; 
    }
    /* private */
}

// Structure contract // -- from Patrick Collins.
/* version */
/* imports */
/* errors */
/* interfaces, libraries, contracts */
/* Type declarations */
/* State variables */
/* Events */
/* Modifiers */

/* FUNCTIONS: */
/* constructor */
/* receive function (if exists) */
/* fallback function (if exists) */
/* external */
/* public */
/* internal */
/* private */
/* internal & private view & pure functions */
/* external & public view & pure functions */
