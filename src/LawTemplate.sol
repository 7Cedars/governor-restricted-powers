// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// RBAC: Role Based Access Control.
import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";

contract LawTemplate is AccessManaged {

    /* Errors  */
    error GovernorOnly(address sender); 

    /* State variables */
    address private immutable i_governor; 
    
    /* Events */
    event FallbackTriggered(address indexed sender);
    event LawsDeployed(address indexed governorContract);

    /* Modifiers */
    /**
     * This modifier is a simplified version of the onlyGovernance modifier in Governor.sol.
     *  In this case, it just checks if calls are made from the Governor contract, ensuring they are called through a governance process. 
     * for a detailed explanation of the original onlyGovernance modifier, see governor.sol.  
     */
    modifier onlyGovernance() {
        if (i_governor != _msgSender()) {
            revert GovernorOnly(_msgSender());
        }
        _;
    }

    /* FUNCTIONS */
    /* constructor */
    constructor(address governor) AccessManaged(governor) {
        i_governor = governor; 

        emit LawsDeployed(governor);
     }

    /* receive function (if exists) */
    /* fallback function (if exists) */
    fallback() external {
        emit FallbackTriggered(msg.sender);
    }
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
