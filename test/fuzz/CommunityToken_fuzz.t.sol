// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {CommunityTokenMock} from "../mocks/CommunityTokenMock.sol";

contract CommunityTokenTest is Test {
    CommunityTokenMock public communityTokenMock;

    function setUp() public {
        communityTokenMock = new CommunityTokenMock();
    }

    function testFuzz_SetNumber(address member) public {
        if (member != address(0)) {
            communityTokenMock.awardIdentity(member);
            assertEq(communityTokenMock.balanceOf(member), 1);
        }
    }
}
