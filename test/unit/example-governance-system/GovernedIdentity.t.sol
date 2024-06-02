// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {GovernedIdentity} from "../../../src/example-governance-system/GovernedIdentity.sol";
import {LawsMock} from "../../mocks/LawsMock.sol";
import {CommunityTokenMock} from "../../mocks/CommunityTokenMock.sol";

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

    CommunityTokenMock communityToken;
    GovernedIdentity governedIdentity;
    LawsMock lawsMock;

    address[] communityMembers = new address[](100); // we create a community of a hundred members. 

    uint256 proposalId;
    uint256 voteStart = 8_000;
    uint256 voteEnd = 50_000;
    uint256 proposedStateChange = 666666666666;

    modifier distributeAndDelegateCommunityTokenMocks() {
        for (uint256 i; i < communityMembers.length; i++) {
            communityToken.awardIdentity(communityMembers[i]);
            // note: every member delegates to themselves.
            vm.prank(communityMembers[i]);
            communityToken.delegate(communityMembers[i]);
        }
        _;
    }

    modifier assignRoles() {
        uint256 percentageCitizens = 100; // every member is a citizen. 
        uint256 percentageCouncillors = 10; // every 10th member is a councillor. 
        uint256 percentageJudges = 5; // every 20th member is a judge. 

        vm.startPrank(communityMembers[0]);
        for (uint160 i = 1; i < communityMembers.length; i++) {
            if (i % (100 / percentageCitizens) == 0) {
                governedIdentity.grantRole(governedIdentity.CITIZEN(), communityMembers[i], 0);
            }
            if (i % (100 / percentageCouncillors) == 0) {
                governedIdentity.grantRole(governedIdentity.COUNCILLOR(), communityMembers[i], 0);
            }
            if (i % (100 / percentageJudges) == 0) {
                governedIdentity.grantRole(governedIdentity.JUDGE(), communityMembers[i], 0);
            }
        }
        vm.stopPrank();

        _;
    }

    modifier createProposal() {
        address[] memory targets = new address[](1);
        targets[0] = address(lawsMock);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = (abi.encodeWithSignature("unrestrictedGovernedLaw(uint256)", proposedStateChange));
        string memory description = "this is a hello world proposal, to a restricted and governed law.";

        proposalId = governedIdentity.hashProposal(targets, values, calldatas, keccak256(bytes(description)));

        vm.expectEmit(true, false, false, false);
        emit ProposalCreated(
            proposalId,
            communityMembers[1],
            targets,
            values,
            new string[](targets.length),
            calldatas,
            voteStart,
            voteEnd,
            description
        );

        vm.prank(communityMembers[1]);
        governedIdentity.propose(targets, values, calldatas, description);
        _;
    }

    function setUp() public {
        for (uint160 i; i < communityMembers.length; i++) {
            communityMembers[i] = address(i + 12345); // avoiding address(0); 
        }

        communityToken = new CommunityTokenMock();
        governedIdentity = new GovernedIdentity(communityToken, communityMembers[0]);
        lawsMock = new LawsMock(payable(address(governedIdentity)));
    }

    function test_checkStateProposal() public distributeAndDelegateCommunityTokenMocks createProposal {
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

    function test_membersCanVoteProposalWithinTimeFrame()
        public
        distributeAndDelegateCommunityTokenMocks
        createProposal
        assignRoles
    {
        uint8 vote = 1;

        vm.roll(10_000);
        vm.prank(communityMembers[1]);
        governedIdentity.castVote(proposalId, vote);

        vm.prank(communityMembers[2]);
        governedIdentity.castVote(proposalId, vote);

        vm.prank(communityMembers[3]);
        governedIdentity.castVote(proposalId, vote);
    }

    function test_passedProposalCallsExternalFunction()
        public
        distributeAndDelegateCommunityTokenMocks
        createProposal
        assignRoles
    {
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
        targets[0] = address(lawsMock);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = (abi.encodeWithSignature("unrestrictedGovernedLaw(uint256)", proposedStateChange));
        string memory description = "this is a hello world proposal, to a restricted and governed law.";
        bytes32 descriptionHash = keccak256(bytes(description));

        // check if target contract state has indeed breen changed.
        vm.startPrank(communityMembers[0]);
        governedIdentity.execute(targets, values, calldatas, descriptionHash);
        vm.stopPrank(); 
        uint256 result = lawsMock.s_unrestrictedLaw();
        console.log("HELLO WORLD", result);
    }
}
