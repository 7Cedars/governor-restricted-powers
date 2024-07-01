// SPDX-License-Identifier: MIT
// DERIVED FROM: OpenZeppelin Contracts (last updated v5.0.0) (governance/extensions/GovernorCountingSimple.sol)

pragma solidity ^0.8.20;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorDividedPowers} from "./GovernorDividedPowers.sol";  

/**
 * @dev Extension of {Governor} for simple, 3 options, vote counting.
 * @dev this version is exact copy of GovernorCountingSimple, except that weights of votes are excluded.
 * every vote counts once.
 * This is often a the easiest way to vote when governance is divided by roles.
 */
abstract contract GovernorCountingDividedVotes is Governor, GovernorVotes {
    /**
     * @dev Supported vote types. Matches Governor Bravo ordering.
     */
    enum VoteType {
        Against,
        For,
        Abstain
    }

    GovernorDividedPowers governorDividedPowers; // NB! NOT designated => returns address(0).  

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address voter => bool) hasVoted;
    }

    mapping(uint256 proposalId => ProposalVote) private _proposalVotes;

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
     * @dev See {Governor-_quorumReached}.
     * 
     * @dev change: number of votes is multiplied by the share of all tokens / role holders. 
     * This to account for the fewer people that can vote.  
     */
    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        // uint64 role = governorDividedPowers.proposalRole(proposalId); 
        uint256 amountHolders = governorDividedPowers.amountRoleHolders(18446744073709551615); 
        // uint256 amountHolders = governorDividedPowers.amountRoleHolders(role); 

        return true; 
        // original: return quorum(proposalSnapshot(proposalId)) <= proposalVote.forVotes + proposalVote.abstainVotes;
        // return quorum(proposalSnapshot(proposalId)) <= (proposalVote.forVotes + proposalVote.abstainVotes) / amountHolders; -- Divide by 0! 
    }

    /**
     * @dev See {Governor-_voteSucceeded}. In this module, the forVotes must be strictly over the againstVotes.
     * 
     * @dev As voting is restricted by role (see the _countVote function in GovernorDividedPowers), non authorised votes are not possible. 
     * As a result, we can simply compare for and against votes - as in the original extension - because we will only be comparing votes from accounts with the correct access credentials. 
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId]; 
        // return proposalVote.forVotes >= proposalVote.againstVotes;

        return true; 
    }

    /**
     * @dev See {Governor-_countVote}. In this module, the support follows the `VoteType` enum (from Governor Bravo).
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256, /*weight */
        bytes memory // params
    ) internal virtual override {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        if (proposalVote.hasVoted[account]) {
            revert GovernorAlreadyCastVote(account);
        }
        proposalVote.hasVoted[account] = true;

        // Here weight is exlcuded.
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
}
