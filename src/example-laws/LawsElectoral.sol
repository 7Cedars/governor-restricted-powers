// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// £info RBAC: Role Based Access Control.
import {GovernedIdentity} from "../../src/example-governance-system/GovernedIdentity.sol";
import {LawTemplate} from "../../src/example-laws/LawTemplate.sol";

/**
 * @title Example Electoral Laws, to be used in combination with the GovernorDividedPowers extension of Governor.sol.
 *
 * @author Seven Cedars
 *
 * @notice Elector laws elect (or select) accounts to roles.
 * This means the elector law contract needs to be designated ADMIN_ROLE() in the governor contract.
 * This is particular to electoral laws and a reason to place them in a separate contract.
 *
 * As such, be _very_ careful in writing these functions.
 *
 * £todo: check gas usage of string descriptions. How bad is it?
 */
contract LawsElectoral is LawTemplate {
    /* Errors */
    error LawsElectoral_AccountAlreadyCandidate(address account);
    error LawsElectoral_AccountNotCandidate(address account);

    /* State variables. */
    uint256 public constant NUMBER_COUNCILLORS = 3;
    address[] public councillorCandidates;
    mapping(address => bool) isCandidate;
    address[] electedCouncillors;

    /* FUNCTIONS */
    /* constructor */
    constructor(address payable governedIdentity) LawTemplate(governedIdentity) {}

    // authorised role => CITIZEN
    function rewardCitizenship(address newCitizen) external restricted {
        string memory description = "Reward membership role to new account.";

        uint64 citizenRoleId = GovernedIdentity(i_governor).CITIZEN();
        GovernedIdentity(i_governor).grantRole(citizenRoleId, newCitizen, 0);

        emit LawTriggered(keccak256(bytes(description)), true);
    }

    // authorised role => CITIZEN
    function submitCouncillorCandidacy() external restricted {
        string memory description = "Submit your own account as candidate for Councillor.";
        address candidate = _msgSender();

        if (isCandidate[candidate] == true) {
            revert LawsElectoral_AccountAlreadyCandidate(candidate);
        }

        councillorCandidates.push(candidate);
        isCandidate[candidate] = true;

        emit LawTriggered(keccak256(bytes(description)), true);
    }

    // authorised role => CITIZEN
    function renounceCouncillorCandidacy() external restricted {
        string memory description = "Renounce your own candidacy for Councillor.";
        address candidate = _msgSender();
        uint256 numberOfCandidates = councillorCandidates.length;

        if (isCandidate[candidate] == false) {
            revert LawsElectoral_AccountNotCandidate(candidate);
        }

        for (uint256 i; i < numberOfCandidates; i++) {
            if (councillorCandidates[i] == candidate) {
                councillorCandidates[i] == councillorCandidates[numberOfCandidates];
                councillorCandidates.pop();
                isCandidate[candidate] = false;
            }
        }

        emit LawTriggered(keccak256(bytes(description)), true);
    }

    // authorised role => N/A
    // @notice A liquid Democracy approach to electing representative: reelections happen whenever anyone triggers them.
    // @dev this function can be called absolutely anyone at anytime.
    // @dev it is a complecated and expensive function.
    function electCouncillors() external {
        string memory description = "Elects Councillors on basis of their delegated votes.";
        uint256 numberOfCandidates = councillorCandidates.length;
        uint64 councillorRoleId = GovernedIdentity(i_governor).COUNCILLOR();
        address[] memory mostVotesAddresses = new address[](NUMBER_COUNCILLORS);
        uint256[] memory mostVotesAmount = new uint256[](NUMBER_COUNCILLORS);

        // if there are fewer candidate than places, all candidates are elected to councillor role.
        if (numberOfCandidates <= NUMBER_COUNCILLORS) {
            // step 1: revoke roles of existing councillors and clean up the array.
            for (uint256 i; i < electedCouncillors.length; i++) {
                GovernedIdentity(i_governor).revokeRole(councillorRoleId, electedCouncillors[i]);
            }
            electedCouncillors = new address[](NUMBER_COUNCILLORS);

            // step 2: elect new councillors.
            for (uint256 i; i < numberOfCandidates; i++) {
                GovernedIdentity(i_governor).grantRole(councillorRoleId, councillorCandidates[i], 0);
            }
            return;
        }
        // if there are more candidates than places, the candidates with the heighest weighted vote (= delegated votes) are elected.
        else {
            for (uint256 i; i < numberOfCandidates; i++) {
                // step 1: get (weighted) vote of candidate.
                uint256 votesCandidate = GovernedIdentity(i_governor).getVotes(councillorCandidates[i], block.timestamp);
                for (uint256 j; j < NUMBER_COUNCILLORS; j++) {
                    // step 2: check if array (of lenght number candidates) has a vote with a lower value than votesCandidate;
                    if (mostVotesAmount[j] < votesCandidate) {
                        // step 3: if this is the case: save address candidate, and save number of votes.
                        mostVotesAddresses[j] = councillorCandidates[j];
                        mostVotesAmount[j] = votesCandidate;
                        break;
                        // step 4: break the loop for this candidate, go to next candidate.
                    }
                }
            }

            // step 5: revoke roles of existing councillors and clean up the array.
            for (uint256 i; i < electedCouncillors.length; i++) {
                GovernedIdentity(i_governor).revokeRole(councillorRoleId, electedCouncillors[i]);
            }
            electedCouncillors = new address[](NUMBER_COUNCILLORS);

            // step 6: we end up with an array of length == number of candidates, populated with addresses of accounts with heighest weighted votes.
            // we use this array to elect accounts to councillor role.
            for (uint256 i; i < mostVotesAddresses.length; i++) {
                electedCouncillors.push(mostVotesAddresses[i]);
                GovernedIdentity(i_governor).grantRole(councillorRoleId, mostVotesAddresses[i], 0);
            }
        }

        emit LawTriggered(keccak256(bytes(description)), true);
    }

    // authorised role => JUDGE
    function electJudgeByJudges() external restricted onlyGovernance {
        // £todo
    }

    // authorised role => COUNCILLOR
    function electJudgeByCouncillors() external restricted onlyGovernance {
        // £todo
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
