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

abstract contract GovernorDividedPowers is Governor, AccessManager {
    error GovernorDividedPowers__ProposalContainsUnauthorizedCalls(bytes[] calldatas);
    error GovernorDividedPowers__ProposalContainsMultipleRoles(bytes[] calldatas);
    error GovernorDividedPowers__UnauthorizedVote(uint256 proposalId);

    /**
     * @dev Supported vote types. Matches Governor Bravo ordering.
     */
    enum VoteType {
        Against,
        For,
        Abstain
    }

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address voter => bool) hasVoted;
    }

    mapping(uint256 proposalId => ProposalVote) private _proposalVotes;  // additional mapping needed to keep track of role restriction of proposal.
    mapping(uint256 proposalId => uint64 proposalRole) public proposalRole; // additional mapping needed fto keep track of number of accounts that hold roles. Otherwise quorum per role cannot be assessed.  
    mapping(uint64 roleId => uint256) public amountRoleHolders; 
    uint256 public constant QUORUM_DENOMINATOR = 100; 
    uint256 public immutable i_quorum_enumerator;    
    
    /**
     * @param _initialAdmin account that is the initial admin of the governance system.
     */
    constructor(address _initialAdmin, uint256 _quorum_enumerator) AccessManager(_initialAdmin) { 
        i_quorum_enumerator = _quorum_enumerator;  
    }

    /**
     * @notice granting role function. 
     * 
     * @dev at the moment compound roles are not supported.
     * Compound roles are roles that are a combination of other roles. (for example: everyone that is a judge and a councillor is also a citizen. Citizen = compound role)  
     */
    function _grantRole(
        uint64 roleId,
        address account,
        uint32 grantDelay,
        uint32 executionDelay
    ) internal virtual override returns (bool) {
        bool newMember = super._grantRole(roleId, account, grantDelay, executionDelay); 
        amountRoleHolders[roleId]++;   
        return newMember;
    }

    /**
     * @dev Internal version of {revokeRole} without access control. This logic is also used by {renounceRole}.
     * Returns true if the role was previously granted.
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function _revokeRole(uint64 roleId, address account) internal virtual override returns (bool) {
        super._revokeRole(roleId, account); 

        // £ here substract from mapping. -- check if this actually substracts... 
        amountRoleHolders[roleId]--;   

        return true;
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
        
        // if function does not have role restriction, getTargetFunctionRole returns 0, and proposal role is set to public. 
        if (calldatasRole == 0) {
            proposalRole[proposalId] = PUBLIC_ROLE; 
        // Else the role restriction is linked to proposalId in the proposalRole mapping...
        } else {
            proposalRole[proposalId] = calldatasRole;
        }
        // ...and the rest of propose function is called.
        super._propose(targets, values, calldatas, description, proposer);

        return proposalId;
    }

    /**
     * Adds restricted role check to _countVote.
     *
     * @dev this function is an override of the initial (empty) _countVote function in Governor.sol
     * It still needs an additional extention to add the actual voting mechanism.
     * GovernorCountingDividedVotes.sol works well for this.
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support, 
        uint256, /* weight */
        bytes memory /* params */
    ) internal virtual override(Governor) {
        uint64 restrictedToRole = proposalRole[proposalId];
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        (bool hasRole, ) = hasRole(restrictedToRole, account);

        if (restrictedToRole != 0 && hasRole == false) {
            revert GovernorDividedPowers__UnauthorizedVote(proposalId);
        }
        if (proposalVote.hasVoted[account]) {
            revert GovernorAlreadyCastVote(account);
        }
        proposalVote.hasVoted[account] = true;

        // Here weight is excluded.
        if (support == uint8(VoteType.Against)) {
            proposalVote.againstVotes += 1;
        } else if (support == uint8(VoteType.For)) {
            proposalVote.forVotes += 1;
        } else if (support == uint8(VoteType.Abstain)) {
            proposalVote.abstainVotes += 1;
        } else {
            revert GovernorInvalidVoteType();
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
        uint256[]memory  /* values */,
        bytes[] memory calldatas,
        bytes32 /*descriptionHash*/
    ) internal virtual override {

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

 /**
     * @dev See {IGovernor-COUNTING_MODE}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=bravo&quorum=for,abstain";
    }

    /**
     * @dev See {IGovernor-hasVoted}.
     */
    function hasVoted(uint256 proposalId, address account) public view virtual override returns (bool) {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    /**
     * @dev Accessor to the internal vote counts.
     */
    function proposalVotes(uint256 proposalId)
        public
        view
        virtual
        returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes)
    {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return (proposalVote.againstVotes, proposalVote.forVotes, proposalVote.abstainVotes);
    }

    /**
     * @dev Returns the quorum for a timepoint, in terms of number of votes: `supply * numerator / denominator`.
     */
    function quorum(uint256 proposalId) public view virtual override returns (uint256) {
        uint64 role = proposalRole[proposalId]; 
        uint256 amountHolders = amountRoleHolders[role]; 

        // return 20; 

        return (amountHolders * i_quorum_enumerator) / QUORUM_DENOMINATOR; 
    }

    /**
     * @dev See {Governor-_quorumReached}.
     * 
     * @dev change: number of votes is multiplied by the share of all tokens / role holders. 
     * This to account for the fewer people that can vote.  
     */
    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        // return true; 
        // return quorum(proposalSnapshot(proposalId)) <= proposalVote.forVotes + proposalVote.abstainVotes;
        return quorum(proposalId) <= proposalVote.forVotes + proposalVote.abstainVotes; 
    }

    /**
     * @dev See {Governor-_voteSucceeded}. In this module, the forVotes must be strictly over the againstVotes.
     * 
     * @dev As voting is restricted by role (see the _countVote function in GovernorDividedPowers), non authorised votes are not possible. 
     * As a result, we can simply compare for and against votes - as in the original extension - because we will only be comparing votes from accounts with the correct access credentials. 
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId]; 
        return proposalVote.forVotes >= proposalVote.againstVotes;

        // return true; 
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
