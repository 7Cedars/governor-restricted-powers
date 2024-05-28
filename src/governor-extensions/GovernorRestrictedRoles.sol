// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// modifier to restrict who can propose and vote on proposals based on restriction of fucntion that proposal calls.
// notice the input. The function that get this modifier need to have these inputs.
// 1: function _propose
// 2: NB function _castVote works with proposalId :D
// 3: function _cancel -- works with target values and calldatas. NOTE: only cancable by the proposer Does NOT need additional check.
// 4: function _executeOperations / execute: NOT needed. Only executes successful proposals - that already are role restricted.
// there might be cases where you want execution not to be restricted.
// queu? - redundant
// relay? - redundant

// what about
// 6: grantRole
// 7: labelRole?
// revokeRole
// setRoleAdmin...
// etc: all functions related to admin and setting role. I have to deal with those. Should only be callable through external / governance functions

import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

abstract contract GovernorRestrictedRoles is Governor, AccessManager {
    // needs to be immutable & part of constructor args when transforming this into extension.

    error GovernorDividedPowers__ProposalContainsUnauthorizedCalls(bytes[] calldatas);
    error GovernorDividedPowers__ProposalContainsMultipleRoles(bytes[] calldatas);
    error GovernorDividedPowers__UnauthorizedVote(uint256 proposalId);

    // additional mapping needed to keep track of role restriction of proposal.
    mapping(uint256 proposalId => uint64) private _proposalsRole;

    /**
     * @param _initialAdmin account that is the initial admin of the governance system.
     */
    constructor(address _initialAdmin) AccessManager(_initialAdmin) {

    }

    /**
     * Overriding the propose function with two additional checks
     * if proposal contains calls to functions that are not callable by proposer.
     * if proposal calls functions that all have the same role restriction. Mixed role restrictions in one proposal are not allowed.
     *
     * Tricky think is that one proposal can call _multiple_ functions. How to deal with this?
     * For now, the whole proposal fails.
     *
     * @dev I choose not to take proposal Id from function I override. It is inefficient, but the logic of the function becomes odd as a result. Felt unsafe.
     *
     */
    function _propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        address proposer
    ) internal virtual override returns (uint256 proposalId) {
        proposalId = hashProposal(targets, values, calldatas, keccak256(bytes(description)));
        bytes4 functionSelector = bytes4(calldatas[0]); // selector fo first function 
        uint64 calldatasRole = getTargetFunctionRole(targets[0], functionSelector); // role restriction of first function. 

        // Check 1: in case there are more than 1 calldatas slots, check if all have the same role restriction as function 0.
        // if not, revert everything
        if (calldatas.length > 1) {
            for (uint256 i = 1; i < calldatas.length; i++) {
                functionSelector = bytes4(calldatas[i]);
                uint64 role = getTargetFunctionRole(targets[i], functionSelector);
                if (calldatasRole != role) {
                    revert GovernorDividedPowers__ProposalContainsMultipleRoles(calldatas);
                }
            }
        }

        // check 2: does proposer have the correct authenticated role?
        (bool hasRole,) = hasRole(calldatasRole, proposer);
        if (
            calldatasRole != 0 && // if function does not have role restriction, getTargetFunctionRole returns 0. 
            !hasRole) 
            {
            revert GovernorDividedPowers__ProposalContainsUnauthorizedCalls(calldatas);
        }

        // if checks pass, the role restriction is linked to proposalId in the _proposalsRole mapping...
        _proposalsRole[proposalId] = calldatasRole;
        // ...and the rest of propose function is called.
        super._propose(targets, values, calldatas, description, proposer);

        return proposalId;
    }

    /**
     * Add check to count vote.
     *
     * @dev this function is an override of the initial (empty) _countVote function in Governor.sol
     * It still needs an additional extention to add the actual voting mechanism.
     * GovernorCountingVoteSuperSimple.sol works well for this.
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8, /* support */
        uint256, /* weight */
        bytes memory /* params */
    ) internal virtual override(Governor) {
        uint64 restrictedToRole = _proposalsRole[proposalId];
        (bool hasRole,) = hasRole(restrictedToRole, account);
        if (!hasRole) {
            revert GovernorDividedPowers__UnauthorizedVote(proposalId);
        }
    }

        /**
     * @dev Internal execution mechanism. Can be overridden (without a super call) to modify the way execution is
     * performed (for example adding a vault/timelock).
     *
     * NOTE: Calling this function directly will NOT check the current state of the proposal, set the executed flag to
     * true or emit the `ProposalExecuted` event. Executing a proposal should be done using {execute} or {_execute}.
     */
    function _executeOperations(
        uint256 /* proposalId */,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 /*descriptionHash*/
    ) internal virtual override {


// NB! this now seems to always pass - but NOT change any state. 
        for (uint256 i = 0; i < targets.length; ++i) {
            // NB: I encode calldata to send a call to my own contract: the execute call from {AccessManager}. Mental. 
            // This kind of works!! use DELEGATEcall, to the contract that uses this extension. It does not seem to be a problem, because it is a delegateCall to the same contract. 
            // The use of delegateCall transfers the msg.sender of primary call into the execute function inherited from {AccessManager}. 
            // this in turn calls the function at external laws contract via {functionCallWithValue} - and changes state of external Law contract.  
            // £additional issue: This does mean that no value can be send throguh function; as delegateCall does not allow this. 
            bytes memory dataCall= abi.encodeWithSignature("execute(address,bytes)", targets[i], calldatas[i]); 
            (bool success, bytes memory returndata) = address(this).delegatecall(dataCall);
            Address.verifyCallResult(success, returndata);
        }
    }
}
