// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/* 
NB: this test file is to try out Governor and AccesControl contracts. 
They are not proper tests (for instance, they miss asserts) 
*/

import {Test, console} from "forge-std/Test.sol";
import {CommunityToken} from "../../src/CommunityToken.sol";
import {GovernedIdentity} from "../../src/GovernedIdentity.sol";
import {LawsPlayground} from "../../src/LawsPlayground.sol"; 

contract GovernedIdentityTest is Test {
    /* events */
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 voteStart,
        uint256 voteEnd,
        string description
    );

    CommunityToken communityToken;
    GovernedIdentity governedIdentity;
    LawsPlayground lawsPlayground; 

    address[] communityMembers = [
        address(1),
        address(2),
        address(3),
        address(4),
        address(5),
        address(6),
        address(7),
        address(8),
        address(9),
        address(10)
    ];

    uint256 proposalId;
    uint256 voteStart = 86_401;
    uint256 voteEnd = 691_201;
    uint256 proposedStateChange = 666666666666;

    modifier distributeAndDelegateCommunityTokens() {
        for (uint256 i; i < communityMembers.length; i++) {
            communityToken.awardIdentity(communityMembers[i]);
            // note: every member delegates to themselves.
            vm.prank(communityMembers[i]);
            communityToken.delegate(communityMembers[i]);
        }

        _;
    }

    modifier createProposal() {
        address[] memory targets = new address[](1);
        targets[0] = address(lawsPlayground);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = (abi.encodeWithSignature("helloWorld(uint256)", proposedStateChange));
        string memory description = "this is a hellowWorld proposal";

        proposalId = governedIdentity.hashProposal(targets, values, calldatas, keccak256(bytes(description)));

        vm.expectEmit(true, false, false, false);
        emit ProposalCreated(
            proposalId,
            communityMembers[0],
            targets,
            values,
            new string[](targets.length),
            calldatas,
            voteStart,
            voteEnd,
            description
        );

        vm.prank(communityMembers[0]);
        governedIdentity.propose(targets, values, calldatas, description);
        _;
    }

    function setUp() public {
        communityToken = new CommunityToken();
        governedIdentity = new GovernedIdentity(communityToken, communityMembers[0]);
        lawsPlayground = new LawsPlayground(address(governedIdentity));
    }

    function test_checkStateProposal() public distributeAndDelegateCommunityTokens createProposal {
        console.log("block number at start:", block.number);

        vm.roll(7_000);
        governedIdentity.state(proposalId);
        console.log("state at block number 7_000", block.number);

        vm.roll(10_000);
        governedIdentity.state(proposalId);
        console.log("state at block number 10_000 roll", block.number);

        vm.roll(100_000);
        governedIdentity.state(proposalId);
        console.log("state at block number 100_000 roll", block.number);
    }

    function test_membersCanVoteProposalWithinTimeFrame() public distributeAndDelegateCommunityTokens createProposal {
        uint8 vote = 1;

        vm.roll(10_000);
        vm.prank(communityMembers[1]);
        governedIdentity.castVote(proposalId, vote);

        vm.prank(communityMembers[2]);
        governedIdentity.castVote(proposalId, vote);

        vm.prank(communityMembers[3]);
        governedIdentity.castVote(proposalId, vote);
    }

    function test_passedProposalCallsExternalFunction() public distributeAndDelegateCommunityTokens createProposal {
        uint256 numberOfYesVotes = 8;
        uint8 vote = 1;

        // voting on proposal...
        vm.roll(10_000);
        for (uint256 i; i < numberOfYesVotes; i++) {
            vm.prank(communityMembers[i]);
            governedIdentity.castVote(proposalId, vote);
        }

        // time roll so vote time passes...
        vm.roll(800_000);
        governedIdentity.state(proposalId);

        // check outcome is indeed succeed:
        (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) = governedIdentity.proposalVotes(proposalId);
        console.log("votes against:", againstVotes);
        console.log("votes for:", forVotes);
        console.log("votes abstain:", abstainVotes);

        // call execute on suceeded proposal:
        address[] memory targets = new address[](1);
        targets[0] = address(lawsPlayground);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = (abi.encodeWithSignature("helloWorld(uint256)", proposedStateChange));
        string memory description = "this is a hellowWorld proposal";
        bytes32 descriptionHash = keccak256(bytes(description));

        // check if target contract state has indeed breen changed.
        governedIdentity.execute(targets, values, calldatas, descriptionHash);
        uint256 result = lawsPlayground.freeStateVar();

        console.log("HELLO WORLD", result);
    }
}
