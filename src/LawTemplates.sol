// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// RBAC: Role Based Access Control.
import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";

contract LawTemplates is AccessManaged {
    /* Type declarations */

    /* State variables */
    uint256 public freeStateVar;
    uint256 public restrictedStateVar;
    uint256 public internallySetStateVar;
    
    /* Events */
    event FallbackTriggered(address indexed sender);

    /* Modifiers */

    /* FUNCTIONS */
    /* constructor */
    constructor(address manager) AccessManaged(manager) { }

    /* receive function (if exists) */
    /* fallback function (if exists) */
    fallback() external {
        emit FallbackTriggered(msg.sender);
    }

    function helloWorld(uint256 _var) external {
        freeStateVar = _var;
    }

    function helloWorldRestricted(uint256 _var) external restricted returns (bytes32 role) {
        restrictedStateVar = _var;
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
