// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/**
 * NB: this test file is to test and try out functionality of the GovernorDividedPowers extension to Openzeppelin's Governor contract.
 * They are often not proper tests (for instance, many miss asserts)
 *
 * £todo : check how guardian playes with all of this..
 */
import {Test, console} from "forge-std/Test.sol";
import {GovernedIdentity} from "../../src/GovernedIdentity.sol";
import {LawTemplate} from "../../src/LawTemplate.sol";
import {GovernorRestrictedRoles} from "../../src/GovernorRestrictedRoles.sol";
import {LawsMock} from "../mocks/LawsMock.sol";
import {CommunityTokenMock} from "../mocks/CommunityTokenMock.sol";

contract GovernorDividedPowersTest is Test {
    LawTemplate lawTemplate;
    LawsMock lawsMock;
    GovernedIdentity governedIdentity;
    CommunityTokenMock communityTokenMock;

    address[] communityMembers = [
        address(1), // = admin.
        address(2),
        address(3),
        address(4),
        address(999) // account unrelated to the protocol. Has no roles assigned what so ever.
    ];

    modifier assignRoles() {
        vm.startPrank(communityMembers[0]);
        governedIdentity.grantRole(governedIdentity.COUNCILLOR(), communityMembers[1], 0);
        governedIdentity.grantRole(governedIdentity.COUNCILLOR(), communityMembers[2], 0);
        governedIdentity.grantRole(governedIdentity.JUDGE(), communityMembers[2], 0);
        governedIdentity.grantRole(governedIdentity.CITIZEN(), communityMembers[3], 0);
        vm.stopPrank();

        _;
    }

    modifier restrictFunctions() {
        bytes4[] memory selectorsCouncillorRole = new bytes4[](1);
        selectorsCouncillorRole[0] = 0x233f8c8f; // s_restrictedGovernedLaw()

        bytes4[] memory selectorsJudgeRole = new bytes4[](2);
        selectorsJudgeRole[0] = 0x4e8c7ee7; //  s_restrictedLaw()
        selectorsJudgeRole[1] = 0x233f8c8f; //  s_restrictedGovernedLaw()

        vm.startPrank(communityMembers[0]);
        governedIdentity.setTargetFunctionRole(
            address(lawsMock), selectorsCouncillorRole, governedIdentity.COUNCILLOR()
        );
        governedIdentity.setTargetFunctionRole(address(lawsMock), selectorsJudgeRole, governedIdentity.JUDGE());
        vm.stopPrank();

        _;
    }

    function setUp() public {
        communityTokenMock = new CommunityTokenMock();
        governedIdentity = new GovernedIdentity(communityTokenMock, communityMembers[0]);
        lawsMock = new LawsMock(payable(address(governedIdentity)));
    }

    function test_GovernorCanRewardRoles() public assignRoles {
        //  £todo here place asserts to test if roles have been properly assigned.

        // use hasRole function.
    }

    function test_GovernorCanRestrictFunctionByRole() public assignRoles {
        uint256 proposedStateChange = 3333;
        uint256 restrictedLawBefore;
        uint256 restrictedLawAfter;
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = 0x4e8c7ee7; // s_restrictedLaw()

        vm.startPrank(communityMembers[0]);
        governedIdentity.setTargetFunctionRole(address(lawsMock), selectors, governedIdentity.JUDGE());
        vm.stopPrank();

        uint64 assignedRole = governedIdentity.getTargetFunctionRole(address(lawsMock), selectors[0]);
        vm.assertEq(assignedRole, governedIdentity.JUDGE());

        // vm.roll(7_000);
        // vm.warp(123_000);

        // restrictedLawBefore = lawsMock.s_restrictedLaw();

        // vm.expectRevert();
        // vm.prank(communityMembers[1]);
        // lawsMock.restrictedLaw(proposedStateChange);

        // vm.prank(communityMembers[2]);
        // lawsMock.restrictedLaw(proposedStateChange);

        // restrictedLawAfter = lawsMock.s_restrictedLaw();

        // assert(restrictedLawBefore != restrictedLawAfter);
    }

    // £todo I have to build these tests I think. Have fun :D

    function test_UnrestrictedFunctionCanBeCalledByAnyone() public {}

    function test_SuccesfulCallEmitsCorrectEvent() public {}

    function test_RestrictedFunctionRevertsWithUnauthorisedCall() public {}

    function test_RestrictedFunctionSucceedsWithAuthorisedCall() public {}

    function test_RestrictedFunctionRevertsWithDirectCall() public {}

    function test_GovernedFunctionSucceedsWithProposalCall() public {}

    function test_GovernedRestrictedFunctionRevertsWithUnauthorisedProposalCall() public {}

    function test_GovernedRestrictedFunctionRevertsWithAuthorisedDirectCall() public {}

    function test_GovernedRestrictedFunctionCannotReceiveUnauthorisedVotes() public {}

    function test_GovernedRestrictedFunctionCanReceiveAuthorisedVotes() public {}

    function test_GovernedRestrictedFunctionSucceedsWithAuthorisedProposalCall() public {}

    /*/////////////////////////////////////////////////////
    //                Helper functions                   //  
    /////////////////////////////////////////////////////*/

    // helper function to create proposal for functions in LawsMock.sol.
    function createProposal(uint256 memberIndex, bytes memory dataCall, string memory description)
        internal
        returns (uint256 proposalId)
    {
        address[] memory targets = new address[](1);
        targets[0] = address(lawsMock);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = dataCall; // (abi.encodeWithSignature("helloWorld(uint256)", proposedStateChange));

        vm.prank(communityMembers[memberIndex]);
        proposalId = governedIdentity.propose(targets, values, calldatas, description);
    }

    // helper function to vote on and pass proposal for functions in LawsMock.sol.
    // function voteAndPassProposal ...
    // £todo
}
