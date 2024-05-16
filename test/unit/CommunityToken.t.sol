// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {CommunityToken} from "../../src/CommunityToken.sol";

contract CommunityTokenTest is Test {
    CommunityToken public communityToken;

    function setUp() public {
        communityToken = new CommunityToken();
    }

    function test_awardIdentity() public {
        communityToken.awardIdentity(address(1));
        assertEq(communityToken.balanceOf(address(1)), 1);
    }
}
