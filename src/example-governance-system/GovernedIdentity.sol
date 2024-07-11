// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
// Started out as contract created through OpenZeppelins contracts wizard.

// see for the following OpenZeppelin docs..
// possible extension to add at later stage: timeLockController.
// although, possibly AccessManager.schedule will work better

// NB: proposalStates = ['Pending', 'Active', 'Canceled', 'Defeated', 'Succeeded', 'Queued', 'Expired', 'Executed'];
// NB:    enum VoteType { Against, For, Abstain }

pragma solidity 0.8.24;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorStorage} from "@openzeppelin/contracts/governance/extensions/GovernorStorage.sol";
import {GovernorVotes, IVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from
    "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorDividedPowers} from "../governor-extensions/GovernorDividedPowers.sol";

// @custom:security-contact cedars7@proton.me
contract GovernedIdentity is
    Governor,
    GovernorSettings,
    GovernorStorage,
    GovernorVotes,
    GovernorDividedPowers
    
{
    // role definitions.
    // Note that it is also possible to set roles through the grantRole function.
    uint64 public constant COUNCILLOR = 1;
    uint64 public constant JUDGE = 2;
    uint64 public constant CITIZEN = 3;

    constructor(IVotes _token, address _initialAdmin)
        Governor("GovernedIdentity")
        GovernorSettings(7200, /* 1 day */ 21600, /* 3 days */ 0)
        GovernorVotes(_token)
        GovernorDividedPowers(_initialAdmin, 30)
    {}

    // The following functions are overrides required by Solidity.

    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    // function quorum(uint256 proposalId)
    //     public
    //     view
    //     override(Governor, GovernorDividedPowers)
    //     returns (uint256)
    // {
    //     return super.quorum(proposalId);
    // }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    function _propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        address proposer
    ) internal override(Governor, GovernorStorage, GovernorDividedPowers) returns (uint256) {
        return super._propose(targets, values, calldatas, description, proposer);
    }

    function _countVote(uint256 proposalId, address account, uint8 support, uint256 weight, bytes memory params)
        internal
        virtual
        override(Governor, GovernorDividedPowers)
    {
        return super._countVote(proposalId, account, support, weight, params);
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual override (Governor, GovernorDividedPowers) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
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
