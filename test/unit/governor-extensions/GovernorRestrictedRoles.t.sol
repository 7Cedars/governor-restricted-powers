// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/**
 * NB: this test file is to test and try out functionality of the GovernorDividedPowers extension to Openzeppelin's Governor contract.
 * They are often not proper tests (for instance, many miss asserts)
 *
 * £todo : check how guardian playes with all of this..
 */
import {Test, console} from "forge-std/Test.sol";
import {GovernedIdentity} from "../../../src/example-governance-system/GovernedIdentity.sol";
import {LawTemplate} from "../../../src/example-laws/LawTemplate.sol";
import {GovernorRestrictedRoles} from "../../../src/governor-extensions/GovernorRestrictedRoles.sol";
import {LawsMock} from "../../mocks/LawsMock.sol";
import {CommunityTokenMock} from "../../mocks/CommunityTokenMock.sol";

contract GovernorRestrictedRolesTest is Test {
    LawTemplate lawTemplate;
    LawsMock lawsMock;
    GovernedIdentity governedIdentity;
    CommunityTokenMock communityTokenMock;

    address[] communityMembers = new address[](100);

    event LawTriggered(bytes32 indexed hashDescription, bool success);

    modifier assignRoles() {
        uint256 percentageCitizens = 100;
        uint256 percentageCouncillors = 10;
        uint256 percentageJudges = 5;

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

    modifier restrictFunctions() {
        bytes4[] memory selectorsRolesCouncillor = new bytes4[](1);
        selectorsRolesCouncillor[0] = 0x79ba2b3b; // restrictedGovernedLaw()

        bytes4[] memory selectorsRolesJudge = new bytes4[](2);
        selectorsRolesJudge[0] = 0xa196ad83; //  restrictedLaw()
        selectorsRolesJudge[1] = 0x79ba2b3b; //  restrictedGovernedLaw()

        vm.startPrank(communityMembers[0]);
        governedIdentity.setTargetFunctionRole(
            address(lawsMock), selectorsRolesCouncillor, governedIdentity.COUNCILLOR()
        );
        governedIdentity.setTargetFunctionRole(address(lawsMock), selectorsRolesJudge, governedIdentity.JUDGE());
        vm.stopPrank();

        _;
    }

    function setUp() public {
        for (uint160 i; i < communityMembers.length; i++) {
            communityMembers[i] = address(i + 12345);
        }

        communityTokenMock = new CommunityTokenMock();
        governedIdentity = new GovernedIdentity(communityTokenMock, communityMembers[0]);
        lawsMock = new LawsMock(payable(address(governedIdentity)));
    }

    function test_GovernorCanRewardRoles() public assignRoles {
        bool hasRole;
        uint256 percentageCitizens = 100;
        uint256 percentageCouncillors = 10;
        uint256 percentageJudges = 5;

        vm.startPrank(communityMembers[0]);
        for (uint160 i = 1; i < communityMembers.length; i++) {
            if (i % (100 / percentageCitizens) == 0) {
                (hasRole,) = governedIdentity.hasRole(governedIdentity.CITIZEN(), communityMembers[i]);
                vm.assertEq(hasRole, true);
            }
            if (i % (100 / percentageCouncillors) == 0) {
                (hasRole,) = governedIdentity.hasRole(governedIdentity.COUNCILLOR(), communityMembers[i]);
                vm.assertEq(hasRole, true);
            }
            if (i % (100 / percentageJudges) == 0) {
                (hasRole,) = governedIdentity.hasRole(governedIdentity.JUDGE(), communityMembers[i]);
                vm.assertEq(hasRole, true);
            }
        }
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
    }

    function test_UnrestrictedFunctionCanBeCalledByAnyone() public {
        uint256 proposedStateChange = 123456;

        vm.prank(address(999));
        lawsMock.unrestrictedLaw(proposedStateChange);

        vm.assertEq(lawsMock.s_unrestrictedLaw(), proposedStateChange);
    }

    function test_SuccesfulCallEmitsCorrectEvent() public {
        uint256 proposedStateChange = 123456;
        bytes32 hashLawDescription = keccak256(bytes("An unrestricted law that changes a state variable."));

        vm.expectEmit(true, false, false, false);
        emit LawTriggered(hashLawDescription, true);
        vm.prank(address(999));
        lawsMock.unrestrictedLaw(proposedStateChange);
    }

    function test_RestrictedFunctionRevertsWithUnauthorisedCall() public restrictFunctions {
        uint256 proposedStateChange = 123456;

        // vm.expectRevert(abi.encodeWithSelector(
        //     LawsMock.AccessManagedUnauthorized.selector, address(999))
        // );

        vm.expectRevert();
        vm.prank(address(999));
        lawsMock.restrictedLaw(proposedStateChange);
    }

    function test_RestrictedFunctionSucceedsWithAuthorisedCall() public assignRoles restrictFunctions {
        uint256 proposedStateChange = 123456;
        bytes32 hashLawDescription = keccak256(bytes("A role restricted law that changes a state variable."));

        vm.expectEmit(true, false, false, false);
        emit LawTriggered(hashLawDescription, true);
        vm.prank(communityMembers[20]); // every 20th community member is a judge.  
        lawsMock.restrictedLaw(proposedStateChange); // restricted by JUDGE role.

        vm.assertEq(lawsMock.s_restrictedLaw(), proposedStateChange);
    }

    function test_GovernedFunctionRevertsWithDirectCall() public {
        uint256 proposedStateChange = 123456;

        // vm.expectRevert(abi.encodeWithSelector(
        //     LawsMock.GovernorOnly.selector, address(999))
        // );

        vm.expectRevert();
        vm.prank(address(999));
        lawsMock.unrestrictedGovernedLaw(proposedStateChange);
    }

    // £todo I have to build these tests I think. Have fun :D
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
    function createProposal(uint256 memberIndex, bytes memory dataCall, string memory proposalDescription)
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
        proposalId = governedIdentity.propose(targets, values, calldatas, proposalDescription);
    }

    // function succeedProposal(uint256 proposalId)
    //     internal
    // {
    //     uint8 voteFor = 1;

    //     address[] memory targets = new address[](1);
    //     targets[0] = address(lawsMock);
    //     uint256[] memory values = new uint256[](1);
    //     values[0] = 0;
    //     bytes[] memory calldatas = new bytes[](1);
    //     calldatas[0] = dataCall; // (abi.encodeWithSignature("helloWorld(uint256)", proposedStateChange));

    //     vm.prank(communityMembers[memberIndex]);
    //     governedIdentity.castVote(proposalId, vote);

    // }

    // function failProposal(uint256 proposalId)
    //     internal
    // {
    //     uint8 voteAgainst = 0;
    // }

    // helper function to vote on and pass proposal for functions in LawsMock.sol.
    // function voteAndPassProposal ...
    // £todo
}
