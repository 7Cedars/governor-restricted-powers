// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// RBAC: Role Based Access Control.
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {LawTemplate} from "./LawTemplate.sol"; 

contract LawsPlayground is LawTemplate {

    /* State variables */
    uint256 public freeStateVar;
    uint256 public restrictedStateVarOne;
    uint256 public restrictedStateVarTwo;
   

    /* FUNCTIONS */
    /* constructor */
    constructor(address governor) LawTemplate(governor) { }

    function helloWorld(uint256 _var) external {
        freeStateVar = _var;
    }

    // This is a first basic outline of what a law should look like. 
    function helloWorldRestrictedOne(uint256 _var) external restricted returns (bool success, bytes32 hashDescription) {
        // human readable description law.  
        string memory description = "this is a test law";

        // related function of law. 
        restrictedStateVarOne = _var; 

        // returns true as check of function execution; descriptionHash as extra check if correct law has been executed.
        return(true, keccak256(bytes(description))); 
    }

        // This is a first basic outline of what a law should look like. 
    function helloWorldRestrictedTwo(uint256 _var) external restricted onlyGovernance returns (bool success, bytes32 hashDescription) {
        // human readable description law.  
        string memory description = "this is a test law";

        // related function of law. 
        restrictedStateVarTwo = _var; 

        // returns true as check of function execution; descriptionHash as extra check if correct law has been executed.
        return(true, keccak256(bytes(description))); 
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
