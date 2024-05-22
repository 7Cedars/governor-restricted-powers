// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/**
 * NB: this test file is to try out LawTemplates contract.
 * They are not proper tests (for instance, they miss asserts) yet. Will do so later.
 *
 *
 */
import {Test, console} from "forge-std/Test.sol";
import {LawTemplate} from "../../src/LawTemplate.sol";

contract GovernedIdentityTest is Test {
    LawTemplate lawTemplate;

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

    /**
     * @notice roles are awarded deterministically. For example:
     * communityMembers[0] is member, councillor and judge.
     * communityMembers[9] has no role awarded.
     */
    modifier awardRoles() {
        uint256 numberOfMembers = 8;
        uint256 numberOfCouncillors = 6;
        uint256 numberOfJudges = 2;

        _;
    }

    function setUp() public {
        lawTemplate = new LawTemplate(address(1));
    }

    function test_deployLawEmitsEvent() public {
        // £TODO
    }

    function test_fallBackIsTriggeredWithIncorrectSelector() public {
        // £TODO
    }

    // OLD tests //

    // function test_helloWorldRestrictedRevertsIfNotCalledByCouncillor() public awardRoles {
    //     uint256 _var = 222;

    //     vm.expectRevert();
    //     vm.prank(communityMembers[8]);
    //     lawTemplates.helloWorldRestricted(_var);
    // }

    // function test_helloWorldRestrictedPassesWhenCalledByCouncillor() public awardRoles {
    //   uint256 _var = 444;

    //   vm.prank(communityMembers[2]);
    //   (bool success, bytes32 hashDescription) = lawTemplates.helloWorldRestricted(_var);

    //   vm.assertEq(lawTemplates.restrictedStateVar(), _var);
    // }

    // function test_queryingPriviledgedAccounts() public awardRoles {
    //   lawTemplates

    // }
}
