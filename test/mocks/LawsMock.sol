// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// RBAC: Role Based Access Control.
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {LawTemplate} from "../../src/LawTemplate.sol";

/**
 * @title Mock Laws for testing
 *
 * @author Seven Cedars
 *
 * @notice These is a collection of different types of laws/functions that can be used with the GovernorRestrictedRoles extension.
 * It also gives a general sense of some best practices for law contracts.
 *
 * @dev the role allocation of restricted laws is not decided in this contract: it is set at the Governor contract.
 * This means that Governor contracts decide along what roles laws are restricted.
 *
 * £todo: check gas usage of string descriptions. How bad is it?
 */
contract LawsMock is LawTemplate {
    /* State variables. */
    // £q: I think it is bet practice to keep state variables always in the same contract as the laws. -- avoid reentrancy attack vector.
    uint256 public s_unrestrictedLaw;
    uint256 public s_restrictedLaw;
    uint256 public s_restrictedGovernedLaw;
    uint256 public s_unrestrictedGovernedLaw;

    /* FUNCTIONS */
    /* constructor */
    constructor(address payable governor) LawTemplate(governor) {}

    function unrestrictedLaw(uint256 _var) external {
        string memory description = "An unrestricted law that changes a state variable.";

        s_unrestrictedLaw = _var;

        emit LawTriggered(keccak256(bytes(description)), true);
    }

    function restrictedLaw(uint256 _var) external restricted {
        string memory description = "A role restricted law that changes a state variable.";

        s_restrictedLaw = _var;

        emit LawTriggered(keccak256(bytes(description)), true);
    }

    // note that this law can be called by anyone that hass access to the propose function in a governor.sol derived contract.
    function unrestrictedGovernedLaw(uint256 _var) external onlyGovernance {
        string memory description =
            "An _unrestricted_ law that can only be called through proposals and changes a state variable.";

        s_unrestrictedGovernedLaw = _var;

        emit LawTriggered(keccak256(bytes(description)), true);
    }

    function restrictedGovernedLaw(uint256 _var) external restricted onlyGovernance {
        string memory description =
            "A role restricted law that can only be called through proposals and changes a state variable.";

        s_restrictedGovernedLaw = _var;

        emit LawTriggered(keccak256(bytes(description)), true);
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
