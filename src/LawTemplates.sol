// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// RBAC: Role Based Access Control.
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract LawTemplates is AccessControl {
    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER");
    bytes32 public constant COUNCILLOR_ROLE = keccak256("COUNCILLOR");
    bytes32 public constant JUDGE_ROLE = keccak256("JUDGE");

    /* State variables */
    uint256 public freeStateVar;
    uint256 public restrictedStateVar;

    /* Events */
    event IncorrectSelector(address indexed sender);

    /* Modifiers */

    /* FUNCTIONS */
    /* constructor */
    constructor() {
        // Grant the contract deployer the default admin role: it will be able
        // to grant and revoke any roles
    }

    /* receive function (if exists) */
    /* fallback function (if exists) */
    fallback() external {
        emit IncorrectSelector(msg.sender);
    }

    function helloWorld(uint256 _var) external {
        freeStateVar = _var;
    }

    function helloWorldRestricted(uint256 _var) external onlyRole(COUNCILLOR_ROLE) {
        restrictedStateVar = _var;
    }

    /**
     * @notice These functions are external and have no access control. For now, anyone can asign roles.
     * This will change in the near future.
     *
     */
    function awardMemberRole(address member) external {
        _grantRole(MEMBER_ROLE, member);
    }

    function awardCouncillorRole(address councillor) external {
        _grantRole(COUNCILLOR_ROLE, councillor);
    }

    function awardJudgeRole(address judge) external {
        _grantRole(JUDGE_ROLE, judge);
    }

    /* public */
    /* internal */
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
