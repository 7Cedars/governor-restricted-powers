// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/**
 * NB: this test file is to test and try out functionality of the GovernorDividedPowers extension to Openzeppelin's Governor contract.
 *
 * £todo : check how guardian playes with all of this..
 */
import {Test, console} from "forge-std/Test.sol";
import {GovernedIdentity} from "../../../src/example-governance-system/GovernedIdentity.sol";
import {LawTemplate} from "../../../src/example-laws/LawTemplate.sol";
import {GovernorDividedPowers} from "../../../src/governor-extensions/GovernorDividedPowers.sol";
import {LawsMock} from "../../mocks/LawsMock.sol";
import {CommunityTokenMock} from "../../mocks/CommunityTokenMock.sol";
// import {IGovernor} from "../../mocks/CommunityTokenMock.sol";

contract GovernorDividedPowersTest is Test {
    LawTemplate lawTemplate;
    LawsMock lawsMock;
    GovernedIdentity governedIdentity;
    CommunityTokenMock communityTokenMock;

    address[] communityMembers = new address[](100); // we create a community of a hundred members. 

    event LawTriggered(bytes32 indexed hashDescription, bool success);

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

    modifier distributeAndDelegateCommunityToken() {
        for (uint256 i; i < communityMembers.length; i++) {
            communityTokenMock.awardIdentity(communityMembers[i]);
            // note: every member delegates to themselves.
            vm.prank(communityMembers[i]);
            communityTokenMock.delegate(communityMembers[i]);
        }

        _;
    }


    modifier restrictFunctions() {
        bytes4[] memory selectorsRolesCitizen = new bytes4[](2);
        selectorsRolesCitizen[0] = 0x0c8e7067; // "unrestrictedLaw(uint256)": ""
        selectorsRolesCitizen[1] = 0x07a1ac5d; // "unrestrictedGovernedLaw(uint256)": ""

        bytes4[] memory selectorsRolesCouncillor = new bytes4[](1);
        selectorsRolesCouncillor[0] = 0x79ba2b3b; // restrictedGovernedLaw()

        bytes4[] memory selectorsRolesJudge = new bytes4[](2);
        selectorsRolesJudge[0] = 0xa196ad83; //  restrictedLaw()
        selectorsRolesJudge[1] = 0x79ba2b3b; //  restrictedGovernedLaw()


        vm.startPrank(communityMembers[0]);
        governedIdentity.setTargetFunctionRole(
            address(lawsMock), selectorsRolesCitizen, governedIdentity.CITIZEN()
        );
        governedIdentity.setTargetFunctionRole(
            address(lawsMock), selectorsRolesCouncillor, governedIdentity.COUNCILLOR()
        );
        governedIdentity.setTargetFunctionRole(address(lawsMock), selectorsRolesJudge, governedIdentity.JUDGE());
        vm.stopPrank();

        _;
    }

    function setUp() public {
        for (uint160 i; i < communityMembers.length; i++) {
            communityMembers[i] = address(i + 12345); // avoiding address(0); 
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
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = 0x4e8c7ee7; // s_restrictedLaw()

        vm.startPrank(communityMembers[0]);
        governedIdentity.setTargetFunctionRole(address(lawsMock), selectors, governedIdentity.JUDGE());
        vm.stopPrank();

        uint64 assignedRole = governedIdentity.getTargetFunctionRole(address(lawsMock), selectors[0]);
        vm.assertEq(assignedRole, governedIdentity.JUDGE());
    }

    // £ todo 
    function test_GovernorRewardingRoleIsCounted() public assignRoles {
    }

    // £ todo 
    function test_GovernorRevokingRoleIsSubtracted() public assignRoles {
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

        vm.expectRevert();
        vm.prank(address(999));
        lawsMock.unrestrictedGovernedLaw(proposedStateChange);
    }

    function test_RestrictedFunctionSucceedsWithProposalCall() public assignRoles restrictFunctions {
        uint256 proposedStateChange = 123456;
        bytes memory dataCall= abi.encodeWithSignature("restrictedLaw(uint256)", proposedStateChange); 
        string memory proposalDescription = "This is a test proposal."; 

        (bool isClosed) = governedIdentity.isTargetClosed(address(lawsMock)); 
        console.log("isClosed?", isClosed); 

        // create & pass proposal. 
        uint256 proposalId = createProposal(20, dataCall, proposalDescription);
        succeedProposal(proposalId, governedIdentity.JUDGE());
        vm.roll(block.timestamp + 60_000);
        
        // call execute on suceeded proposal:
        address[] memory targets = new address[](1);
        targets[0] = address(lawsMock);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = dataCall; 

        vm.startPrank(communityMembers[20]); 
        governedIdentity.execute(address(lawsMock), dataCall);
        vm.stopPrank();

        vm.assertEq(lawsMock.s_restrictedLaw(), proposedStateChange);
    }

    function test_GovernedFunctionSucceedsWithProposalCall() public assignRoles restrictFunctions {
        uint256 proposedStateChange = 123456;
        bytes memory dataCall= abi.encodeWithSignature("unrestrictedGovernedLaw(uint256)", proposedStateChange); 
        string memory proposalDescription = "This is a test proposal."; 

        // create & pass proposal. 
        uint256 proposalId = createProposal(1, dataCall, proposalDescription);
        succeedProposal(proposalId, governedIdentity.CITIZEN());
        vm.roll(block.timestamp + 600_000_000);

        console.log("address community member[1]:", communityMembers[1]); 
        console.log("address contract GovernedIdentity:", address(governedIdentity)); 
        
        // call execute on suceeded proposal:
        address[] memory targets = new address[](1);
        targets[0] = address(lawsMock);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = dataCall; 
        bytes32 descriptionHash = keccak256(bytes(proposalDescription));
        
        vm.startPrank(communityMembers[1]); 
        governedIdentity.execute(targets, values, calldatas, descriptionHash);
        vm.stopPrank(); 

        vm.assertEq(lawsMock.s_unrestrictedGovernedLaw(), proposedStateChange);
    }

    function test_GovernedRestrictedFunctionRevertsWithUnauthorisedProposalCall() public assignRoles restrictFunctions {
        uint256 proposedStateChange = 123456;
        bytes memory dataCall= abi.encodeWithSignature("restrictedGovernedLaw(uint256)", proposedStateChange); 
        string memory proposalDescription = "This is a test proposal."; 

        uint64 role = governedIdentity.getTargetFunctionRole(address(lawsMock), bytes4(dataCall)); 
        console.log("ROLE: ", role); 

        // create & pass proposal. 
        uint256 proposalId = createProposal(
            20, // Every 20th community member is a judge. The restrictedGovernedLaw function can be called by Judge role. 
            dataCall, 
            proposalDescription
            );
        succeedProposal(proposalId, governedIdentity.JUDGE());
        vm.roll(block.number + 60_000);
        
        address[] memory targets = new address[](1);
        targets[0] = address(lawsMock);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = dataCall; 
        bytes32 descriptionHash = keccak256(bytes(proposalDescription));

        vm.expectRevert();
        vm.startPrank(communityMembers[10]); // Note: this is a councillor role. Should not be able to 
        governedIdentity.execute(targets, values, calldatas, descriptionHash); // this calls execute on Governor contract -- does not pass
        vm.stopPrank(); 
    }
    
    // £todo I have to build these tests. Getting there... 
    function test_GovernedRestrictedFunctionRevertsWithAuthorisedDirectCall() public assignRoles restrictFunctions {
        uint256 proposedStateChange = 123456;
        bytes memory dataCall = abi.encodeWithSignature("restrictedGovernedLaw(uint256)", proposedStateChange); 
        
        address[] memory targets = new address[](1);
        targets[0] = address(lawsMock);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = dataCall;

        // check if community member has correct role to call function. 
        uint64 role = governedIdentity.getTargetFunctionRole(address(lawsMock), bytes4(dataCall)); 
        (bool hasRole , ) = governedIdentity.hasRole(role, communityMembers[20]);
        vm.assertEq(hasRole, true); 

        // calling function directly - reverts. 
        vm.expectRevert();
        vm.startPrank(communityMembers[20]); 
        lawsMock.restrictedGovernedLaw(proposedStateChange);
        vm.stopPrank(); 
    }

    function test_GovernedRestrictedFunctionCannotReceiveUnauthorisedVotes() public assignRoles restrictFunctions {
        uint256 proposedStateChange = 123456;
        bytes memory dataCall= abi.encodeWithSignature("restrictedGovernedLaw(uint256)", proposedStateChange); 
        string memory proposalDescription = "This is a test proposal."; 
        uint8 vote = 1; // vote in favor
        uint160 communityMemberId = 3; 

        // create & pass proposal. 
        uint256 proposalId = createProposal(
            20, // Every 20th community member is a judge. The restrictedGovernedLaw function can be called by Judge role. 
            dataCall, 
            proposalDescription
            );

        // check if community member does NOT have correct role to call function. 
        uint64 role = governedIdentity.getTargetFunctionRole(address(lawsMock), bytes4(dataCall)); 
        (bool hasRole , ) = governedIdentity.hasRole(role, communityMembers[communityMemberId]);
        vm.assertEq(hasRole, false); 
  
        vm.roll(block.number + 10_000);
        vm.expectRevert(); 
        vm.startPrank(communityMembers[communityMemberId]);
        governedIdentity.castVote(proposalId, vote);
        vm.stopPrank(); 
    }

    function test_GovernedRestrictedFunctionCanReceiveAuthorisedVotes() public assignRoles restrictFunctions {
        uint256 proposedStateChange = 123456;
        bytes memory dataCall= abi.encodeWithSignature("restrictedGovernedLaw(uint256)", proposedStateChange); 
        string memory proposalDescription = "This is a test proposal."; 
        uint8 vote = 1; // vote in favor
        uint160 communityMemberId = 40; 

        // create & pass proposal. 
        uint256 proposalId = createProposal(
            20, // Every 20th community member is a judge. The restrictedGovernedLaw function can be called by Judge role. 
            dataCall, 
            proposalDescription
            );

        // check if community member has correct role to call function. 
        uint64 role = governedIdentity.getTargetFunctionRole(address(lawsMock), bytes4(dataCall)); 
        (bool hasRole , ) = governedIdentity.hasRole(role, communityMembers[communityMemberId]);
        vm.assertEq(hasRole, true); 
        
        vm.roll(block.number + 10_000);
        vm.prank(communityMembers[communityMemberId]);
        governedIdentity.castVote(proposalId, vote);
    }

    function test_GovernedRestrictedFunctionSucceedsWithAuthorisedProposalCall() public assignRoles restrictFunctions  {
        uint256 proposedStateChange = 1;
        bytes memory dataCall= abi.encodeWithSignature("restrictedGovernedLaw(uint256)", proposedStateChange); 
        string memory proposalDescription = "This is a test proposal."; 

        uint64 role = governedIdentity.getTargetFunctionRole(address(lawsMock), bytes4(dataCall)); 
        console.log("ROLE: ", role); 

        // create & pass proposal. 
        uint256 proposalId = createProposal(
            20, // Every 20th community member is a judge. The restrictedGovernedLaw function can be called by Judge role. 
            dataCall, 
            proposalDescription
            );
        succeedProposal(proposalId, governedIdentity.JUDGE());

        vm.roll(block.number + 60_000);

        // ProposalState proposalState = governedIdentity.state(proposalId); 

        // console.log("state proposal:", proposalState); 
        
        address[] memory targets = new address[](1);
        targets[0] = address(lawsMock);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = dataCall; 
        bytes32 descriptionHash = keccak256(bytes(proposalDescription));

        vm.roll(block.number + 60_000);
        vm.startPrank(communityMembers[20]);
        governedIdentity.execute(targets, values, calldatas, descriptionHash); // this calls execute on Governor contract -- does not pass
        vm.stopPrank(); 

        vm.assertEq(lawsMock.s_restrictedGovernedLaw(), proposedStateChange);
    }

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
        calldatas[0] = dataCall; 
        
        bytes4 functionSelector = bytes4(calldatas[0]);
        uint64 calldatasRole = governedIdentity.getTargetFunctionRole(targets[0], functionSelector);
        console.log("calldatasRole: ", calldatasRole); 

        vm.prank(communityMembers[memberIndex]);
        proposalId = governedIdentity.propose(targets, values, calldatas, proposalDescription);
    }

    function succeedProposal(uint256 proposalId, uint64 RoleRestriction)
         internal distributeAndDelegateCommunityToken
     {
        uint8 vote = 1; // vote in favor
        vm.roll(block.number + 10_000);

        // everyone that is allowed to vote, votes in favor. 
        for (uint256 i; i < communityMembers.length; i++) {
            (bool hasRole , ) = governedIdentity.hasRole(RoleRestriction, communityMembers[i]); 
            if (hasRole) {
                vm.prank(communityMembers[i]);
                governedIdentity.castVote(proposalId, vote);
            } 
        }
    }

    function failProposal(uint256 proposalId, uint64 RoleRestriction)
         internal distributeAndDelegateCommunityToken
     {
        uint8 vote = 0; // vote against
        vm.roll(block.number + 10_000);

        // everyone that is allowed to vote, votes against. 
        for (uint256 i; i < communityMembers.length; i++) {
            (bool hasRole , ) = governedIdentity.hasRole(RoleRestriction, communityMembers[i]); 
            if (hasRole) {
                vm.prank(communityMembers[i]);
                governedIdentity.castVote(proposalId, vote);
            } 
        }
    }
}
