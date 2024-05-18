// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// RBAC: Role Based Access Control.
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract LawTemplates is AccessControl {
    /* Type declarations */
    struct Law {
      bytes32 role; 
      string description;
      // bytes32 descriptionHash; £q replace string with bytes32 ?   
    }
    // This is Enough! (if I can get )
    // bytes4 function selector to Law (role + description) mapping   
    mapping(bytes4 => Law) public restrictedLaws; 

    /* State variables */
    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER");
    bytes32 public constant COUNCILLOR_ROLE = keccak256("COUNCILLOR");
    bytes32 public constant JUDGE_ROLE = keccak256("JUDGE");

    uint256 public freeStateVar;
    uint256 public restrictedStateVar;
    uint256 public internallySetStateVar;
    
    /* Events */
    event IncorrectSelector(address indexed sender);

    /* Modifiers */

    /* FUNCTIONS */
    /* constructor */
    constructor() {
      // laws.push(
      //   Law({
      //     selector: 0xabac0926,
      //     role: keccak256("COUNCILLOR"), 
      //     description: "this is a test law"
      //   })); 
        // Grant the contract deployer the default admin role: it will be able
        // to grant and revoke any roles
    }

    /* receive function (if exists) */
    /* fallback function (if exists) */
    fallback() external {
        emit IncorrectSelector(msg.sender);
    }

    /**
     * @notice This should be the entry point to laws (written as internal function). 
     *  If I am correct, it should be possible to get the selector of the function from the dataCall. 
     * This would mean that an external contract would call this function with the abi_encoded signature 
     * of the _internal_ function. 
     * 
     * As such, the external party would need to have access to the actual file that has the contracts. 
     * It is not possible to lookup the meaning of laws on-chain.  
     * 
      */
    function accessLaw(Law memory law, bytes memory dataCall) public returns (bool success) {
      _checkRole(law.role); 
      (success, ) = address(this).call(dataCall);
      
      return success;  
    }

    function helloWorld(uint256 _var) external {
        freeStateVar = _var;
    }

    function helloWorldRestricted(uint256 _var) external onlyRole(COUNCILLOR_ROLE) returns (bytes32 role) {
        restrictedStateVar = _var;
        return COUNCILLOR_ROLE; 
    }

    /**
     * @notice These functions are external and have no access control. For now, anyone can asign roles.
     * This will change in the near future.
     *
     */
    function awardMemberRole(address member) external {
        _grantRole(MEMBER_ROLE, member);
    }

    function awardCouncillorRole(address councillor) external {
        _grantRole(COUNCILLOR_ROLE, councillor);
    }

    function awardJudgeRole(address judge) external {
        _grantRole(JUDGE_ROLE, judge);
    }

    /* public */
    /* internal */
    function _internalLaw(uint256 _var) internal {
      internallySetStateVar = _var; 
    }
    /* private */
}

// Structure contract // -- from Patrick Collins.
/* version */
/* imports */
/* errors */
/* interfaces, libraries, contracts */
/* Type declarations */
/* State variables */
/* Events */
/* Modifiers */

/* FUNCTIONS: */
/* constructor */
/* receive function (if exists) */
/* fallback function (if exists) */
/* external */
/* public */
/* internal */
/* private */
/* internal & private view & pure functions */
/* external & public view & pure functions */
