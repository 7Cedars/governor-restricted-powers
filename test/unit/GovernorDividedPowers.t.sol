// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/* 
NB: this test file is to try out Governor and AccesControl contracts. 
They are not proper tests (for instance, they miss asserts) 
*/

import {Test, console} from "forge-std/Test.sol";
import {CommunityToken} from "../../src/CommunityToken.sol";
import {GovernedIdentity} from "../../src/GovernedIdentity.sol";
import {LawTemplates} from "../../src/LawTemplates.sol";
import {GovernorDividedPowers} from "../../src/GovernorDividedPowers.sol";

contract GovernorDividedPowersTest is Test {
  LawTemplates lawTemplates; 
  GovernorDividedPowers governorDividedPowers; 

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

  function setUp() public {
    governorDividedPowers = new GovernorDividedPowers(communityMembers[0]);
    lawTemplates = new LawTemplates(address(governorDividedPowers));
  }

  function test_GovernorCanRewardCouncillorAndJudgeRoles() public {

    vm.startPrank(communityMembers[0]); 
    governorDividedPowers.grantRole(governorDividedPowers.COUNCILLOR(), communityMembers[1], 1); 
    governorDividedPowers.grantRole(governorDividedPowers.JUDGE(), communityMembers[2], 1); 
    vm.stopPrank();

  }

    function test_GovernorCanRestrictFunctionByRole() public {
      uint256 proposedStateChange = 3333; 
      uint256 restrictedStateVarBefore; 
      uint256 restrictedStateVarAfter; 
      bytes4[] memory selectors = new bytes4[](1); 
      selectors[0] = 0x51ea00d8; 

    vm.startPrank(communityMembers[0]); 
    governorDividedPowers.grantRole(governorDividedPowers.COUNCILLOR(), communityMembers[1], 0); 
    governorDividedPowers.grantRole(governorDividedPowers.JUDGE(), communityMembers[2], 0); 
    
    governorDividedPowers.setTargetFunctionRole(address(lawTemplates), selectors, governorDividedPowers.JUDGE()); 
    vm.stopPrank();

    restrictedStateVarBefore = lawTemplates.restrictedStateVar(); 

    vm.roll(7_000);
    vm.warp(123_000);

    // check 
    governorDividedPowers.canCall(communityMembers[2], address(lawTemplates), selectors[0]); 

    restrictedStateVarBefore = lawTemplates.restrictedStateVar(); 

    vm.expectRevert(); 
    vm.prank(communityMembers[1]); 
    lawTemplates.helloWorldRestricted(proposedStateChange); 

    vm.prank(communityMembers[2]); 
    lawTemplates.helloWorldRestricted(proposedStateChange); 

    restrictedStateVarAfter = lawTemplates.restrictedStateVar(); 

    assert(restrictedStateVarBefore != restrictedStateVarAfter); 

    
  }


}


