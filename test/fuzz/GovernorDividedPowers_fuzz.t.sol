 // SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// Still completely WIP

import {Test, console} from "forge-std/Test.sol";
import {GovernedIdentity} from "../../../src/example-governance-system/GovernedIdentity.sol";
import {LawTemplate} from "../../../src/example-laws/LawTemplate.sol";
import {GovernorDividedPowers} from "../../../src/governor-extensions/GovernorDividedPowers.sol";
import {LawsMock} from "../mocks/LawsMock.sol";
import {CommunityTokenMock} from "../mocks/CommunityTokenMock.sol";

contract GovernorDividedPowers_fuzz is Test {
    LawTemplate lawTemplate;
    LawsMock lawsMock;
    GovernedIdentity governedIdentity;
    CommunityTokenMock communityTokenMock;
    
    enum VoteType {
        Against,
        For,
        Abstain
    }
    struct LoggedVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
    } 
    mapping(uint256 proposalId => LoggedVote) public LoggedVotes;

    address[] communityMembers = new address[](500); // we create a community of a hundred members. 
    uint256 denominator = 100; 
    uint256 percentageCitizens = 100; // every member is a citizen. 
    uint256 percentageCouncillors = 10; // every 10th member is a councillor. 
    uint256 percentageJudges = 5; // every 20th member is a judge. 

    event LawTriggered(bytes32 indexed hashDescription, bool success);

    modifier assignRoles() {

        vm.startPrank(communityMembers[0]);
        for (uint160 i = 1; i < communityMembers.length; i++) {
            // if (i % (denominator / percentageCitizens) == 0) {
            //     governedIdentity.grantRole(governedIdentity.CITIZEN(), communityMembers[i], 0);
            // }
            if (i % (denominator / percentageCouncillors) == 0) {
                governedIdentity.grantRole(governedIdentity.COUNCILLOR(), communityMembers[i], 0);
            }
            if (i % (denominator / percentageJudges) == 0) {
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
        selectorsRolesCouncillor[0] = 0xa4c1fb18; // "councillorsRestrictedGovernedLaw(uint256)"

        bytes4[] memory selectorsRolesJudge = new bytes4[](2);
        selectorsRolesJudge[0] = 0xa196ad83; //  restrictedLaw()
        selectorsRolesJudge[1] = 0xa88f2e64; //  "judgesRestrictedGovernedLaw(uint256)"

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
            communityMembers[i] = address(i + 7); // avoiding address(0); 
        }

        communityTokenMock = new CommunityTokenMock();
        governedIdentity = new GovernedIdentity(communityTokenMock, communityMembers[0]);
        lawsMock = new LawsMock(payable(address(governedIdentity)));
    }

    function test_GovernorCanRewardRoles(uint256 communityMember, uint256 roleType) public {
        communityMember = bound(communityMember, 1, (communityMembers.length - 1)); 
        roleType = bound(roleType, 0, 2); 

        uint64[] memory roles = new uint64[](3);
        roles[0] = governedIdentity.CITIZEN(); 
        roles[1] = governedIdentity.COUNCILLOR(); 
        roles[2] = governedIdentity.JUDGE(); 
        bool hasRole;

        vm.startPrank(communityMembers[0]);
        governedIdentity.grantRole(roles[roleType], communityMembers[communityMember], 0);
        vm.stopPrank(); 

        (hasRole,) = governedIdentity.hasRole(roles[roleType], communityMembers[communityMember]);
        vm.assertEq(hasRole, true);
    }

    function test_RoleBasedAccessRestrictionsWorkWithDirectFunctionCall() public assignRoles restrictFunctions {
        // have randomised account call functions directly. 
    }

    function test_RoleBasedAccessRestrictionsWorkWithPropose() public assignRoles restrictFunctions {
        // have randomised account propose proposals. 
    }

    function test_RoleBasedAccessRestrictionsWorkWithVote() public assignRoles restrictFunctions {
        // have randomised account vote for proposals. 
    }

    function test_RoleBasedAccessRestrictionsWorkWithExecute() public assignRoles restrictFunctions {
        // have randomised account execute proposals. 
    }
     
    function test_VotesAreCorrectlyCounted(uint128 pseudoRandomiser) public assignRoles restrictFunctions {
        // setup 
        uint256 proposedStateChange = 10;
        
        // create proposal: councillor. 
        uint256 proposalIdCouncillor = createProposal(
            10, // Every 10th community member is a councillor. The restrictedGovernedLaw function can be called by Judge role. 
            abi.encodeWithSignature("councillorsRestrictedGovernedLaw(uint256)", proposedStateChange), 
            "This is a proposal for a councillor."
            );
        // create proposal: judge. 
        uint256 proposalIdJudge = createProposal(
            20, // Every 20th community member is a judge. The restrictedGovernedLaw function can be called by Judge role. 
            abi.encodeWithSignature("judgesRestrictedGovernedLaw(uint256)", proposedStateChange), 
            "This is a proposal for a judge."
            );
        // vars for logging votes. 
        LoggedVote storage loggedVoteCouncillors = LoggedVotes[proposalIdCouncillor];
        LoggedVote storage loggedVoteJudges = LoggedVotes[proposalIdJudge];
        
        // get to time point where vote is open
        vm.roll(10_000);

        // action
        // loop through communityMembers.length. If Judge or Councillor, vote & log vote.  
        for (uint160 i = 1; i < communityMembers.length; i++) {
            if (i % (denominator / percentageCouncillors) == 0) {
                // pseudo random vote. 
                uint8 vote = uint8((pseudoRandomiser + i) % 3); 
                vm.prank(communityMembers[i]);
                governedIdentity.castVote(proposalIdCouncillor, vote);
                
                // logging vote 
                if (vote == uint8(VoteType.Against)) {
                    loggedVoteCouncillors.againstVotes += 1;
                } else if (vote == uint8(VoteType.For)) {
                    loggedVoteCouncillors.forVotes += 1;
                } else if (vote == uint8(VoteType.Abstain)) {
                    loggedVoteCouncillors.abstainVotes += 1;
                }
            }
            if (i % (denominator / percentageJudges) == 0) {
                // pseudo random vote. 
                uint8 vote = uint8((pseudoRandomiser + i) % 3); 
                //  uint8 vote = 1; 
                vm.prank(communityMembers[i]);
                governedIdentity.castVote(proposalIdJudge, vote);
                
                // logging vote 
                if (vote == uint8(VoteType.Against)) {
                    loggedVoteJudges.againstVotes += 1;
                } else if (vote == uint8(VoteType.For)) {
                    loggedVoteJudges.forVotes += 1;
                } else if (vote == uint8(VoteType.Abstain)) {
                    loggedVoteJudges.abstainVotes += 1;
                }
            }
        }
        
        
        // get to time point where vote is open
        vm.roll(60_000);

        // checks 
        (uint256 CouncillorAgainst, uint256 CouncillorFor, uint256 CouncillorAbstain) = governedIdentity.proposalVotes(proposalIdCouncillor);
        (uint256 JudgesAgainst, uint256 JudgesFor, uint256 JudgesAbstain) = governedIdentity.proposalVotes(proposalIdJudge);

        vm.assertEq(CouncillorAgainst, loggedVoteCouncillors.againstVotes); 
        vm.assertEq(CouncillorFor, loggedVoteCouncillors.forVotes); 
        vm.assertEq(CouncillorAbstain, loggedVoteCouncillors.abstainVotes); 

        vm.assertEq(JudgesAgainst, loggedVoteJudges.againstVotes); 
        vm.assertEq(JudgesFor, loggedVoteJudges.forVotes); 
        vm.assertEq(JudgesAbstain, loggedVoteJudges.abstainVotes); 
    }


    /*/////////////////////////////////////////////////////
    //             Internal Helper functions             //  
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

    // function failProposal(uint256 proposalId, uint64 RoleRestriction)
    //      internal distributeAndDelegateCommunityToken
    //  {
    //     uint8 vote = 0; // vote against
    //     vm.roll(block.number + 10_000);

    //     // everyone that is allowed to vote, votes against. 
    //     for (uint256 i; i < communityMembers.length; i++) {
    //         (bool hasRole , ) = governedIdentity.hasRole(RoleRestriction, communityMembers[i]); 
    //         if (hasRole) {
    //             vm.prank(communityMembers[i]);
    //             governedIdentity.castVote(proposalId, vote);
    //         } 
    //     }
    // }

}