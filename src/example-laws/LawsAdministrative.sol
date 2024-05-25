// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {GovernedIdentity} from "../../src/example-governance-system/GovernedIdentity.sol";
import {LawTemplate} from "../../src/example-laws/LawTemplate.sol";

/**
 * @title Example Administrative Laws, to be used in combination with the GovernorRestrictedRoles extension of Governor.sol.
 *
 * @author Seven Cedars
 *
 * @notice Administrative laws manage checks and balances between roles.
 * This means these laws always take a proposalId from another role as input, and apply a subsequent check or balance.
 * This is particular to administrative law and what sets them apart from other laws.
 *
 * £todo: check gas usage of string descriptions. How bad is it?
 */
contract LawsAdministrative is LawTemplate {
    /* Errors */

    /* State variables. */

    /* FUNCTIONS */
    /* constructor */
    constructor(address payable governedIdentity) LawTemplate(governedIdentity) {}

    // role restriction JUDGE();
    function JudgesCancelCouncillorProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external restricted onlyGovernance {
        // £todo
        // start with recreating proposalID
        // then checking if proposal indeed exists and is from councillor.

        // then: call _cancel function. -- this function can be called at any time.
    }

    // role restriction JUDGE();
    function JudgesReinstateCitizenship(
        // all this should be data of _original_ call!
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        int256 callId
    ) external restricted onlyGovernance {
        // £todo
        // start with recreating proposalID
        // then check if proposal id exists.
        // if callId != -1:
        // check each index: are they indeed to revokeRole function & contract?
        // if call == -1
        // check all in array:  are they indeed to revokeRole function & contract?

        // call awardRole on those that are to correct functions.
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
