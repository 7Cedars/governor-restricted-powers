// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {CommunityToken} from "../../src/CommunityToken.sol";

contract CommunityTokenTest is Test {
    CommunityToken public communityToken;

    function setUp() public {
        communityToken = new CommunityToken();
    }

    function testFuzz_SetNumber(address member) public {

        if (member != address(0)) {
            communityToken.awardIdentity(member);
            assertEq(communityToken.balanceOf(member), 1);
        }
    }
}
