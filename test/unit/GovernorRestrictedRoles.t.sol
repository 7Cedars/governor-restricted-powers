// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/* 
NB: this test file is to test and try out functionality of the GovernorDividedPowers extension to Openzeppelin's Governor contract.  
They are often not proper tests (for instance, many miss asserts) 
*/

import {Test, console} from "forge-std/Test.sol";
import {CommunityToken} from "../../src/CommunityToken.sol";
import {GovernedIdentity} from "../../src/GovernedIdentity.sol";
import {LawTemplate} from "../../src/LawTemplate.sol";
import {LawsPlayground} from "../../src/LawsPlayground.sol"; 
import {GovernorRestrictedRoles} from "../../src/GovernorRestrictedRoles.sol";

contract GovernorDividedPowersTest is Test {
  LawTemplate lawTemplate; 
  LawsPlayground lawsPlayground; 
  GovernedIdentity governedIdentity; 
  CommunityToken communityToken;
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
    communityToken = new CommunityToken();
    governedIdentity = new GovernedIdentity(communityToken, communityMembers[0]);
    lawsPlayground = new LawsPlayground(address(governedIdentity));
  }

  function test_GovernorCanRewardCouncillorAndJudgeRoles() public {
    vm.startPrank(communityMembers[0]); 
    governedIdentity.grantRole(governedIdentity.COUNCILLOR(), communityMembers[1], 0); 
    governedIdentity.grantRole(governedIdentity.JUDGE(), communityMembers[2], 0); 
    governedIdentity.grantRole(governedIdentity.CITIZEN(), communityMembers[3], 0); 
    vm.stopPrank();
  }

  function test_GovernorCanRestrictFunctionByRole() public {
      uint256 proposedStateChange = 3333; 
      uint256 restrictedStateVarBefore; 
      uint256 restrictedStateVarAfter; 
      bytes4[] memory selectors = new bytes4[](1); 
      selectors[0] = 0xc70aff61; //  helloWorldRestrictedOne

    vm.startPrank(communityMembers[0]); 
    governedIdentity.grantRole(governedIdentity.COUNCILLOR(), communityMembers[1], 0); 
    governedIdentity.grantRole(governedIdentity.JUDGE(), communityMembers[2], 0); 
    
    governedIdentity.setTargetFunctionRole(address(lawsPlayground), selectors, governedIdentity.JUDGE()); 
    vm.stopPrank();

    restrictedStateVarBefore = lawsPlayground.restrictedStateVarOne(); 

    vm.roll(7_000);
    vm.warp(123_000);

    // check 
    governedIdentity.canCall(communityMembers[2], address(lawsPlayground), selectors[0]); 

    restrictedStateVarBefore = lawsPlayground.restrictedStateVarOne(); 

    vm.expectRevert(); 
    vm.prank(communityMembers[1]); 
    lawsPlayground.helloWorldRestrictedOne(proposedStateChange); 

    vm.prank(communityMembers[2]); 
    lawsPlayground.helloWorldRestrictedOne(proposedStateChange); 

    restrictedStateVarAfter = lawsPlayground.restrictedStateVarOne(); 

    assert(restrictedStateVarBefore != restrictedStateVarAfter); 

    
  }


}


