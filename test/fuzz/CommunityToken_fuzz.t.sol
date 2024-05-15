// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CommunityToken} from "../../src/CommunityToken.sol";

contract CommunityTokenTest is Test {
    CommunityToken public communityToken;

    function setUp() public {
        communityToken = new CommunityToken();
    }

    function testFuzz_SetNumber(address member) public {
        communityToken.awardIdentity(member);
        assertEq(communityToken.balanceOf(member), 1);
    }
}
