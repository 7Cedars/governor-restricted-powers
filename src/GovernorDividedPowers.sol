// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";

abstract contract GovernorDividedPowers is Governor, AccessManager {
  // needs to be immutable & part of constructor args when transforming this into extension. 

  // modifier to restrict who can propose and vote on proposals based on restriction of fucntion that proposal calls.  
  // ... 
  modifier governanceRestricted(
    address[] memory targets, 
    bytes4[] memory calldatas,
    address proposer
    ) {
    // bytes4 of calldata will give function selector! :D 

    _; 
  }

  // then override propose etc governance functions. 

  constructor(address _initialAdmin) AccessManager(_initialAdmin) {} 

}