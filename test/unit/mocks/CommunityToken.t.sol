// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {CommunityTokenMock} from "../../mocks/CommunityTokenMock.sol";

contract CommunityTokenTest is Test {
    CommunityTokenMock public communityTokenMock;

    function setUp() public {
        communityTokenMock = new CommunityTokenMock();
    }

    function test_awardIdentity() public {
        communityTokenMock.awardIdentity(address(1));
        assertEq(communityTokenMock.balanceOf(address(1)), 1);
    }
}
